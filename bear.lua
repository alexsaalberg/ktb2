-- create the base table for the class definition.
local Bear = {}

-- Bear static variables
Bear.image = love.graphics.newImage("bear.png")


-- constructor
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
function Bear:_init(world, id, ... )
    -- game stuff
    self.health = 100

    -- physics stuff
    local x = math.random(200, 600)
    local y = math.random(200, 600)
    self.body = love.physics.newBody(world, x, y, "dynamic")  -- set x,y position (400,200) and let it move and hit other objects ("dynamic")
    self.body:setMass(10)                                        -- make it pretty light
    self.body:setSleepingAllowed(false)
    self.body:setFixedRotation(true)
    self.shape = love.physics.newCircleShape(25)                  -- give it a radius of 50
    self.fixture = love.physics.newFixture(self.body, self.shape)          -- connect body to shape
    self.fixture:setRestitution(1.0)                                -- make it bouncy
    self.fixture:setUserData(id)

    self.body:setLinearVelocity(self:randomDirection())
end

function Bear:update(dt)
    if self.health <= 0 then
        self.body:setPosition(self:randomPosition())
        self.body:setLinearVelocity(self:randomDirection())
        self.health = 100
    end
end

function Bear:randomDirection(velocity)
    local v = velocity or 1000
    local angle = math.random(0, 628) / 100
    local x = math.sin(angle)
    local y = math.cos(angle)
    print("angle="..angle.."\tx="..x.."\ty="..y)
    return x*v, y*v
end

function Bear:randomPosition()
    return math.random(200, 600), math.random(200, 400)
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

--[[ External ]]
function Bear:damage(damage)
    self.health = self.health - damage
    return self.health
end

function Bear:kill()

end

return Bear