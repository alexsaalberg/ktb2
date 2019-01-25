local Animal = require( "animal" )

-- create the base table for the class definition
local Bear = Animal:new()

-- Bear static variables
Bear.image = love.graphics.newImage("bear.png")
Bear.maxHealth = 100
Bear.points = 1

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