-- Библиотеки
require "src.libs.logger"
require "src.libs.ui"
require "src.libs.queue"
-- Игровые файлы
require "src.collision"
require "src.pong"

-- Настройки отладчика
loggerConfig = {
    bouncing =  false,
    trace =     false,
    queue =     false,
}

-- Настройки игры
gameConfig = {
    metainfo = {
        version_code = "0.2 RC",
        author = "Manchakkay Maxim"
    },

    paddleSpeed = 15,
    paddleAcceleration = 1.5,
    paddleBraking = 1.5,
    paddleWidth = 10,
    paddleHeight = 150,

    ballRadius = 14,
    ballStartSpeed = 10,
    ballAcceleration = 0.0025,

    anglePower = 0.075,

    enemyDelay = 5,
}

function love.load()
    -- Полноэкранный режим и цвет фона
    love.window.setFullscreen(true)
    love.graphics.setBackgroundColor(0 / 255, 0 / 255, 0 / 255)

    -- Получение размеров окна
    windowWidth = love.graphics.getWidth()
    windowHeight = love.graphics.getHeight()

    -- Установка настроек игры
    love.math.setRandomSeed(love.timer.getTime())

    -- Создание инстанции игры
    game = PongGame:create{
        config = gameConfig
    }
end

function love.draw()
    UI.cursorRequired = false
    game:draw() 
    UI.cursorCheck()
end

function love.update() 
    game:keyCheck()
    game:update()
end

function love.mousepressed( x, y, button )
    game:mouseClick()
end

function love.resize()
    windowWidth = love.graphics.getWidth()
    windowHeight = love.graphics.getHeight()
end