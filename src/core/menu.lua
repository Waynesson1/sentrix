local Menu = {}
Menu.__index = Menu

function Menu.new(opts)
	opts = opts or {}

	return setmetatable({
		id = opts.id or "menu",
		title = opts.title or "Menu",
		items = {},
		index = 1,
		parent = nil,
	}, Menu)
end

function Menu:addItem(item)
	assert(type(item) == "table", "item must be a table")

	if item.submenu and getmetatable(item.submenu) == Menu then
		item.submenu.parent = self
	end

	table.insert(self.items, item)

	if #self.items == 1 then
		self.index = 1
	end

	return self
end

function Menu:getSelectedItem()
	if #self.items == 0 then
		return nil
	end

	return self.items[self.index]
end

function Menu:move(delta)
	local count = #self.items
	if count == 0 then
		return
	end

	self.index = ((self.index - 1 + delta) % count) + 1
end

function Menu:moveUp()
	self:move(-1)
end

function Menu:moveDown()
	self:move(1)
end

function Menu:adjust(direction)
	local item = self:getSelectedItem()
	if not item then
		return
	end

	if direction == "left" and item.onLeft then
		item.onLeft(item)
	elseif direction == "right" and item.onRight then
		item.onRight(item)
	end
end

function Menu:activate()
	local item = self:getSelectedItem()
	if not item then
		return self
	end

	if item.submenu and getmetatable(item.submenu) == Menu then
		return item.submenu
	end

	if item.onSelect then
		item.onSelect(item)
	end

	return self
end

function Menu:back()
	if self.parent then
		return self.parent
	end

	return self
end

function Menu:getRenderableItems()
	local rows = {}

	for i, item in ipairs(self.items) do
		local value = ""

		if item.getValue then
			value = tostring(item.getValue(item) or "")
		elseif item.value ~= nil then
			value = tostring(item.value)
		end

		if item.submenu then
			if value ~= "" then
				value = value .. "  >"
			else
				value = ">"
			end
		end

		rows[#rows + 1] = {
			index = i,
			label = item.label or ("Item " .. i),
			value = value,
			selected = (i == self.index),
		}
	end

	return rows
end

return Menu
