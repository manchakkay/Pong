CollisionObject = {}
CollisionObject.__index = CollisionObject

--[[
    Создание объекта коллизии
    Типы объектов:
        Название параметра: type

        "ball"
            Параметры:
                startX, startY, radius
        "rect"
            Параметры:
                startX, startY, width, height
 --]]
function CollisionObject:create( arguments )

    local prototype = {}

    setmetatable(prototype, CollisionObject)

    if (arguments.type == "ball") then
        if (arguments.startX ~= nil and arguments.startY ~= nil and arguments.radius ~= nil) then
            prototype.type = "ball"
            prototype.x = arguments.startX
            prototype.y = arguments.startY
            prototype.r = arguments.radius
        end

    elseif (arguments.type == "rect") then
        if (arguments.startX ~= nil and arguments.startY ~= nil and arguments.width ~= nil and arguments.height ~= nil) then
            prototype.type = "rect"
            prototype.x = arguments.startX
            prototype.y = arguments.startY
            prototype.w = arguments.width
            prototype.h = arguments.height
        end

    end

    return prototype
end

function CollisionObject:checkCollision( obj )
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

            if (distance <= self.r) then
                return true
            end
        end
    end

    return false
end
