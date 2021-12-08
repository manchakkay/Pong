
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
        Рассчёт размеров центрированного текста

        Аргументы:
        rectX, rectY, text, fontName
    ]]
    centerTextRect = function ( arguments )

        local font = ui.FONTS[arguments.fontName]
        local textWidth = font:getWidth(arguments.text)
        local textHeight = font:getHeight()

        return { 
            x = arguments.rectX-textWidth, 
            y = arguments.rectY-textHeight, 
            w = textWidth*2, 
            h = textHeight*2 
        }

    end,

    --[[ 
        Рисует центрированный текст

        Аргументы:
        rectX, rectY, text, fontName, colorName
    ]]
    centerText = function( arguments )

        local font = ui.FONTS[arguments.fontName]
        local color = ui.COLORS[arguments.colorName]

        local textWidth = font:getWidth(arguments.text)
        local textHeight = font:getHeight()

        love.graphics.setFont(font)
        love.graphics.setColor(color["r"] / 255, color["g"] / 255, color["b"] / 255)
        love.graphics.print(arguments.text, arguments.rectX, arguments.rectY, 0, 1, 1, textWidth / 2, textHeight / 2)

    end,

    --[[ 
        Проверяем попадание курсора в прямоугольник

        Аргументы:
        rect = {x,y,w,h}
    ]]
    mouseInsideRect = function ( rect )

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

    cursorCheck = function ()
        if (ui.cursorRequired) then
            love.mouse.setCursor( love.mouse.getSystemCursor(ui.cursorMode) )
        else
            love.mouse.setCursor( love.mouse.getSystemCursor("arrow") )
        end
    end
}

