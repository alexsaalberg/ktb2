local Animal = require( "animal" )
local ExtraMath = require( "extraMath" )

-- create the base table for the class definition
local Wolf = Animal:new()

-- Wolf static variables
Wolf.image = love.graphics.newImage("wolf.png")
Wolf.radius = 20
Wolf.mass = 20


-- constructor
function Wolf:new()
    -- create a new table for the object instance
    local instance = {}

    -- hook up its metatable to the class definition
    setmetatable( instance, self )
    self.__index = self

    -- return the instance
    return instance
end

-- function that you would normally think of as the constructor.
function Wolf:init(world, id, ... )
  self.id = id
  self.health = self.maxHealth
  self:initPhysics(world, id) 
end

function Wolf:update(dt)
    love.graphics.setColor(0,0,0,255)
	love.graphics.print("wolf is being called", 25, 50)
	if love.mouse.isDown(1) then -- mouse is being held
		local x, y = self.body:getPosition()
		local mx, my = love.mouse:getPosition()
		local vx, vy = self.body:getLinearVelocity()
		local tmx, tmy = mx - x, my - y

		local playerSpeed = 20

		self.body:applyLinearImpulse(tmx * dt * playerSpeed, tmy * dt * playerSpeed)

		-- limit max speed
		vx, vy = self.body:getLinearVelocity()
		local speed = ExtraMath.magnitude(vx, vy)
		local maxSpeed = 500

		if speed > maxSpeed then
			local speedModifier = (maxSpeed / speed)
			local excessSpeed = speed - maxSpeed
			self.body:applyForce(-vx * excessSpeed, -vy * excessSpeed)
			--self.body:setLinearVelocity(speedModifier * vx, speedModifier * vy)
		end
	end
end

function Wolf:draw()
	Animal.draw(self)
    love.graphics.setColor(0,0,0,255)
    love.graphics.print("angle="..(math.deg(self.angle or 0)).."\tv="..(self.velocity or 0), 0, 40)
    love.graphics.print("body_angle="..(self.body:getAngle()), 0, 50)
    local vx, vy = self.body:getLinearVelocity()
    love.graphics.print("vx="..vx.."\tvy="..vy, 0, 65)
end


return Wolf