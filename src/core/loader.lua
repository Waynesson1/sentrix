local Loader = {}
Loader.__index = Loader

function Loader.new(opts)
	opts = opts or {}

	return setmetatable({
		environment = opts.environment,
		compile = opts.compile,
		readFile = opts.readFile,
		httpGet = opts.httpGet,
	}, Loader)
end

function Loader:loadSource(source, chunkName)
	local compileFn = self.compile
	if type(compileFn) ~= "function" then
		return nil, "compile function is missing (provide opts.compile, e.g. loadstring)"
	end

	local chunk, compileErr = compileFn(source, chunkName or "=(loader)")
	if not chunk then
		return nil, ("compile failed: %s"):format(tostring(compileErr))
	end

	if self.environment and type(setfenv) == "function" then
		pcall(setfenv, chunk, self.environment)
	end

	local ok, result = pcall(chunk)
	if not ok then
		return nil, ("runtime failed: %s"):format(tostring(result))
	end

	return result
end

function Loader:loadLocal(path, readFile)
	local readFileFn = readFile or self.readFile
	if type(readFileFn) ~= "function" then
		return nil, "readFile function is missing (provide opts.readFile)"
	end

	local ok, sourceOrErr = pcall(readFileFn, path)
	if not ok then
		return nil, ("read failed (%s): %s"):format(path, tostring(sourceOrErr))
	end

	if type(sourceOrErr) ~= "string" then
		return nil, ("readFile did not return source string for %s"):format(path)
	end

	return self:loadSource(sourceOrErr, "@" .. path)
end

function Loader:loadRemote(url, httpGet)
	local httpGetFn = httpGet or self.httpGet
	if type(httpGetFn) ~= "function" then
		return nil, "httpGet function is missing (provide opts.httpGet or arg)"
	end

	local ok, bodyOrErr = pcall(httpGetFn, url)
	if not ok then
		return nil, ("http failed (%s): %s"):format(url, tostring(bodyOrErr))
	end

	if type(bodyOrErr) ~= "string" then
		return nil, ("http body is not a string for %s"):format(url)
	end

	return self:loadSource(bodyOrErr, "@" .. url)
end

function Loader:loadManifest(manifest, adapters)
	assert(type(manifest) == "table", "manifest table is required")

	adapters = adapters or {}

	local loaded = {}

	for _, entry in ipairs(manifest.locals or {}) do
		local result, err = self:loadLocal(entry.path, adapters.readFile)
		if not result then
			return nil, ("local module '%s' failed: %s"):format(entry.name, err)
		end

		loaded[entry.name] = result
	end

	for _, entry in ipairs(manifest.remotes or {}) do
		local result, err = self:loadRemote(entry.url, adapters.httpGet)
		if not result then
			return nil, ("remote module '%s' failed: %s"):format(entry.name, err)
		end

		loaded[entry.name] = result
	end

	return loaded
end

return Loader
