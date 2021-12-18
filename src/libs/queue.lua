Queue2D = {}
Queue2D.__index = Queue2D

-- Очередь из координат 
function Queue2D:create( arguments ) 
    
    local prototype = {}
    setmetatable(prototype, Queue2D)

    prototype.length = arguments.length or 10
    prototype.startX = arguments.startX or 0
    prototype.startY = arguments.startY or 0

    prototype.queue = {}

    for index = 1, prototype.length do
        prototype.queue[index] = {
            x = prototype.startX, 
            y = prototype.startY
        }
    end

    return prototype

end

function Queue2D:reset()

    for index = 1, self.length do
        self.queue[index] = {
            x = self.startX, 
            y = self.startY
        }
    end

end

function Queue2D:add(valueX, valueY)

    for index = 1, self.length do
        self.queue[self.length-index+1] = self.queue[self.length-index] 
    end

    self.queue[1] = {x = valueX, y = valueY}
    
end

function Queue2D:__tostring()
    local result = "(" .. self.length .. ": "

    for index = 1, self.length do
        result = result .. "[" .. self.queue[index].x .. ":" .. self.queue[index].y .. "] "
    end

    result = result .. ")"

    return result
end
