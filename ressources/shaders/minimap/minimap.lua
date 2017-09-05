minimap = {}

function minimap.getShader()
    local shader = love.graphics.newShader("minimap.glsl")
    return shader
end

return minimap