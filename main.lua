Bear = require( "bear" )
Wolf = require( "wolf" )
Panda = require( "panda" )
EntityManager = require( "entityManager" )
MouseEntity = require( "mouseEntity" )
ExtraMath = require( "extraMath" )
DelayQueue = require( "delayQueue" )

math.randomseed( os.time() )

--[[ love callbacks ]]
function love.load()
   math.randomseed( os.time() )
   love.graphics.setNewFont(12)
   love.graphics.setColor(0,0,0)
   love.graphics.setBackgroundColor(255,255,255)

   love.window.setMode(800,600, {display=1})

   -- game state
   state = {}
   state.drawObjects = true
   state.drawPhysics = false
   state.drawGUI = true
   state.score = 0
   state.justClicked = true

   -- physics world
   state.world = love.physics.newWorld(0, 0, true)
   EntityManager.world = state.world
   state.world:setCallbacks(beginContact, endContact, preSolve, postSolve)
   state.delayQueue = DelayQueue:new()

   -- game objects
   for i=1,50 do
      local id = EntityManager:getNewId()

      local bear = Bear:new()
      bear:init(state.world, id)
      EntityManager:register(bear, id)
   end

   --mouse entity
   local id = EntityManager:getNewId()

   state.mouseEntity = MouseEntity:new()
   state.mouseEntity:init(state.world, id)
   EntityManager:register(state.mouseEntity, id)
   state.mouseEntityId = id

   state.combineSound = love.audio.newSource("pop.mp3", "static")
   state.hitSound = love.audio.newSource("sound/pool_balls_1.ogg", "static")

   -- background
   state.background = love.graphics.newImage("forest.jpg")
   state.tiledBackground = love.graphics.newImage("images/felt_green.png")

   createBorder(world, 2, 2, love.graphics.getWidth() - 2, love.graphics.getHeight() - 2)
end

function love.update(dt)
   state.world:update(dt)

   EntityManager:update(dt)

   state.delayQueue:update(dt)
end

function love.draw()
   love.graphics.setColor(255,255,255,255)
   love.graphics.draw(state.background, 0, 0)

   for x=0,2 do
      for y=0,2 do
         love.graphics.draw(state.tiledBackground, x * state.tiledBackground:getWidth(), y * state.tiledBackground:getHeight())
      end
   end

   if state.drawPhysics then
      for _, body in pairs(state.dworld:getBodies()) do
         for _, fixture in pairs(body:getFixtures()) do
            local shape = fixture:getShape()

            if shape:getType() == "circle" then
               local cx, cy = body:getWorldPoints(shape:getPoint())
               love.graphics.setColor(0,0,0,255)
               love.graphics.circle("fill", cx, cy, shape:getRadius())
            end
            if shape:getType() == "polygon" then
               love.graphics.setColor(0,0,0,255)
               love.graphics.polygon("fill", body:getWorldPoints( shape:getPoints() ) ) 
            end
         end

         local x, y = body:getPosition()
         local vx, vy = body:getLinearVelocity()
         vx, vy = vx, vy

         love.graphics.setColor(0,0,255,255)
         love.graphics.line(x, y, x+vx, y+vy)
      end
   end

   if state.drawObjects then
      EntityManager:draw()
   end

   if state.drawGUI then
      love.graphics.setColor(0,0,0,255)
      love.graphics.print("Score = "..state.score, 5)
      love.graphics.print("Tool = "..state.mouseEntity.tools[state.mouseEntity.activeToolKey].name, 5, 20)
   end
end

function love.mousepressed(x, y, button, istouch)
   EntityManager:mousepressed(x, y, button, istouch)
end 

function love.mousereleased(x, y, button, istouch)
   EntityManager:mousereleased(x, y, button, istouch)
end


function love.keypressed(key)
   EntityManager:keypressed(key)

   if key == 'q' then
      love.event.quit()
   end
   if key == 'o' then
      state.drawObjects = not state.drawObjects
   end
   if key == 'p' then
      state.drawPhysics = not state.drawPhysics
   end
end

function addContactId(map, body)
   id = body:getUserData()

   if id == nil then return end

   map[id] = true
end

function removeContactId(map, body)
   id = body:getUserData()

   if not id then return end

   map[id] = nil
end

--[[ collision callbacks ]]
function beginContact(a, b, coll)
   local aId = a:getUserData()
   local bId = b:getUserData()

   if( aId == state.mouseEntityId ) then
      -- mouse clicked something
      addContactId(state.mouseEntity.contacts, b)
      return
   end
   if( bId == state.mouseEntityId ) then
      -- mouse clicked something
      addContactId(state.mouseEntity.contacts, a)
      return
   end

   if EntityManager:isAnimal(aId) and EntityManager:isAnimal(bId) then

      local aBody = a:getBody()
      local bBody = b:getBody()

      local aVelocity = ExtraMath.magnitude(aBody:getLinearVelocity())
      local bVelocity = ExtraMath.magnitude(bBody:getLinearVelocity())

      local aVX, aVY = aBody:getLinearVelocity()
      local bVX, bVY = bBody:getLinearVelocity()

      collForce = aVelocity * aBody:getMass() + bVelocity * bBody:getMass()


      local minSoundForce = 450
      local minSoundPercent = 5
      local maxSoundForce = 2000
      local maxSoundPercent = 80

      if collForce > minSoundForce then

         -- percent within range
         local forcePercent = ((collForce - minSoundForce) / (maxSoundForce - minSoundForce))

         if forcePercent > 100 then
            forcePercent = 100
         end

         -- interpolation of min and max
         forcePercent = (1 - forcePercent) * minSoundPercent + (forcePercent * maxSoundPercent)

         --ex 20% along range is .8*5 + .2*80 = 4 + 16 = 20

         local newSound = love.audio.newSource("sound/pool_balls_1.ogg", "static")
         --print(collForce.."\t"..forcePercent)
         newSound:setVolume(forcePercent / 100)

         if forcePercent < 25 then
            newSound:setPitch(1.4)
         elseif forcePercent < 50 then
            newSound:setPitch(1.25)
         elseif forcePercent < 75 then
            newSound:setPitch(1.1)
         end

         -- if ExtraMath.rbool() then -- flip a coin to modify pitch
         --    if ExtraMath.rbool() then -- flip a coin for direction
         --       newSound:setPitch(1.5)
         --       print("higher")
         --    else
         --       print('lower')
         --       newSound:setPitch(0.75)
         --    end
         -- end

         newSound:play()


      end
      




      if collForce > 800 then
         local aEntity = EntityManager:get(aId)
         local bEntity = EntityManager:get(bId)

         local x, y = coll:getPositions()


         mergeFunction = function(obj)   
            local firstId = aId
            local secondId = bId

            EntityManager:delete(firstId)
            EntityManager:delete(secondId)

            local id = EntityManager:getNewId()
            local panda = Panda:new()
            panda:init(state.world, id, x, y)
            EntityManager:register(panda, id)
            if state.combineSound:isPlaying() then
               local newSound = love.audio.newSource("pop.mp3", "static")
               newSound:play()
            else
               state.combineSound:play()
            end

            if aVelocity > bVelocity then
               aVX, aVY = aVX/2, aVY/2
               bVX, bVY = bVX/2, bVY/2

               panda.body:setLinearVelocity(aVX, aVY)
            else
               panda.body:setLinearVelocity(bVX, bVY)
            end
         end

         if aEntity.name == "bear" and bEntity.name == "bear" then
            state.delayQueue:addDelayedScript(0, mergeFunction)
         end
      end
   end

end
 
function endContact(a, b, coll)
   if( a:getUserData() == state.mouseEntityId ) then
      -- remove id from contact map
      removeContactId(state.mouseEntity.contacts, b)
   end
      -- remove id from contact map 
      removeContactId(state.mouseEntity.contacts, a)
end
 
function preSolve(a, b, coll)
 
end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
 
end

--[[ other ]]
function createBorder(world, minX, minY, maxX, maxY)
   local boxWidth = 50

   --print("minX="..minX.." minY="..minY.." maxX="..maxX.." maxY="..maxY)

   local leftBox = makeBox(world, minX-boxWidth, minY, minX, maxY)
   local topBox = makeBox(world, minX, minY-boxWidth, maxX, minY)
   local rightBox = makeBox(world, maxX, minY, maxX+boxWidth, maxY)
   local bottomBox = makeBox(world, minX, maxY, maxX, maxY+boxWidth)
end

function makeBox(world, minX, minY, maxX, maxY)
   --print("minX="..minX.." minY="..minY.." maxX="..maxX.." maxY="..maxY)

   local box = {}
   local w, h = maxX-minX, maxY-minY
   box.body = love.physics.newBody(state.world, minX, minY, "static")
   box.body:setMass(10)
   box.body:setSleepingAllowed(false)
   box.shape = love.physics.newRectangleShape(w/2, h/2, w, h, 0)
   box.fixture = love.physics.newFixture(box.body, box.shape)
   box.fixture:setRestitution(1.0)
end

function click(id)
   if not id then
      return
   end
   if state.justClicked then
   print("click collision! id="..(id or "nil"))
   local entity = EntityManager:get(id)
   entity:damage(100)
   state.score = state.score + 1
   state.justClicked = false
   end
end