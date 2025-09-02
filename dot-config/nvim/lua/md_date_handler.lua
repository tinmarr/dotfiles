-- lua/render_md_date_handler.lua
local M = {}

local iso_pat = ":_ %(%d%d%d%d%-%d%d%-%d%d%)"


local function parse_iso_date(iso)
    local y, m, d = iso:match("^:_ %((%d%d%d%d)%-(%d%d)%-(%d%d)%)")
    if not y then return nil end
    return os.time({
        year = tonumber(y, 10),
        month = tonumber(m, 10),
        day = tonumber(d, 10),
    })
end

local function day_label_from_diff(diff)
    local label = { "" }
    if diff == 0 then
        label = { "today", "CatppucinPeach" }
    elseif diff == 1 then
        label = { "tomorrow", "CatppucinPeach" }
    elseif diff == -1 then
        label = { "yesterday", "CatppucinRed" }
    elseif diff > 0 then
        label = { string.format("in %d days", diff), diff <= 3 and "CatppucinYellow" or "CatppucinGreen" }
    else
        label = { string.format("%d days ago", -diff), "CatppucinRed" }
    end

    label[1] = "(due " .. label[1] .. ")"
    return label
end

local function label_for_iso(iso)
    local t = parse_iso_date(iso)
    if not t then
        return nil
    end
    local now = os.time()
    local diff = math.floor((t - now) / 86400 + 0.5)
    return day_label_from_diff(diff)
end

-- ctx: render.md.handler.Context { buf = bufnr, root = TSNode }
function M.parse(ctx)
    local bufnr = ctx.buf
    local root = ctx.root
    if not (bufnr and root) then
        return {}
    end

    -- get the textual contents of the node
    local ok, text = pcall(vim.treesitter.get_node_text, root, bufnr)
    if not ok or not text or text == "" then
        return {}
    end

    local marks = {}

    -- base row/col for the node within the buffer
    local srow, scol, erow, ecol = root:range()

    -- iterate through each line in the node text
    local row_offset = 0
    for line in text:gmatch("([^\n]*)\n?") do
        if line == "" and row_offset > 0 and row_offset >= (erow - srow + 1) then
            break
        end

        -- search ISO dates in the line
        local init = 1
        while true do
            local s, e = line:find(iso_pat, init)
            if not s then
                break
            end
            local iso = line:sub(s, e)
            local iso_len = #iso
            local label = label_for_iso(iso)
            if label then
                local start_row = srow + row_offset
                local start_col = (row_offset == 0) and (scol + s + 2) or (s + 2)
                local end_col = start_col + iso_len - 3
                table.insert(marks, {
                    conceal = true,
                    start_row = start_row,
                    start_col = start_col,
                    opts = {
                        virt_text = { label },
                        virt_text_pos = "inline",
                        hl_mode = "combine",
                        end_col = end_col,
                        conceal = "",
                    },
                })
            end
            init = e + 1
        end

        row_offset = row_offset + 1
    end

    return marks
end

return M
