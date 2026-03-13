local ConsoleRenderer = {}
ConsoleRenderer.__index = ConsoleRenderer

local function clear()
	io.write("\27[2J\27[H")
end

local function line(width)
	return "+" .. string.rep("-", width - 2) .. "+"
end

local function padRight(text, width)
	local value = tostring(text or "")
	if #value >= width then
		return value:sub(1, width)
	end
	return value .. string.rep(" ", width - #value)
end

function ConsoleRenderer.new(opts)
	opts = opts or {}

	return setmetatable({
		width = opts.width or 56,
	}, ConsoleRenderer)
end

function ConsoleRenderer:render(menu)
	clear()

	local width = self.width
	print(line(width))
	print("| " .. padRight(menu.title, width - 4) .. " |")
	print(line(width))

	local rows = menu:getRenderableItems()
	if #rows == 0 then
		print("| " .. padRight("(empty)", width - 4) .. " |")
	else
		for _, row in ipairs(rows) do
			local prefix = row.selected and "> " or "  "
			local leftWidth = math.floor((width - 6) * 0.65)
			local rightWidth = (width - 6) - leftWidth

			local left = padRight(prefix .. row.label, leftWidth)
			local right = padRight(row.value or "", rightWidth)
			print("| " .. left .. right .. " |")
		end
	end

	print(line(width))
end

function ConsoleRenderer:renderClosed()
	clear()
	print("[Menu Hidden] Press 'm' to open")
end

return ConsoleRenderer
