-- create the base table for the class definition.
local Animal = {}

-- Animal static variables
Animal.image = love.graphics.newImage("bear.png")
Animal.maxHealth = 100
Animal.points = 1
Animal.radius = 25
Animal.mass = 10

-- constructor
function Animal:new()
    -- create a new table for the object instance
    local instance = {}
    -- hook up its metatable to the class definition
    setmetatable( instance, self )

    instance.__index = self
    self.__index = self

    -- return the instance
    return instance
end

-- function that you would normally think of as the constructor.
function Animal:init(world, id, ... )
  self.id = id
  self.health = self.maxHealth
  self:initPhysics(world, id) 
end

-- called when killed
function Animal:respawn()
  self.body:setPosition(self:randomPosition())
  self.body:setLinearVelocity(self:randomVelocity())
  self.health = self.maxHealth
end

-- world and id are required, override randomVelocity() and randomPosition() to change respawning
function Animal:initPhysics(world, id, x, y, vX, vY, shape, mass, restitution)
  if not x or not y then
    x, y = self.randomPosition()
  end

  if not vX or not vY then
    vX, vY = self.randomVelocity()
  end

  mass = mass or self.mass

  restitution = restitution or 0.9

  self.shape = shape or love.physics.newCircleShape(self.radius)

  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.body:setLinearVelocity(vX, vY)
  self.body:setMass(mass)
  self.body:setSleepingAllowed(false)
  self.body:setFixedRotation(true)

  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.fixture:setRestitution(restitution)
  self.fixture:setUserData(id)
end

-- Love2D callback
function Animal:update(dt)
    if self.health <= 0 then
      self:respawn()
    end
end

-- Love2D callback
function Animal:draw()
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

-- Called in respawn()
function Animal:randomVelocity(velocity)
  local v = velocity or 1000
  local angle = math.random(0, 628) / 100
  angle = (math.random(0,4) * 90 * (3.14/180) ) + 45
  local x = math.sin(angle)
  local y = math.cos(angle)
  print("angle="..angle.."\tx="..x.."\ty="..y)
  return 0, 0, x*v, y*v
end

-- Called in respawn()
function Animal.randomPosition()
    return math.random(50, 600), math.random(50, 400)
end

-- Call to damage
function Animal:damage(damage)
    self.health = self.health - damage
    return self.health
end

return Animal