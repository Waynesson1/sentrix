return function(menuFactory)
	local visualsMenu = menuFactory({
		id = "visuals",
		title = "Visuals",
	})

	local esp = false
	local fov = 80

	visualsMenu:addItem({
		label = "ESP",
		getValue = function()
			return esp and "ON" or "OFF"
		end,
		onSelect = function()
			esp = not esp
		end,
	})

	visualsMenu:addItem({
		label = "Field of View",
		getValue = function()
			return tostring(fov)
		end,
		onLeft = function()
			fov = math.max(60, fov - 5)
		end,
		onRight = function()
			fov = math.min(120, fov + 5)
		end,
	})

	return visualsMenu
end
