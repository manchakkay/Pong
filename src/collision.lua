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
    local result = {
        success = false,
        rectSide = "none",
        type = "none"
    }
    -- Если это шар
    if (self.type == "ball") then
        -- Соприкасается с прямоугольником
        if (obj.type == "rect") then
            local checkX = self.x
            local checkY = self.y

            local sideX = "noneX"
            if (self.x < obj.x) then
                checkX = obj.x
                sideX = "left"
            elseif (self.x > obj.x + obj.w) then
                checkX = obj.x + obj.w
                sideX = "right"
            end

            local sideY = "noneY"
            if (self.y < obj.y) then
                checkY = obj.y
                sideY = "top"
            elseif (self.y > obj.y + obj.h) then
                checkY = obj.y + obj.h
                sideY = "bottom"
            end

            local dx = math.abs(self.x - checkX)
            local dy = math.abs(self.y - checkY)
            local distance = math.sqrt((dx * dx) + (dy * dy))

            if (distance <= self.r) then
                -- Стандартный удар ближе к углу

                result.success = true
                result.type = "corner"

                if (dx >= dy) then
                    result.rectSide = sideX
                else
                    result.rectSide = sideY
                end

            else
                -- Удары о центр стороны

                if ((self.y <= obj.y + obj.h) and (self.y >= obj.y)) then
                    if ((sideX == "right") and (self.x-self.r <= checkX)) or ((sideX == "left") and (self.x-self.r >= checkX)) then
                        result.success = true
                        result.type = "side"
                        result.rectSide = sideX
                    end
                elseif ((self.x <= obj.x + obj.w) and (self.x >= obj.x)) then
                    if ((sideY == "bottom") and (self.y-self.r <= checkY)) or ((sideY == "top") and (self.y-self.r >= checkY)) then
                        result.success = true
                        result.type = "side"
                        result.rectSide = sideY
                    end
                end

            end
        end
    end

    return result
end
