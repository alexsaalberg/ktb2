MouseEntity = {}
ExtraMath = require( "ExtraMath" )

function MouseEntity:new()
 -- create a new table for the object instance
 local instance = {}
 -- hook up its metatable to the class definition
 setmetatable( instance, self )

 instance.__index = self
 self.__index = self

 -- return the instance
 return instance
end

function MouseEntity:init(world, id)
	self.body = love.physics.newBody(world, -100, -100, "dynamic")
	self.body:setSleepingAllowed(false)
	self.shape = love.physics.newCircleShape(10)
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setUserData(id)
	self.fixture:setSensor(true)

	self.contacts = {}

	self.tools = {}
	self:initTools()
end

function MouseEntity:initTools()
	pop = {}
	self.tools["1"] = pop

	pop.name="pop"
	pop.mousepressed = function(mouseEntity, x, y, button, isTouch)
	   if button == 1 then -- left click
	      print("Click! x"..x.."y"..y)

	      local numClicks = 10

	      for id, _ in pairs(state.mouseEntity.contacts) do
	         animal = EntityManager:get(id)
	         animal:addDelayedScript(0.1, function(animal) animal:damage(100) end)
	         animal.body:setLinearVelocity(animal:randomVelocity(2000))

	         numClicks = numClicks - 1
	         if numClicks == 0 then
	            break
	         end
	      end
	   end
	end

	meteor = {}
	self.tools["2"] = meteor
	meteor.name = "meteor"

	self.drag = {}

	meteor.mousepressed = function(mouseEntity, x, y, button, isTouch)
	   if button == 1 then -- left click
	   	-- drag info
	   	drag = {startX = x, startY = y, endX = x, endY = y}
	   	mouseEntity.drag = drag

	   	-- find what the mouse is hovering over
	   	for id, _ in pairs(mouseEntity.contacts) do
	   		drag.animal = EntityManager:get(id)
	   		break
	   	end

	   	-- if we didn't click anything, exit
	   	if animal == nil then
	   		return
	   	end
	   end
	end

	meteor.mousereleased = function(mouseEntity, x, y, button, isTouch)
	   if button == 1 then -- left click


	   	local drag = mouseEntity.drag
	   	if drag == nil then
	   		return
	   	end
	   	if drag.animal == nil then
	   		drag = nil
	   		return
	   	end

	   	local dragVectorX, dragVectorY = x - drag.startX, y - drag.startY
	   	local dragLength = ExtraMath.magnitude(dragVectorX, dragVectorY)


	   	local forceScale = 10
	   	--d*f * x = 100
	   	--d *x = 100 * f
	   	--x = 100/f* d

	   	if dragLength * forceScale > 1000 then
	   		forceScale = forceScale * (1000.0 / (forceScale * dragLength) ) -- limit
	   	end

	   	drag.animal.body:setLinearVelocity(dragVectorX * forceScale, dragVectorY * forceScale)
	      --drag.animal:addDelayedScript(0.4, function(animal) animal:damage(100) end)

	   	mouseEntity.drag = nil
	   end
	end

	meteor.update = function(mouseEntity, dt)
		local drag = mouseEntity.drag
		if drag and drag.animal == nil then
			drag = nil
			print("nilling drag in update()")
		end

		if drag then
			drag.startX, drag.startY = drag.animal.body:getPosition()
			drag.endX, drag.endY = love.mouse.getPosition()
		end
	end

	meteor.draw = function(mouseEntity)
		local drag = mouseEntity.drag
		if not mouseEntity then
			print("mouse nil")
		end

		if not drag then
			print('drag nil"')
		end

		if drag then
			print("drawing")
			if drag.startX and drag.startY and drag.endX and drag.endY then
				print('actually draing"')
		      love.graphics.setColor(0,0,255,255)
				love.graphics.line(drag.startX, drag.startY, drag.endX, drag.endY)
				print("sx="..drag.startX.."\tsY="..drag.startY.."eX="..drag.endX.."ey="..drag.endY)
			end
		end
	end

	self.activeToolKey = "1"
end

function MouseEntity:keypressed(key)
	if self.tools[key] == nil then
		return
	end

	self.activeToolKey = key
end

function MouseEntity:mousepressed(...)
	local activeTool = self.tools[self.activeToolKey]
	callIfExists(activeTool.mousepressed, self, ...)
end

function MouseEntity:mousereleased(...)
	local activeTool = self.tools[self.activeToolKey]
	callIfExists(activeTool.mousereleased, self, ...)
end

function MouseEntity:update(...)
	self.body:setPosition(love.mouse.getPosition())

	local activeTool = self.tools[self.activeToolKey]
	callIfExists(activeTool.update, self, ...)
end

function MouseEntity:draw()
	print("mouse draw")
	local activeTool = self.tools[self.activeToolKey]
	callIfExists(activeTool.draw, self)
end

function callIfExists(f, ...)
  if f then
    f(...)
  end
end

return MouseEntity