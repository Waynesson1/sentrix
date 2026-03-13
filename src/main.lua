local Main = {}

function Main.build(runtime)
	assert(type(runtime) == "table", "runtime table is required")
	assert(runtime.Menu and runtime.App and runtime.Loader, "runtime.Menu, runtime.App, runtime.Loader are required")
	assert(runtime.input and runtime.renderer, "runtime.input and runtime.renderer are required")
	assert(runtime.manifest, "runtime.manifest is required")

	local loader = runtime.Loader.new({
		compile = runtime.compile,
		readFile = runtime.readFile,
		httpGet = runtime.httpGet,
		environment = runtime.environment,
	})

	local modules, loadErr = loader:loadManifest(runtime.manifest, {
		readFile = runtime.readFile,
		httpGet = runtime.httpGet,
	})

	if not modules then
		error(loadErr)
	end

	local root = runtime.Menu.new({
		id = "root",
		title = runtime.title or "Sentrix Core",
	})

	local createMenu = runtime.createMenu or function(opts)
		return runtime.Menu.new(opts)
	end

	if modules.playerModule then
		root:addItem({
			label = "Player",
			submenu = modules.playerModule(createMenu),
		})
	end

	if modules.visualsModule then
		root:addItem({
			label = "Visuals",
			submenu = modules.visualsModule(createMenu),
		})
	end

	root:addItem({
		label = "Unload",
		onSelect = function()
			if runtime.onUnload then
				runtime.onUnload()
			end
		end,
	})

	return runtime.App.new({
		rootMenu = root,
		input = runtime.input,
		renderer = runtime.renderer,
		startOpen = runtime.startOpen ~= false,
	})
end

return Main
