--!nocheck

-- Red-engine style GitHub bootstrap template.
-- Upload repo to GitHub, then set `baseUrl` and `httpGet` below.

local baseUrl = "https://raw.githubusercontent.com/Waynesson1/sentrix/main/src"

-- Set this to your runtime HTTP function.
-- Example: local customHttpGet = HttpGet
local customHttpGet = nil

-- Set this to your runtime compile function.
-- Example: local customCompile = loadstring
local customCompile = loadstring

local function performHttpGet(url)
	if type(customHttpGet) ~= "function" then
		error("customHttpGet is nil. Set it to your runtime HTTP function.")
	end

	local ok, body = pcall(customHttpGet, url)
	if not ok then
		error(("HTTP request failed for %s: %s"):format(url, tostring(body)))
	end

	if type(body) ~= "string" then
		error(("HTTP getter returned non-string body for %s"):format(url))
	end

	return body
end

local function compile(source, chunkName)
	if type(customCompile) ~= "function" then
		error("customCompile is nil. Set it to your runtime compile function.")
	end

	local fn, err = customCompile(source, chunkName)
	if not fn then
		error(("compile failed: %s"):format(tostring(err)))
	end

	return fn
end

local function normalizePath(path)
	return (path:gsub("^src/", ""))
end

local function fetchModule(path)
	local rel = normalizePath(path)
	local url = baseUrl .. "/" .. rel
	local source = performHttpGet(url)

	if type(source) ~= "string" then
		error(("http body was not string for %s"):format(url))
	end

	local chunk = compile(source, "@" .. url)
	return chunk()
end

local Menu = fetchModule("core/menu.lua")
local App = fetchModule("core/app.lua")
local Loader = fetchModule("core/loader.lua")
local Main = fetchModule("main.lua")
local manifest = fetchModule("manifest.lua")

-- Runtime adapter stubs: replace with your real input/draw integration.
local input = {
	poll = function()
		return nil
	end,
}

local renderer = {
	render = function(_menu)
		-- Draw your menu here (title/items/selection)
	end,
	renderClosed = function()
		-- Draw hidden state or nothing
	end,
}

local app = Main.build({
	Menu = Menu,
	App = App,
	Loader = Loader,
	input = input,
	renderer = renderer,
	manifest = manifest,
	compile = compile,
	httpGet = function(url)
		return performHttpGet(url)
	end,
	startOpen = true,
	title = "Sentrix Core",
})

-- Call this on your engine tick/update loop.
local function step()
	app:update()
end

return {
	app = app,
	step = step,
}
