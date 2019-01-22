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
    self.body = love.physics.newBody(world, x, y, "dynamic")
    self.body:setMass(10)
    self.body:setSleepingAllowed(false)
    self.body:setFixedRotation(true)
    self.shape = love.physics.newCircleShape(25)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setRestitution(0.9)
    self.fixture:setUserData(id)
    --self.fixture:setCategory(2)
    --self.fixture:setMask(2)
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
    angle = (math.random(0,4) * 90 * (3.14/180) ) + 45
    local x = math.sin(angle)
    local y = math.cos(angle)
    print("angle="..angle.."\tx="..x.."\ty="..y)
    return x*v, y*v
end

function Bear:randomPosition()
    return math.random(50, 600), math.random(50, 400)
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
end

--[[ External ]]
function Bear:damage(damage)
    self.health = self.health - damage
    return self.health
end

function Bear:kill()

end

return Bear