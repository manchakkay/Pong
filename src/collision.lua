CollisionObject = {}
CollisionObject.__index = CollisionObject

--[[
# Создание объекта коллизии
# Типы объектов:
#    "ball"
        Параметры:
            x, y, radius
#    "rect"
        Параметры:
            x, y, width, height
 --]]
function CollisionObject:create(type, ...)

    local prototype = {}
    local arguments = {...}

    setmetatable(prototype, CollisionObject)

    if (type == "ball") then
        if (arguments[1] ~= nil and arguments[2] ~= nil and arguments[3] ~= nil) then
            prototype.type = "ball"
            prototype.x = arguments[1]
            prototype.y = arguments[2]
            prototype.r = arguments[3]
        end

    elseif (type == "rect") then
        if (arguments[1] ~= nil and arguments[2] ~= nil and arguments[3] ~= nil and
            arguments[4] ~= nil) then
            prototype.type = "rect"
            prototype.x = arguments[1]
            prototype.y = arguments[2]
            prototype.w = arguments[3]
            prototype.h = arguments[4]
        end

    end

    return prototype
end

function CollisionObject:checkCollision(obj)
    -- Если это шар
    if (self.type == "ball") then
        -- Соприкасается с прямоугольником
        if (obj.type == "rect") then
            local checkX = self.x
            local checkY = self.y

            if (self.x < obj.x) then
                checkX = obj.x
            elseif (self.x > obj.x + obj.w) then
                checkX = obj.x + obj.w
            end

            if (self.y < obj.y) then
                checkY = obj.y
            elseif (self.y > obj.y + obj.h) then
                checkY = obj.y + obj.h
            end

            local dx = self.x - checkX
            local dy = self.y - checkY
            local distance = math.sqrt((dx * dx) + (dy * dy))

            if (distance <= self.r) then return true end
            return false
        end
    end
end
