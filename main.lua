require("src.collision")

function love.load()
    love.graphics.setBackgroundColor(20 / 255, 20 / 255, 20 / 255)
    ball = CollisionObject:create("ball", 10, 20, 30)
end
