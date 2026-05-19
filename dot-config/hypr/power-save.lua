local enable = not hl.get_config("decoration.blur.enabled")

hl.config({ decoration = { blur = { enabled = enable } } })
hl.config({ animations = { enabled = enable } })
