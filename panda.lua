local Bear = require( "bear" )

-- create the base table for the class definition
local Panda = Bear:new()

-- Panda static variables
Panda.image = love.graphics.newImage("panda.png")
Panda.radius = 20
Panda.innerRadius = 20
Panda.maxHealth = 100
Panda.points = 1
Panda.name = "panda"

-- constructor
function Panda:new()
    -- create a new table for the object instance
    local instance = {}

    -- hook up its metatable to the class definition
    setmetatable( instance, self )
    self.__index = self

    -- return the instance
    return instance
end

return Panda