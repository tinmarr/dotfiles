local function reload()
    hl.exec_cmd("hyprctl reload")
    hl.exec_cmd(
        "app2unit -u sunsetctl.service -t service -s b -- systemd-cat -t sunsetctl ~/.config/hypr/sunsetctl.sh")
    hl.exec_cmd("systemctl restart --user awww-daemon.service")
    hl.exec_cmd("systemctl --user stop qs; app2unit -u qs.service -t service -s a -- qs")
end

return {
    reload = reload
}
