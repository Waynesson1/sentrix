--!nocheck

-- Red-engine style GitHub bootstrap template.
-- Upload repo to GitHub, then set `baseUrl` and `httpGet` below.

local baseUrl = "https://raw.githubusercontent.com/Waynesson1/sentrix/main/src"

local function httpGet(_url)
	-- Replace with your runtime HTTP fetch function.
	-- Must return the response body as a string.
	error("Provide httpGet(url) implementation for your runtime")
end

local function compile(_source, _chunkName)
	-- Replace with your runtime compile function, for example:
	-- local fn, err = loadstring(source, chunkName)
	error("Provide compile(source, chunkName) implementation for your runtime")
end

local function normalizePath(path)
	return (path:gsub("^src/", ""))
end

local function fetchModule(path)
	local rel = normalizePath(path)
	local url = baseUrl .. "/" .. rel
	local source = httpGet(url)

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
		return httpGet(url)
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
