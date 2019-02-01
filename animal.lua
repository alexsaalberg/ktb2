ExtraMath = require( "extraMath" )

-- create the base table for the class definition.
local Animal = {}

-- Animal static variables
Animal.image = love.graphics.newImage("bear.png")
Animal.maxHealth = 100
Animal.points = 1
Animal.radius = 25
Animal.physicsRadius = 15
Animal.mass = 10
Animal.name = "animal"

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
  self.scripts = {}
  self.scriptCount = 1
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

  self.shape = shape or love.physics.newCircleShape(self.innerRadius)

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

    local vx, vy = self.body:getLinearVelocity()
    local speed = ExtraMath.magnitude(vx, vy)
      --print("speed="..speed.." vx="..vx.." vy="..vy)
    if( speed < 50.0 ) then
      --print("speed="..speed.." vx="..vx.." vy="..vy)
      self.body:setLinearVelocity(self:randomVelocity(75))
    end

    for i, scriptObj in pairs(self.scripts) do
      scriptObj.delay = scriptObj.delay - dt

      if(scriptObj.delay < 0) then
        self.scripts[i] = nil
        scriptObj.script(self)
      end
    end
end

-- Love2D callback
function Animal:draw()
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

-- Called in respawn()
function Animal:randomVelocity(velocity)
  local v = velocity or 75
  local angle = math.random(0, 628) / 100
  angle = (math.random(0,4) * 90 * (3.14/180) ) + 45
  local x = math.sin(angle)
  local y = math.cos(angle)
  --print("angle="..angle.."\tx="..x.."\ty="..y)
  return x*v, y*v
end

-- Called in respawn()
function Animal.randomPosition()
    return math.random(50, 600), math.random(50, 400)
end

function Animal:addDelayedScript(delay, script)
  self.scriptCount = self.scriptCount + 1
  scriptObj = {}
  scriptObj.delay = delay
  scriptObj.script = script
  self.scripts[self.scriptCount] = scriptObj
end

-- Call to damage
function Animal:damage(damage)
    self.health = self.health - damage
    return self.health
end

return Animal