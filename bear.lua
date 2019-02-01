local Animal = require( "animal" )

-- create the base table for the class definition
local Bear = Animal:new()

-- Bear static variables
Bear.image = love.graphics.newImage("bear.png")
Bear.radius = 20
Bear.innerRadius = 20
Bear.maxHealth = 100
Bear.points = 1
Bear.name = "bear"

-- constructor
function Bear:new()
    -- create a new table for the object instance
    local instance = {}

    -- hook up its metatable to the class definition
    setmetatable( instance, self )
    self.__index = self

    -- return the instance
    return instance
end

return Bear