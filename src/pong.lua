PongGame = {}
PongGame.__index = PongGame

--[[
    Создание объекта игры
    Режимы игры:
        Название параметра: mode

        "pve"
            Игрок против компьютера
                левой доской управляет игрок (стрелочки / WASD), правой компьютер
        "pvp"
            Игрок против игрока
                левой доской управляет первый игрок (WASD), правой второй игрок (стрелочка)
 --]]
function PongGame:create( arguments )

    local prototype = {}
    setmetatable(prototype, PongGame)

    -- Настройки игры
    prototype.config = arguments.config
    
    -- Создание объектов
    prototype.ballObject = CollisionObject:create{ 
        type = "ball", 
        startX = (windowWidth / 2), 
        startY = (windowHeight / 2), 
        radius = prototype.config.ballRadius,
    }
    prototype.paddleLObject = CollisionObject:create{
        type = "rect",
        startX = 50,
        startY = (windowHeight / 2) - (prototype.config.paddleHeight / 2),
        width = prototype.config.paddleWidth,
        height = prototype.config.paddleHeight,
    }
    prototype.paddleRObject = CollisionObject:create{
        type = "rect", 
        startX = (windowWidth - prototype.config.paddleWidth) - 50, 
        startY = (windowHeight / 2) - (prototype.config.paddleHeight / 2), 
        width = prototype.config.paddleWidth,                   
        height = prototype.config.paddleHeight,
    }
    prototype.ballTracer = Queue2D:create{
        startX = (windowWidth / 2),
        startY = (windowHeight / 2),
        length = prototype.config.enemyDelay,
    }

    -- Скорости
    prototype.ballSpeed = {x, y, a}
    prototype.ballGhost = {x, y}
    prototype.paddleBusy = {
        l = false, 
        r = false
    }
    prototype.paddleVelocities = {
        l = {
            v = 0,
            a = 0,
            active = false
        },
        r = {
            v = 0,
            a = 0,
            active = false
        }
    }

    prototype.paddleSpeed = prototype.config.paddleSpeed
    prototype.paddleAcceleration = prototype.config.paddleAcceleration
    prototype.paddleBraking = prototype.config.paddleBraking

    -- Настройки игры
    prototype.gameMode = "menu"
    prototype.scoreL = 0
    prototype.scoreR = 0
    
    -- Элементы интерфейса
    prototype.buttons = {}

    return prototype
end

-- Функция запуска следующего раунда
function PongGame:nextRound(winner)

    -- Рассчёт очков и определение победителя
    if (winner == "L") then
        self.scoreL = self.scoreL + 1       
    elseif (winner == "R") then
        self.scoreR = self.scoreR + 1
    end

    if (self.scoreL >= 9 or self.scoreR >= 9) then
        if (self.gameMode == "game-2P") then
            self.gameMode = "end-2P"
        elseif (self.gameMode == "game-1P") then
            self.gameMode = "end-1P"
        end
    end

    -- Установка координат
    self.ballObject.x = (windowWidth / 2) 
    self.ballObject.y = (windowHeight / 2) 
    -- Установка скоростей
    self.ballSpeed.x = self.config.ballStartSpeed * ( (love.math.random() > 0.5) and 1 or -1)
    self.ballSpeed.y = self.config.ballStartSpeed * (love.math.random() - 0.5) * 2
    self.ballSpeed.a = self.config.ballAcceleration
    
end

-- Обновление объектов игры
function PongGame:update()
    if (self.gameMode == "game-2P" or self.gameMode == "game-1P") then
        self.ballObject.x = self.ballObject.x + self.ballSpeed.x
        self.ballObject.y = self.ballObject.y + self.ballSpeed.y
        
        if (self.ballSpeed.x > 0) then
            self.ballSpeed.x = self.ballSpeed.x + self.ballSpeed.a
        else
            self.ballSpeed.x = self.ballSpeed.x + self.ballSpeed.a * -1
        end

        if (self.ballSpeed.y > 0) then
            self.ballSpeed.y = self.ballSpeed.y + self.ballSpeed.a 
        else
            self.ballSpeed.y = self.ballSpeed.y + self.ballSpeed.a  * -1
        end

        self.ballTracer:add(self.ballObject.x, self.ballObject.y)

    end

    if (self.gameMode == "game-1P") then
        if (self.ballObject.x > windowWidth/2) then
            local delayed1 = self.ballTracer.queue[self.config.enemyDelay]
            local delayed2 = self.ballTracer.queue[self.config.enemyDelay-1]

            Log.print("trace", self.ballTracer)
            local diffY = (delayed2.y - delayed1.y)
            local predictionY = self.ballTracer.queue[1].y + (self.config.enemyDelay * diffY)
            Log.print("queue", predictionY)

            if (predictionY > self.paddleRObject.y) then
                self:move("R", "down")
            elseif (predictionY < self.paddleRObject.y) then
                self:move("R", "up")
            end
        end
    end

    self:checkCollisions()
    self:checkBoundaries()
    
    self:braking()
end


function PongGame:braking()

    -- Торможение левого
    if (self.paddleVelocities.l.active == true) then
        self.paddleVelocities.l.active = false
    else
        if (self.paddleVelocities.l.v > 0) then
            self.paddleVelocities.l.v = self.paddleVelocities.l.v - self.paddleBraking

            if (self.paddleVelocities.l.v < 0) then
                self.paddleVelocities.l.v = 0
            end
        elseif (self.paddleVelocities.l.v < 0) then
            self.paddleVelocities.l.v = self.paddleVelocities.l.v + self.paddleBraking

            if (self.paddleVelocities.l.v > 0) then
                self.paddleVelocities.l.v = 0
            end
        end
    end

    -- Торможение правого
    if (self.paddleVelocities.r.active == true) then
        self.paddleVelocities.r.active = false
    else
        if (self.paddleVelocities.r.v > 0) then
            self.paddleVelocities.r.v = self.paddleVelocities.r.v - self.paddleBraking

            if (self.paddleVelocities.r.v < 0) then
                self.paddleVelocities.r.v = 0
            end
        elseif (self.paddleVelocities.r.v < 0) then
            self.paddleVelocities.r.v = self.paddleVelocities.r.v + self.paddleBraking

            if (self.paddleVelocities.r.v > 0) then
                self.paddleVelocities.r.v = 0
            end
        end
    end

    if (self.paddleVelocities.r.v > self.paddleSpeed) then
        self.paddleVelocities.r.v = self.paddleSpeed
    elseif (self.paddleVelocities.r.v < self.paddleSpeed*-1) then
        self.paddleVelocities.r.v = self.paddleSpeed*-1
    end

    if (self.paddleVelocities.l.v > self.paddleSpeed) then
        self.paddleVelocities.l.v = self.paddleSpeed
    elseif (self.paddleVelocities.l.v < self.paddleSpeed*-1) then
        self.paddleVelocities.l.v = self.paddleSpeed*-1
    end
    
end

function PongGame:move( paddle, direction )
    --[[ 

    Функция движения курков
    Параметры: 
        dt, paddle, direction

    ]]

    if (paddle == "L") then
        -- Левый курок
        self.paddleVelocities.l.active = true

        if (direction == "up") then
            if (self.paddleLObject.y >= 0) then
                self.paddleVelocities.l.a = self.paddleAcceleration * -1
                self.paddleVelocities.l.v = self.paddleVelocities.l.v + self.paddleVelocities.l.a
            else
                self.paddleVelocities.l.v = 0
                self.paddleVelocities.l.a = 0
            end
        elseif (direction == "down") then
            if (self.paddleLObject.y <= windowHeight - self.config.paddleHeight) then
                self.paddleVelocities.l.a = self.paddleAcceleration
                self.paddleVelocities.l.v = self.paddleVelocities.l.v + self.paddleVelocities.l.a
            else
                self.paddleVelocities.l.v = 0
                self.paddleVelocities.l.a = 0
            end
        end

        self.paddleLObject.y = self.paddleLObject.y + self.paddleVelocities.l.v
        
    elseif (paddle == "R") then
        -- Правый курок
        self.paddleVelocities.r.active = true

        if (direction == "up") then
            if (self.paddleRObject.y >= 0) then
                self.paddleVelocities.r.a = self.paddleAcceleration * -1
                self.paddleVelocities.r.v = self.paddleVelocities.r.v + self.paddleVelocities.r.a
            else
                self.paddleVelocities.r.v = 0
                self.paddleVelocities.r.a = 0
            end

        elseif (direction == "down") then
            if (self.paddleRObject.y <= windowHeight - self.config.paddleHeight) then
                self.paddleVelocities.r.a = self.paddleAcceleration
                self.paddleVelocities.r.v = self.paddleVelocities.r.v + self.paddleVelocities.r.a
            else
                self.paddleVelocities.r.v = 0
                self.paddleVelocities.r.a = 0
            end
        end
        
        self.paddleRObject.y = self.paddleRObject.y + self.paddleVelocities.r.v
    end

end

-- Триггер нажатия клавиши мыши
function PongGame:mouseClick()
    if (self.gameMode == "menu") then
        -- -- -- РЕЖИМ МЕНЮ -- -- --
        
        if (UI.mouseInsideRect(self.buttons["start1P"])) then
            -- Кнопка: Игра с компьютером
            self.gameMode = "game-1P"

            self:nextRound()

        elseif (UI.mouseInsideRect(self.buttons["start2P"])) then
            -- Кнопка: Игра с другим игроком
            self.gameMode = "game-2P"

            self:nextRound()

        elseif (UI.mouseInsideRect(self.buttons["exit"])) then
            -- Кнопка: Выйти из игры
            love.event.quit()

        end
    elseif (self.gameMode == "end-2P") then
        -- -- -- РЕЖИМ ОКОНЧАНИЮ ИГРЫ 1 на 1 -- -- --
        
        if (UI.mouseInsideRect(self.buttons["menu"])) then
            -- Кнопка: Выход в меню

            self.scoreL = 0
            self.scoreR = 0
            self.paddleLObject.y = (windowHeight / 2) - (self.config.paddleHeight / 2)
            self.paddleRObject.y = (windowHeight / 2) - (self.config.paddleHeight / 2)

            self:nextRound()

            self.gameMode = "menu"

        elseif (UI.mouseInsideRect(self.buttons["start2P"])) then
            -- Кнопка: Рестарт

            self.scoreL = 0
            self.scoreR = 0
            self.paddleLObject.y = (windowHeight / 2) - (self.config.paddleHeight / 2)
            self.paddleRObject.y = (windowHeight / 2) - (self.config.paddleHeight / 2)

            self:nextRound()

            self.gameMode = "game-2P"

            
        end
    elseif (self.gameMode == "end-1P") then
        -- -- -- РЕЖИМ ОКОНЧАНИЮ ИГРЫ 1 на 1 -- -- --
        
        if (UI.mouseInsideRect(self.buttons["menu"])) then
            -- Кнопка: Выход в меню

            self.scoreL = 0
            self.scoreR = 0
            self.paddleLObject.y = (windowHeight / 2) - (self.config.paddleHeight / 2)
            self.paddleRObject.y = (windowHeight / 2) - (self.config.paddleHeight / 2)

            self:nextRound()

            self.gameMode = "menu"

        elseif (UI.mouseInsideRect(self.buttons["start1P"])) then
            -- Кнопка: Рестарт

            self.scoreL = 0
            self.scoreR = 0
            self.paddleLObject.y = (windowHeight / 2) - (self.config.paddleHeight / 2)
            self.paddleRObject.y = (windowHeight / 2) - (self.config.paddleHeight / 2)

            self:nextRound()

            self.gameMode = "game-1P"

            
        end
    end
end


function PongGame:draw()
    -- Отрисовка

    if (self.gameMode == "game-2P") then

        -- -- -- РЕЖИМ МУЛЬТИПЛЕЕРА -- -- --

        -- Рисуем мяч
        love.graphics.setColor(255 / 255, 255 / 255, 255 / 255)
        love.graphics.circle("fill", self.ballObject.x, self.ballObject.y, self.ballObject.r)

        -- Рисуем игроков
        love.graphics.setColor(255 / 255, 255 / 255, 255 / 255)
        love.graphics.rectangle("fill", self.paddleLObject.x, self.paddleLObject.y, self.paddleLObject.w, self.paddleLObject.h)
        love.graphics.rectangle("fill", self.paddleRObject.x, self.paddleRObject.y, self.paddleRObject.w, self.paddleRObject.h)

        -- Счёт игры
        UI.text{
            x = windowWidth / 2, 
            y = 72, 
            text = self.scoreL .. " : " .. self.scoreR, 
            font = "EXTRABOLD48", 
            color = "ACCENT"
        }
        
    elseif (self.gameMode == "game-1P") then

        -- -- -- РЕЖИМ ОДИНОЧНЫЙ ИГРЫ -- -- --

        -- Рисуем мяч
        love.graphics.setColor(255 / 255, 255 / 255, 255 / 255)
        love.graphics.circle("fill", self.ballObject.x, self.ballObject.y, self.ballObject.r)

        -- Рисуем игроков
        love.graphics.setColor(255 / 255, 255 / 255, 255 / 255)
        love.graphics.rectangle("fill", self.paddleLObject.x, self.paddleLObject.y, self.paddleLObject.w, self.paddleLObject.h)
        love.graphics.setColor(255 / 255, 60 / 255, 40 / 255)
        love.graphics.rectangle("fill", self.paddleRObject.x, self.paddleRObject.y, self.paddleRObject.w, self.paddleRObject.h)

        -- Счёт игры
        UI.text{
            x = windowWidth / 2, 
            y = 72, 
            text = self.scoreL .. " : " .. self.scoreR, 
            font = "EXTRABOLD48", 
            color = "ACCENT"
        }

    elseif (self.gameMode == "menu") then
        -- -- -- РЕЖИМ МЕНЮ -- -- --

        -- Рисуем логотип
        UI.text{
            x = windowWidth / 2, 
            y = windowHeight / 2 - 128, 
            text = "P O N G", 
            font = "BOLD160", 
            color = "ACCENT"
        }
        -- Мета-информация
        UI.text{
            x = windowWidth / 2, 
            y = windowHeight - 64, 
            text = self.config.metainfo.version_code, 
            font = "MEDIUM16", 
            color = "GRAY"
        }
        UI.text{
            x = windowWidth / 2, 
            y = windowHeight - 96, 
            text = self.config.metainfo.author, 
            font = "MEDIUM16", 
            color = "GRAY"
        }

        -- Получаем зоны для нажатия на кнопки

        -- Одиночная игра
        self.buttons["start1P"] = UI.text{
            x = windowWidth / 2, 
            y = windowHeight / 2 + 64, 
            text = "Игра с компьютером", 
            font = "BOLD24",
            colorIdle = "WHITE",
            colorHover = "GRAY",
            clickable = true,
        }
        -- -- Мультиплеер
        self.buttons["start2P"] = UI.text{
            x = windowWidth / 2, 
            y = windowHeight / 2 + 140, 
            text = "Игра с другим игроком", 
            font = "BOLD24",
            colorIdle = "WHITE",
            colorHover = "GRAY",
            clickable = true,
        }
        -- Выход из игры
        self.buttons["exit"] = UI.text{
            x = windowWidth / 2, 
            y = windowHeight / 2 + 216, 
            text = "Выйти из игры", 
            font = "BOLD24",
            colorIdle = "WHITE",
            colorHover = "GRAY",
            clickable = true,
        }
        

    elseif (self.gameMode == "end-2P") then
        -- -- -- РЕЖИМ МЕНЮ -- -- --


        -- Выводим победителя
        local tempText

        if (self.scoreL > self.scoreR) then
            tempText = "PLAYER 1"
        else
            tempText = "PLAYER 2"
        end

        UI.text{
            x = windowWidth / 2, 
            y = windowHeight / 2 - 256, 
            text = tempText .. " WINS!", 
            font = "BOLD160", 
            color = "ACCENT"
        }

        UI.text{
            x = windowWidth / 2, 
            y = windowHeight / 2 - 108, 
            text = self.scoreL .. " : " .. self.scoreR, 
            font = "EXTRABOLD48", 
            color = "GRAY"
        }

        -- Получаем зоны для нажатия на кнопки

        -- Рестарт
        self.buttons["start2P"] = UI.text{
            x = windowWidth / 2, 
            y = windowHeight / 2 + 88, 
            text = "Начать новую игру", 
            font = "BOLD24",
            colorIdle = "WHITE",
            colorHover = "GRAY",
            clickable = true,
            
        }
        -- Выход в меню
        self.buttons["menu"] = UI.text{
            x = windowWidth / 2, 
            y = windowHeight / 2 + 164, 
            text = "Выйти в главное меню", 
            font = "BOLD24",
            colorIdle = "WHITE",
            colorHover = "GRAY",
            clickable = true,
        }
    
    elseif (self.gameMode == "end-1P") then
        -- -- -- РЕЖИМ МЕНЮ -- -- --


        -- Выводим победителя
        local tempText, tempColor

        if (self.scoreL > self.scoreR) then
            tempText = "PLAYER" 
            tempColor = "ACCENT"
        else
            tempText = "COMPUTER"
            tempColor = "RED"
        end

        UI.text{
            x = windowWidth / 2, 
            y = windowHeight / 2 - 256, 
            text = tempText .. " WINS!", 
            font = "BOLD160", 
            color = tempColor
        }

        UI.text{
            x = windowWidth / 2, 
            y = windowHeight / 2 - 108, 
            text = self.scoreL .. " : " .. self.scoreR, 
            font = "EXTRABOLD48", 
            color = "GRAY"
        }

        -- Получаем зоны для нажатия на кнопки

        -- Рестарт
        self.buttons["start1P"] = UI.text{
            x = windowWidth / 2, 
            y = windowHeight / 2 + 88, 
            text = "Начать новую игру", 
            font = "BOLD24",
            colorIdle = "WHITE",
            colorHover = "GRAY",
            clickable = true,
            
        }
        -- Выход в меню
        self.buttons["menu"] = UI.text{
            x = windowWidth / 2, 
            y = windowHeight / 2 + 164, 
            text = "Выйти в главное меню", 
            font = "BOLD24",
            colorIdle = "WHITE",
            colorHover = "GRAY",
            clickable = true,
        }
    
    
    end
end


function PongGame:keyCheck()
    -- Проверка зажатия кнопки на клавиатуре
    
    if (self.gameMode == "game-1P") then
        -- Одиночная игра
        
        if (love.keyboard.isDown("escape")) then
            -- Выйти в меню

            self.scoreL = 0
            self.scoreR = 0
            self.paddleLObject.y = (windowHeight / 2) - (self.config.paddleHeight / 2)
            self.paddleRObject.y = (windowHeight / 2) - (self.config.paddleHeight / 2)

            self:nextRound()

            self.gameMode = "menu"
        end

        if (love.keyboard.isDown("w") or love.keyboard.isDown("up")) then
            -- Вверх
            self:move("L", "up")
        elseif (love.keyboard.isDown("s") or love.keyboard.isDown("down")) then
            -- Вниз
            self:move("L", "down")
        end

    elseif (self.gameMode == "game-2P") then
        -- Мультиплеер

        if (love.keyboard.isDown("escape")) then
            -- Выйти в меню

            self.scoreL = 0
            self.scoreR = 0
            self.paddleLObject.y = (windowHeight / 2) - (self.config.paddleHeight / 2)
            self.paddleRObject.y = (windowHeight / 2) - (self.config.paddleHeight / 2)

            self:nextRound()

            self.gameMode = "menu"
        end

        if (love.keyboard.isDown("w")) then
            -- Вверх Левый
            self:move("L", "up")
        elseif (love.keyboard.isDown("s")) then
            -- Вниз Левый
            self:move("L", "down")
        end

        if (love.keyboard.isDown("up") or love.keyboard.isDown("pageup")) then
            -- Вверх Правый
            self:move("R", "up")
        elseif (love.keyboard.isDown("down") or love.keyboard.isDown("pagedown")) then
            -- Вниз Правый
            self:move("R", "down")
        end
    end
end

function PongGame:checkBoundaries()
    -- Проверка столкновения мяча с краями экрана

    if (self.ballObject.x > windowWidth - self.ballObject.r) then 
        self:nextRound("L")
    elseif self.ballObject.x < self.ballObject.r then 
        self:nextRound("R")
    end

    if (self.ballObject.y > windowHeight - self.ballObject.r) then 

        self.ballObject.y = windowHeight - self.ballObject.r
        self.ballSpeed.y = -1 * self.ballSpeed.y
    
    elseif self.ballObject.y < self.ballObject.r then 
    
        self.ballObject.y = self.ballObject.r
        self.ballSpeed.y = -1 * self.ballSpeed.y
    
    end
end

function PongGame:checkCollisions()
    -- Проверка столкновения мяча с игровыми курками

    local collisionL = self.ballObject:checkCollision(self.paddleLObject)
    local collisionR = self.ballObject:checkCollision(self.paddleRObject)

    if (self.paddleBusy.l == false and collisionL.success) then

        -- БЛОКИРОВКА КУРКА ДЛЯ МНОГОПОТОЧНОСТИ
        self.paddleBusy.l = true

        -- Рассчитываем угол мяча относительно курка и вектор движения

        local ballPaddleAngle = math.atan2(
            self.paddleLObject.y+(self.paddleLObject.h/2) - self.ballObject.y, 
            self.paddleLObject.x+(self.paddleLObject.w/2) - self.ballObject.x) * (180.0 / math.pi)

        local ballMovement = self:getBallDirection()

        Log.print("bouncing", "[L]ANGLE START: " .. ballMovement.angle)
        Log.print("bouncing", "[L]ANGLE PADDLE: " .. ballPaddleAngle)

        -- Отодвигаем мяч от курка
        self.ballObject.x = self.ballGhost.x
        self.ballObject.y = self.ballGhost.y

        -- Рассчитываем вектор отскока
        if (collisionL.rectSide == "left" or collisionL.rectSide == "right") then
            ballMovement = self:getBallDirection("x")
        elseif (collisionL.rectSide == "top" or collisionL.rectSide == "bottom") then
            ballMovement = self:getBallDirection("y")
        end
        
        Log.print("bouncing", "[L]ANGLE MIDDLE: " .. ballMovement.angle)

        local changeAngle = -1 * (ballPaddleAngle/ballPaddleAngle) * (math.abs( ballPaddleAngle ) - 180);
        local newAngle = (ballMovement.angle * (1-self.config.anglePower) + changeAngle * self.config.anglePower)
        
        Log.print("bouncing", "[R]ANGLE CHANGE: " .. tostring(changeAngle))
        if (newAngle < -90 and newAngle >= -180) then
            newAngle = -80
            Log.print("bouncing", "[L]FIX-")
        elseif (newAngle > 90 and newAngle <= 180) then
            newAngle = 80
            Log.print("bouncing", "[L]FIX+")
        end
        -- Рассчитываем финальный вектор движения мяча
        local newSpeed = lengthDir(ballMovement.speed, newAngle)

        -- Устанавливаем скорость мяча после отскока
        self.ballSpeed.x = newSpeed.x
        self.ballSpeed.y = newSpeed.y

        Log.print("bouncing", "[L]ANGLE END: " .. newAngle)

        -- РАЗБЛОКИРОВКА КУРКА ДЛЯ МНОГОПОТОЧНОСТИ
        self.paddleBusy.l = false

    elseif (self.paddleBusy.r == false and collisionR.success) then

        -- БЛОКИРОВКА КУРКА ДЛЯ МНОГОПОТОЧНОСТИ
        self.paddleBusy.r = true

        -- Рассчитываем угол мяча относительно курка и вектор движения
    
        local ballPaddleAngle = math.atan2(
            self.paddleRObject.y+(self.paddleRObject.h/2) - self.ballObject.y, 
            self.paddleRObject.x+(self.paddleRObject.w/2) - self.ballObject.x) * (180.0 / math.pi)

        local ballMovement = self:getBallDirection()

        Log.print("bouncing", "[R]ANGLE START: " .. ballMovement.angle)
        Log.print("bouncing", "[R]ANGLE PADDLE: " .. ballPaddleAngle)

        -- Отодвигаем мяч от курка
        self.ballObject.x = self.ballGhost.x
        self.ballObject.y = self.ballGhost.y

        -- Рассчитываем вектор отскока
        if (collisionR.rectSide == "left" or collisionR.rectSide == "right") then
            ballMovement = self:getBallDirection("x")
        elseif (collisionR.rectSide == "top" or collisionR.rectSide == "bottom") then
            ballMovement = self:getBallDirection("y")
        end
        
        Log.print("bouncing", "[R]ANGLE MIDDLE: " .. ballMovement.angle)
        
        -- Рассчитываем дополнительное смещение вектора относительно курка
        local changeAngle = ballPaddleAngle

        Log.print("bouncing", "[R]ANGLE CHANGE: " .. changeAngle)
        local newAngle = (ballMovement.angle * (1-self.config.anglePower) + changeAngle * self.config.anglePower)
        if (newAngle < 0 and newAngle >= -90) then
            newAngle = -100
            Log.print("bouncing", "[R]FIX-")
        elseif (newAngle > 0 and newAngle <= 90) then
            newAngle = 100
            Log.print("bouncing", "[R]FIX+")
        end
        -- Рассчитываем финальный вектор движения мяча
        local newSpeed = lengthDir(ballMovement.speed, newAngle)

        -- Устанавливаем скорость мяча после отскока
        self.ballSpeed.x = newSpeed.x
        self.ballSpeed.y = newSpeed.y

        Log.print("bouncing", "[R]ANGLE END: " .. newAngle)

        -- РАЗБЛОКИРОВКА КУРКА ДЛЯ МНОГОПОТОЧНОСТИ
        self.paddleBusy.r = false

    elseif (self.paddleBusy.r == false and self.paddleBusy.l == false) then

        self.ballGhost.x = self.ballObject.x
        self.ballGhost.y = self.ballObject.y
    
    end
    --[[

          Ball movement

      45        90         135
                 |
                 |
      0  ----------------- 180
                 |
                 |
      -45       -90       -135

               
          Paddle to ball

     45        90         135
                |
                |
    0   ----------------- 180
                |
                |
    -45        -90        -135

    ]] 
end

function PongGame:getBallDirection(bounceAxis)

    local newSpeed = {x, y}

    if (bounceAxis ~= nil) then
        if (bounceAxis == "y") then
            newSpeed.x = self.ballSpeed.x
            newSpeed.y = self.ballSpeed.y * -1
        else
            newSpeed.x = self.ballSpeed.x * -1
            newSpeed.y = self.ballSpeed.y
        end
    else 
        newSpeed.x = self.ballSpeed.x
        newSpeed.y = self.ballSpeed.y
    end

    local speed = math.sqrt(math.pow(newSpeed.x, 2) + math.pow(newSpeed.y, 2))

    return {
        angle = math.atan2(newSpeed.y, newSpeed.x) * (180.0 / math.pi),
        speedX = newSpeed.x,
        speedY = newSpeed.y,
        speed = speed
    }

end

function lengthDir(speed, angle)
    return {
        x = math.cos(angle * math.pi / 180) * speed,
        y = math.sin(angle * math.pi / 180) * speed
    }
end


