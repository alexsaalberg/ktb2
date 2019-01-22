Bear = require( "bear" )
EntityManager = require( "entityManager" )

math.randomseed( os.time() )

--[[ love callbacks ]]
function love.load()
   love.graphics.setNewFont(12)
   love.graphics.setColor(0,0,0)
   love.graphics.setBackgroundColor(255,255,255)

   love.window.setMode(800,600, {display=2})

   -- game state
   state = {}
   state.drawObjects = true
   state.drawPhysics = false
   state.score = 0

   -- physics world
   world = love.physics.newWorld(0, 0, true)
   world:setCallbacks(beginContact, endContact, preSolve, postSolve)

   -- game objects
   for i=1,10 do
      local id = EntityManager:getNewId()
      EntityManager:register(Bear:new(world, id), id)
   end

   local id = EntityManager:getNewId()
   mouseEntity = {}
   mouseEntity.body = love.physics.newBody(world, -100, -100, "dynamic")
   mouseEntity.body:setSleepingAllowed(false)
   mouseEntity.shape = love.physics.newCircleShape(10)
   mouseEntity.fixture = love.physics.newFixture(mouseEntity.body, mouseEntity.shape)
   mouseEntity.fixture:setUserData(id)
   mouseEntity.fixture:setSensor(true)

   EntityManager:register(mouseEntity, id)
   mouseEntityId = id

   createBorder(world, 2, 2, love.graphics.getWidth() - 2, love.graphics.getHeight() - 2)
end

function love.update(dt)
   world:update(dt)

   EntityManager:update(dt)
end

function love.draw()
   love.graphics.setColor(255,255,255,255)

   if state.drawPhysics then
      for _, body in pairs(world:getBodies()) do
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
      end
   end

   if state.drawObjects then
      EntityManager:draw()
   end
end

function love.mousepressed(x, y, button, istouch)
   if button == 1 then -- left click
      print("Click! x"..x.."y"..y)
      mouseEntity.body:setPosition(-100, -100)
      mouseEntity.body:setPosition(x, y)
   end
end

function love.keypressed(key)
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

--[[ collision callbacks ]]
function beginContact(a, b, coll)
   if( a:getUserData() == mouseEntityId ) then
      -- mouse clicked something
      click( b:getUserData() )
   end
   if( b:getUserData() == mouseEntityId ) then
      -- mouse clicked something
      click( a:getUserData() )
   end

end
 
function endContact(a, b, coll)
 
end
 
function preSolve(a, b, coll)
 
end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
 
end

--[[ other ]]
function createBorder(world, minX, minY, maxX, maxY)
   local boxWidth = 50

   print("minX="..minX.." minY="..minY.." maxX="..maxX.." maxY="..maxY)

   local leftBox = makeBox(world, minX-boxWidth, minY, minX, maxY)
   local topBox = makeBox(world, minX, minY-boxWidth, maxX, minY)
   local rightBox = makeBox(world, maxX, minY, maxX+boxWidth, maxY)
   local bottomBox = makeBox(world, minX, maxY, maxX, maxY+boxWidth)
end

function makeBox(world, minX, minY, maxX, maxY)
   print("minX="..minX.." minY="..minY.." maxX="..maxX.." maxY="..maxY)

   local box = {}
   local w, h = maxX-minX, maxY-minY
   box.body = love.physics.newBody(world, minX, minY, "static")
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
   print("click collision! id="..(id or "nil"))
   local entity = EntityManager:get(id)
   entity:damage(100)
end