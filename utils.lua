local utils = {}

function utils.drawBgColor(r, g, b)
    local old_r, old_g, old_b, old_a = love.graphics.getColor()
    love.graphics.setColor(love.math.colorFromBytes(r, g, b))
    love.graphics.rectangle("fill", 0, 0, WIN_WIDTH, WIN_HEIGHT)
    love.graphics.setColor(old_r, old_g, old_b, old_a)
end

return utils
