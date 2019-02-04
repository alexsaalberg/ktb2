ExtraMath = require( "extraMath" )

-- create the base table for the class definition.
local Field = {}

-- Field static variables
Field.image = love.graphics.newImage("circle_02.png")
Field.radius = 5
Field.name = "Field"
function Field:defaultScript(dt, contactBody) 

  self.radius = self.radius + dt * 1000.0

  local x, y = self.body:getPosition()
  local otherX, otherY = contactBody:getPosition()

  local dX, dY = otherX - x, otherY - y -- vector from self.body to contactBody

  local distance = ExtraMath.magnitude(dX, dY)
  -- bigger distance, less force so...
  local effectiveDistance = (self.radius / distance)
  if effectiveDistance > self.radius then --if distance is less than 1, just say it's 1 (or force is huge)
    effectiveDistance = self.radius
  end

  local multiplier = 500000

  contactBody:applyForce(multiplier * effectiveDistance * dX * dt, multiplier * effectiveDistance * dY * dt)
end
Field.lifeTime = 0.1 --seconds

-- constructor
function Field:new()
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
function Field:init(world, id, x, y, script, lifeTime)
  self.id = id
  self:initPhysics(world, id, x, y) 
  self.script = script or self.defaultScript
  self.timeLeft = lifeTime or self.lifeTime
end

-- world and id are required, override randomVelocity() and randomPosition() to change respawning
function Field:initPhysics(world, id, x, y)
  mass = mass or self.mass

  restitution = restitution or 0.9

  self.shape = shape or love.physics.newCircleShape(self.radius)

  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.body:setSleepingAllowed(false)
  self.body:setFixedRotation(true)

  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.fixture:setRestitution(restitution)
  self.fixture:setUserData(id)
  self.fixture:setSensor(true)
end

-- Love2D callback
function Field:update(dt)
  self.timeLeft = self.timeLeft - dt
  if self.timeLeft <= 0 then
    EntityManager:delete(self.id)
    return
  end

  local contacts = self.body:getContacts()
  local contactsIsEmpty = true

  for i, contact in pairs(contacts) do
    contactsIsEmpty = false
    local fixtureA, fixtureB = contact:getFixtures()
    local otherFixture
    if (fixtureA == self.fixture) then 
      otherFixture = fixtureB 
    else 
      otherFixture = fixtureA 
    end
    local otherBody = otherFixture:getBody()

    print("contact#"..i)

    self:script(dt, otherBody)
  end

  if contactsIsEmpty then
    print("EMPTY")
  end
end

-- Love2D callback
function Field:draw()
   love.graphics.setColor(255,255,255,255)
   local b = self --faster
   local imgWidth = b.image:getWidth()
   local imgHeight = b.image:getHeight()
   local shapeHeight = self.radius * 2
   local shapeWidth = self.radius * 2
   local xScale = shapeWidth / imgWidth
   local yScale = shapeHeight / imgHeight
   local invXScale = imgWidth / shapeWidth
   local invYScale = imgWidth / shapeHeight
   love.graphics.draw(b.image, b.body:getX(), b.body:getY(), b.body:getAngle(), xScale, yScale, self.radius * invXScale, self.radius * invYScale)
end

return Field