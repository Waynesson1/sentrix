--!nocheck

-- This is a template. Adapt `httpGet` and `baseUrl` to your runtime.

local Loader = dofile("src/core/loader.lua")

local loader = Loader.new({
	compile = loadstring,
})

local baseUrl = "https://raw.githubusercontent.com/<user>/<repo>/main/src"

local function httpGet(_url)
	-- Replace this with your engine executor HTTP function.
	-- Example in some runtimes: return game:HttpGet(url)
	error("Provide an httpGet(url) implementation for your runtime")
end

local manifest, manifestErr = loader:loadRemote(baseUrl .. "/manifest.lua", httpGet)
if not manifest then
	error(manifestErr)
end

for _, entry in ipairs(manifest.remotes or {}) do
	local moduleFactory, moduleErr = loader:loadRemote(entry.url, httpGet)
	if not moduleFactory then
		error(moduleErr)
	end

	-- You can store/execute moduleFactory here based on your core runtime.
end
