-- create the base table for the class definition.
local Bear = {}

-- Bear static variables
Bear.image = love.graphics.newImage("bear.png")


-- magic constructor. This is exactly the same no matter what the class is for.
function Bear:new(world, ... )
    -- create a new table for the object instance
    local instance = {}
    -- hook up its metatable to the class definition
    setmetatable( instance, self )
    self.__index = self
    -- call my "normal" constructor method. "..." is like argv.
    self._init( instance, world, ... )
    -- return the instance
    return instance
end

-- function that you would normally think of as the constructor.
function Bear:_init(world, ... )
    -- physics stuff
    self.body = love.physics.newBody(world, 400,200, "dynamic")  -- set x,y position (400,200) and let it move and hit other objects ("dynamic")
    self.body:setMass(10)                                        -- make it pretty light
    self.shape = love.physics.newCircleShape(50)                  -- give it a radius of 50
    self.fixture = love.physics.newFixture(self.body, self.shape)          -- connect body to shape
    self.fixture:setRestitution(0.4)                                -- make it bouncy
    self.fixture:setUserData("bear")
end

function Bear:update(dt)

end

function Bear:draw()
   love.graphics.setColor(255,255,255,255)
   local b = self --faster
   local imgWidth = b.image:getWidth()
   local imgHeight = b.image:getHeight()
   local shapeHeight = b.shape:getRadius() * 2
   local shapeWidth = b.shape:getRadius() * 2
   local xScale = shapeWidth / imgWidth
   local yScale = shapeHeight / imgHeight
   local invXScale = imgWidth / shapeWidth
   local invYScale = imgWidth / shapeHeight
   love.graphics.draw(b.image, b.body:getX(), b.body:getY(), b.body:getAngle(), xScale, yScale, b.shape:getRadius() * invXScale, b.shape:getRadius() * invYScale)

   love.graphics.setColor(0,0,0,255)
   love.graphics.print("xScale" .. xScale .. ", yScale" .. yScale, 20, 20)
   love.graphics.print("x" .. b.body:getX() .. ", y" .. b.body:getY(), 20, 30)
   love.graphics.print("iW" .. imgWidth .. ", iH" .. imgHeight, 20, 40)
   --love.graphics.draw(Bear.image, self.body:getX(), self.body:getY())
end

return Bear