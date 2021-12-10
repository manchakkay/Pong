ui = {
    -- Константы с цветами
    COLORS = { 
        BLACK =     { r = 0,    g = 0,      b = 0 }, 
        GRAY =      { r = 100,  g = 100,    b = 100 }, 
        WHITE =     { r = 255,  g = 255,    b = 255 }, 
        ACCENT =    { r = 205,  g = 198,    b = 131 }
    },
    -- Константы со шрифтами
    FONTS = {
        -- Кегль: 16
        MEDIUM16 = love.graphics.newFont("assets/fonts/Manrope-Medium.ttf", 16, "light", love.graphics.getDPIScale()),
        -- Кегль: 24
        REGULAR24 = love.graphics.newFont("assets/fonts/Manrope-Regular.ttf", 24, "light", love.graphics.getDPIScale()),
        BOLD24 = love.graphics.newFont("assets/fonts/Manrope-Bold.ttf", 24, "light", love.graphics.getDPIScale()),
        -- Кегль: 48
        EXTRABOLD48 = love.graphics.newFont("assets/fonts/Manrope-ExtraBold.ttf", 48, "light", love.graphics.getDPIScale()),
        -- Кегль: 160
        LIGHT160 = love.graphics.newFont("assets/fonts/Manrope-Light.ttf", 160, "light", love.graphics.getDPIScale()),
        BOLD160 = love.graphics.newFont("assets/fonts/Manrope-Bold.ttf", 160, "light", love.graphics.getDPIScale()),
    },

    --[[ 
        Рисует центрированный текст

        Аргументы:
        x, y, text, font, colorIdle, colorHover
    ]]
    text = function( arguments )

        local font = ui.FONTS[arguments.font]
        local color;

        local textWidth = font:getWidth(arguments.text)
        local textHeight = font:getHeight()
        local rect = { x = arguments.x - textWidth, y = arguments.y - textHeight, w = textWidth * 2, h = textHeight * 2 }

        if (arguments.clickable == true and ui.mouseInsideRect(rect)) then
            color = ui.COLORS[arguments.colorHover]
            ui.cursorRequired = true
            ui.cursorMode = arguments.cursor or "hand"
        else
            color = ui.COLORS[arguments.color or arguments.colorIdle]
        end

        love.graphics.setFont(font)
        love.graphics.setColor(color["r"] / 255, color["g"] / 255, color["b"] / 255)
        love.graphics.print(arguments.text, arguments.x, arguments.y, 0, 1, 1, textWidth / 2, textHeight / 2)

        return rect

    end,

    --[[ 
        Проверяем попадание курсора в прямоугольник

        Аргументы:
        rect = {x,y,w,h}
    ]]
    mouseInsideRect = function( rect )

        local mX = love.mouse.getX()
        local mY = love.mouse.getY()

        if (mX >= rect.x) and (mX <= rect.x + rect.w) and (mY >= rect.y) and (mY <= rect.y + rect.h) then
            return true
        end

        return false

    end,

    -- Работа с курсором

    cursorRequired = false,
    cursorMode = "arrow",

    cursorCheck = function()
        if (ui.cursorRequired) then
            love.mouse.setCursor(love.mouse.getSystemCursor(ui.cursorMode))
        else
            love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
        end
    end
}

