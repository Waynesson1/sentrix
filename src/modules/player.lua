return function(menuFactory)
	local playerMenu = menuFactory({
		id = "player",
		title = "Player",
	})

	local godMode = false
	local speed = 16

	playerMenu:addItem({
		label = "God Mode",
		getValue = function()
			return godMode and "ON" or "OFF"
		end,
		onSelect = function()
			godMode = not godMode
		end,
	})

	playerMenu:addItem({
		label = "Walk Speed",
		getValue = function()
			return tostring(speed)
		end,
		onLeft = function()
			speed = math.max(1, speed - 1)
		end,
		onRight = function()
			speed = math.min(100, speed + 1)
		end,
	})

	return playerMenu
end
