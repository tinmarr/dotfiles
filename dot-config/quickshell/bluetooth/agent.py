"""BlueZ KeyboardDisplay agent for Quickshell. Requires python-gobject.

JSON prompts and replies use private stdout/stdin pipes. No credentials in logs.
"""
import json
import os
import sys
from gi.repository import Gio, GLib

PATH = '/quickshell/bluetooth_agent'
METHODS = {
    'Release': '', 'Cancel': '',
    'RequestPinCode': 'o>s', 'DisplayPinCode': 'os',
    'RequestPasskey': 'o>u', 'DisplayPasskey': 'ouq',
    'RequestConfirmation': 'ou', 'RequestAuthorization': 'o',
    'AuthorizeService': 'os',
}


def emit(**data):
    print(json.dumps(data), flush=True)


class Agent:
    def __init__(self):
        self.pending = None
        self.kind = ''
        self.buffer = b''
        self.owner = None
        self.bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
        methods = ''
        for name, signature in METHODS.items():
            inputs, _, outputs = signature.partition('>')
            args = ''.join(f'<arg type="{t}" direction="{direction}"/>'
                           for direction, types in [('in', inputs), ('out', outputs)] for t in types)
            methods += f'<method name="{name}">{args}</method>'
        info = Gio.DBusNodeInfo.new_for_xml(
            f'<node><interface name="org.bluez.Agent1">{methods}</interface></node>')
        self.bus.register_object(PATH, info.interfaces[0], self.request, None, None)
        Gio.bus_watch_name_on_connection(self.bus, 'org.bluez', Gio.BusNameWatcherFlags.NONE,
                                        self.appeared, self.vanished)
        self.bus.signal_subscribe('org.bluez', 'org.freedesktop.DBus.Properties',
                                  'PropertiesChanged', None, None, Gio.DBusSignalFlags.NONE,
                                  self.changed)
        GLib.io_add_watch(sys.stdin, GLib.IO_IN | GLib.IO_HUP, self.read)

    def appeared(self, connection, name, owner):
        self.owner = owner
        try:
            for method, args in [
                ('RegisterAgent', GLib.Variant('(os)', (PATH, 'KeyboardDisplay'))),
                ('RequestDefaultAgent', GLib.Variant('(o)', (PATH,))),
            ]:
                self.bus.call_sync('org.bluez', '/org/bluez', 'org.bluez.AgentManager1',
                                   method, args, None, Gio.DBusCallFlags.NONE, 3000, None)
            emit(ready=True, error='')
        except GLib.Error as error:
            emit(ready=False, error=str(error))

    def clear(self):
        if self.pending:
            self.pending.return_dbus_error('org.bluez.Error.Canceled', 'Pairing canceled')
        self.pending = None
        self.kind = ''
        emit(prompt=None)

    def vanished(self, *args):
        self.owner = None
        self.clear()
        emit(ready=False, error='Bluetooth service is unavailable.')

    def changed(self, connection, sender, path, interface, signal, parameters):
        iface, changes, invalidated = parameters.unpack()
        if getattr(self, 'device', '') == path and iface == 'org.bluez.Device1':
            if changes.get('Paired') or changes.get('Connected') is False:
                self.clear()

    def request(self, connection, sender, path, interface, method, parameters, invocation):
        if sender != self.owner:
            invocation.return_dbus_error('org.bluez.Error.Rejected', 'Only BlueZ may call this agent')
            return
        args = parameters.unpack()
        if method in ('Release', 'Cancel'):
            self.clear()
            if method == 'Release':
                emit(ready=False, error='Bluetooth pairing agent was released.')
            invocation.return_value(None)
            return
        if self.pending:
            invocation.return_dbus_error('org.bluez.Error.Rejected', 'Another pairing request is pending')
            return
        self.device = str(args[0])
        self.kind = method
        prompt = dict(kind=method, device=self.device.rsplit('/dev_', 1)[-1].replace('_', ':'))
        if method in ('DisplayPinCode', 'DisplayPasskey', 'RequestConfirmation'):
            prompt['code'] = str(args[1]) if method == 'DisplayPinCode' else f'{args[1]:06d}'
        if method == 'DisplayPasskey':
            prompt['entered'] = int(args[2])
        if method == 'AuthorizeService':
            prompt['uuid'] = str(args[1])
        if method.startswith('Display'):
            invocation.return_value(None)
        else:
            self.pending = invocation
        emit(prompt=prompt)

    def dispatch(self, data):
        if data['action'] == 'cancel':
            self.clear()
        elif data['action'] == 'reply' and self.pending:
            if not data.get('accept'):
                self.pending.return_dbus_error('org.bluez.Error.Rejected', 'User rejected pairing')
            elif self.kind == 'RequestPinCode':
                value = data.get('value', '')
                if not 1 <= len(value) <= 16:
                    emit(error='PIN must contain 1 to 16 characters.')
                    return
                self.pending.return_value(GLib.Variant('(s)', (value,)))
            elif self.kind == 'RequestPasskey':
                value = data.get('value', '')
                if not value.isascii() or not value.isdecimal() or len(value) > 6:
                    emit(error='Passkey must contain 1 to 6 digits.')
                    return
                self.pending.return_value(GLib.Variant('(u)', (int(value),)))
            else:
                self.pending.return_value(None)
            self.pending = None
            self.clear()
            emit(error='')

    def read(self, source, condition):
        chunk = os.read(sys.stdin.fileno(), 4096)
        if not chunk:
            self.clear()
            loop.quit()
            return False
        self.buffer += chunk
        while b'\n' in self.buffer:
            line, self.buffer = self.buffer.split(b'\n', 1)
            try:
                self.dispatch(json.loads(line))
            except (ValueError, KeyError, TypeError):
                emit(error='Invalid pairing agent request.')
        return True


if __name__ == '__main__':
    loop = GLib.MainLoop()
    try:
        agent = Agent()
        loop.run()
    except GLib.Error as error:
        emit(ready=False, error=str(error))
