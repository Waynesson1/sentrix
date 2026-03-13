local ConsoleInput = {}
ConsoleInput.__index = ConsoleInput

local keyMap = {
	["\27[A"] = "up",
	["\27[B"] = "down",
	["\27[D"] = "left",
	["\27[C"] = "right",
	["w"] = "up",
	["s"] = "down",
	["a"] = "left",
	["d"] = "right",
	[""] = "select",
	["e"] = "select",
	["q"] = "back",
	["m"] = "toggle",
	["x"] = "exit",
}

function ConsoleInput.new()
	return setmetatable({}, ConsoleInput)
end

function ConsoleInput:poll()
	io.write("Input [w/s/a/d, enter/e, q, m, x]: ")
	local raw = io.read("*l")
	if raw == nil then
		return nil
	end

	return keyMap[raw]
end

return ConsoleInput
