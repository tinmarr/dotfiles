"""Line-delimited JSON bridge between Quickshell and iwd. Requires python-gobject.

Passwords travel only over the private stdin pipe and D-Bus, never argv or logs.
API: https://kernel.googlesource.com/pub/scm/network/wireless/iwd/+/master/doc/
"""
import json
import os
import sys
from gi.repository import Gio, GLib

IWD = 'net.connman.iwd'
AGENT = '/quickshell/network_agent'


def emit(**data):
    print(json.dumps(data), flush=True)


class Backend:
    def __init__(self):
        self.bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
        self.device = ''
        self.input_buffer = b''
        self.pending = None
        self.busy = False
        self.refresh_pending = False
        methods = ''.join(
            f'<method name="{name}">{args}</method>' for name, args in {
                'Release': '', 'Cancel': '<arg type="s" direction="in"/>',
                'RequestPassphrase': '<arg type="o" direction="in"/><arg type="s" direction="out"/>',
                'RequestPrivateKeyPassphrase': '<arg type="o" direction="in"/><arg type="s" direction="out"/>',
                'RequestUserPassword': '<arg type="o" direction="in"/><arg type="s" direction="in"/><arg type="s" direction="out"/>',
                'RequestUserNameAndPassword': '<arg type="o" direction="in"/><arg type="s" direction="out"/><arg type="s" direction="out"/>',
            }.items())
        info = Gio.DBusNodeInfo.new_for_xml(f'<node><interface name="{IWD}.Agent">{methods}</interface></node>')
        self.bus.register_object(AGENT, info.interfaces[0], self.agent, None, None)
        Gio.bus_watch_name_on_connection(self.bus, IWD, Gio.BusNameWatcherFlags.NONE, self.appeared, self.vanished)
        self.bus.signal_subscribe(IWD, None, None, None, None, Gio.DBusSignalFlags.NONE, self.schedule_refresh)
        GLib.io_add_watch(sys.stdin, GLib.IO_IN | GLib.IO_HUP, self.read)
        GLib.timeout_add_seconds(15, self.schedule_refresh)

    def call(self, path, interface, method, args=None):
        return self.bus.call_sync(IWD, path, interface, method, args, None, Gio.DBusCallFlags.NONE, 3000, None).unpack()

    def appeared(self, *args):
        try:
            self.call('/net/connman/iwd', IWD + '.AgentManager', 'RegisterAgent', GLib.Variant('(o)', (AGENT,)))
            self.schedule_refresh()
        except GLib.Error as error:
            emit(error=str(error))

    def vanished(self, *args):
        self.cancel()
        emit(devices=[], networks=[], state='unavailable', powered=False, busy=False, error='iwd is unavailable.')

    def schedule_refresh(self, *args):
        if not self.refresh_pending:
            self.refresh_pending = True
            GLib.timeout_add(150, self.refresh)
        return True

    def refresh(self):
        self.refresh_pending = False
        try:
            objects = self.call('/', 'org.freedesktop.DBus.ObjectManager', 'GetManagedObjects')[0]
            devices = [dict(path=p, name=v[IWD + '.Device']['Name'], powered=v[IWD + '.Device'].get('Powered', False))
                       for p, v in objects.items() if IWD + '.Device' in v and v[IWD + '.Device'].get('Mode') == 'station']
            if self.device not in [d['path'] for d in devices]:
                self.device = next((d['path'] for d in devices if d['powered']), devices[0]['path'] if devices else '')
            props = objects.get(self.device, {})
            station = props.get(IWD + '.Station', {})
            powered = props.get(IWD + '.Device', {}).get('Powered', False)
            strengths = dict(self.call(self.device, IWD + '.Station', 'GetOrderedNetworks')[0]) if powered and station else {}
            networks = []
            for path, interfaces in objects.items():
                network = interfaces.get(IWD + '.Network')
                if network and network.get('Device') == self.device:
                    known = network.get('KnownNetwork', '')
                    networks.append(dict(path=path, name=network['Name'], security=network['Type'],
                                         connected=network.get('Connected', False), known=known,
                                         autoconnect=objects.get(known, {}).get(IWD + '.KnownNetwork', {}).get('AutoConnect', True),
                                         signal=round(strengths.get(path, -10000) / 100)))
            networks.sort(key=lambda n: (not n['connected'], not bool(n['known']), -(n['signal'] or -100), n['name']))
            emit(devices=devices, device=self.device, networks=networks, powered=powered,
                 state=station.get('State', 'disconnected'), scanning=station.get('Scanning', False))
        except GLib.Error as error:
            emit(error=str(error))
        return False

    def cancel(self):
        if self.pending:
            self.pending.return_dbus_error(IWD + '.Agent.Error.Canceled', 'Canceled by user')
            self.pending = None
        emit(prompt='')

    def agent(self, connection, sender, path, interface, method, params, invocation):
        if method in ('Release', 'Cancel'):
            self.cancel()
            invocation.return_value(None)
        else:
            self.cancel()
            self.pending = invocation
            emit(prompt=method)

    def completed(self, bus, result):
        try:
            bus.call_finish(result)
        except GLib.Error as error:
            emit(error=str(error))
        self.busy = False
        emit(busy=False)
        self.schedule_refresh()

    def read(self, source, condition):
        if condition & GLib.IO_HUP:
            self.cancel()
            loop.quit()
            return False
        chunk = os.read(source.fileno(), 65536)
        if not chunk:
            loop.quit()
            return False
        self.input_buffer += chunk
        while b'\n' in self.input_buffer:
            line, self.input_buffer = self.input_buffer.split(b'\n', 1)
            self.dispatch(line)
        return True

    def dispatch(self, line):
        try:
            data = json.loads(line)
            action = data['action']
            if action == 'credentials':
                if self.pending:
                    values = (data.get('username', ''), data['password']) if data.get('usernameRequired') else (data['password'],)
                    self.pending.return_value(GLib.Variant('(ss)' if len(values) == 2 else '(s)', values))
                    self.pending = None
                    emit(prompt='')
                return
            if action == 'cancel':
                self.cancel()
                return
            if action in ('device', 'refresh'):
                if action == 'device':
                    self.device = data['path']
                self.schedule_refresh()
                return
            if self.busy:
                return
            path = data.get('path', self.device)
            interface, method, args = {
                'scan': (IWD + '.Station', 'Scan', None),
                'connect': (IWD + '.Network', 'Connect', None),
                'disconnect': (IWD + '.Station', 'Disconnect', None),
                'forget': (IWD + '.KnownNetwork', 'Forget', None),
                'hidden': (IWD + '.Station', 'ConnectHiddenNetwork', GLib.Variant('(s)', (data.get('ssid', ''),))),
                'power': ('org.freedesktop.DBus.Properties', 'Set', GLib.Variant('(ssv)', (IWD + '.Device', 'Powered', GLib.Variant('b', data.get('value', False))))),
                'autoconnect': ('org.freedesktop.DBus.Properties', 'Set', GLib.Variant('(ssv)', (IWD + '.KnownNetwork', 'AutoConnect', GLib.Variant('b', data.get('value', False))))),
            }[action]
            self.busy = True
            emit(busy=True, error='')
            self.bus.call(IWD, path, interface, method, args, None, Gio.DBusCallFlags.NONE, 120000, None, self.completed)
        except (ValueError, KeyError, GLib.Error) as error:
            emit(error=str(error))


loop = GLib.MainLoop()
try:
    Backend()
    loop.run()
except GLib.Error as error:
    emit(error=str(error))
