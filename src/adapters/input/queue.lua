local QueueInput = {}
QueueInput.__index = QueueInput

function QueueInput.new()
	return setmetatable({
		queue = {},
	}, QueueInput)
end

function QueueInput:push(action)
	self.queue[#self.queue + 1] = action
end

function QueueInput:poll()
	if #self.queue == 0 then
		return nil
	end

	local action = self.queue[1]
	table.remove(self.queue, 1)
	return action
end

return QueueInput
