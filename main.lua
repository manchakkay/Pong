require "src.collision"
require "src.pong"
require "src.ui"

function love.load()
    -- Полноэкранный режим и цвет фона
    love.window.setFullscreen(true)
    love.graphics.setBackgroundColor(0 / 255, 0 / 255, 0 / 255)

    -- Получение размеров окна
    windowWidth = love.graphics.getWidth()
    windowHeight = love.graphics.getHeight()

    -- Установка настроек игры
    love.math.setRandomSeed(love.timer.getTime())
    gameConfig = {
        paddleSpeed = 10,
        paddleWidth = 10,
        paddleHeight = 100,

        ballRadius = 10,
        ballStartSpeed = 10,
        ballAcceleration = 0.001
    }

    -- Создание инстанции игры
    game = PongGame:create{
        config = gameConfig
    }
end

function love.draw()
    ui.cursorRequired = false
    game:draw() 
    ui.cursorCheck()
end

function love.update( dt ) 
    game:keyCheck(dt)
    game:update(dt)
end

function love.mousepressed( x, y, button )
    game:mouseClick()
end

function love.resize()
    windowWidth = love.graphics.getWidth()
    windowHeight = love.graphics.getHeight()
end