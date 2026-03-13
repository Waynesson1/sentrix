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

	local app = nil

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

	local scriptControl = runtime.Menu.new({
		id = "script-control",
		title = "Script Control",
	})

	scriptControl:addItem({
		label = "Suspend",
		getValue = function()
			if app and app.isSuspended then
				return "ON"
			end

			return "OFF"
		end,
		onSelect = function()
			if app then
				app:toggleSuspend()
			end
		end,
	})

	scriptControl:addItem({
		label = "Terminate",
		onSelect = function()
			if app then
				app:terminate("menu-terminate")
			end
		end,
	})

	root:addItem({
		label = "Script Control",
		submenu = scriptControl,
	})

	app = runtime.App.new({
		rootMenu = root,
		input = runtime.input,
		renderer = runtime.renderer,
		startOpen = runtime.startOpen ~= false,
		onTerminate = runtime.onUnload,
	})

	return app
end

return Main
