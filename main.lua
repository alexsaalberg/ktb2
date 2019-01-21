Bear = require( "bear" )
EntityManager = require( "entityManager" )

function love.load()
   love.graphics.setNewFont(12)
   love.graphics.setColor(0,0,0)
   love.graphics.setBackgroundColor(255,255,255)

   -- game state
   state = {}
   state.drawObjects = true
   state.drawPhysics = false

   -- physics world
   world = love.physics.newWorld(0, 0, true)
   world:setCallbacks(beginContact, endContact, preSolve, postSolve)

   -- game objects
   for i=1,2 do
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
end

function love.update(dt)
   world:update(dt)


   EntityManager:update(dt)
end

function love.draw()
   love.graphics.setColor(0,0,0,255)
   love.graphics.print("Hello World", 600, 400)
   love.graphics.setColor(255,255,255,255)

   if state.drawPhysics then
      for _, body in pairs(world:getBodies()) do
         for _, fixture in pairs(body:getFixtures()) do
            local shape = fixture:getShape()
             
            local cx, cy = body:getWorldPoints(shape:getPoint())
            love.graphics.setColor(0,0,0,255)
            love.graphics.circle("fill", cx, cy, shape:getRadius())

            love.graphics.setColor(0,0,0,255)
            love.graphics.print("cx" .. cx .. ", cy" .. cy, 20, 80)
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
      --local range = 5
      --wrld:rayCast(x-range, y-range, x+range, y+range, clickRaycastCallback)
      mouseEntity.body:setPosition(x, y)
   end
   if button == 2 then
      entities[2].body:setPosition(x, y)
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

-- physics callbacks
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

-- other functions
function click(id)
   print("click collision! id="..(id or "nil"))
   local entity = EntityManager:get(id)
   entity:damage(100)
end