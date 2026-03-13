local App = {}
App.__index = App

local function normalizeActions(polled)
	if polled == nil then
		return {}
	end

	if type(polled) == "table" then
		return polled
	end

	return { polled }
end

function App.new(opts)
	assert(type(opts) == "table", "opts table is required")
	assert(opts.rootMenu, "opts.rootMenu is required")
	assert(opts.input, "opts.input is required")
	assert(opts.renderer, "opts.renderer is required")

	return setmetatable({
		rootMenu = opts.rootMenu,
		currentMenu = opts.rootMenu,
		input = opts.input,
		renderer = opts.renderer,
		isOpen = opts.startOpen ~= false,
		shouldExit = false,
	}, App)
end

function App:toggle()
	self.isOpen = not self.isOpen
end

function App:handleAction(action)
	if action == "exit" then
		self.shouldExit = true
		return
	end

	if action == "toggle" then
		self:toggle()
		return
	end

	if not self.isOpen then
		return
	end

	if action == "up" then
		self.currentMenu:moveUp()
	elseif action == "down" then
		self.currentMenu:moveDown()
	elseif action == "left" or action == "right" then
		self.currentMenu:adjust(action)
	elseif action == "select" then
		self.currentMenu = self.currentMenu:activate()
	elseif action == "back" then
		self.currentMenu = self.currentMenu:back()
	end
end

function App:update()
	local actions = normalizeActions(self.input:poll())

	for _, action in ipairs(actions) do
		self:handleAction(action)
	end

	if self.isOpen then
		self.renderer:render(self.currentMenu)
	else
		self.renderer:renderClosed()
	end
end

return App
