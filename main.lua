Bear = require( "bear" )

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

   -- game objects
   entities = {}
   for i=1,10 do
      entities[i] = Bear:new(world)
   end
end

function love.update(dt)
   world:update(dt)

   for id, entity in pairs(entities) do
      entity:update(dt)
   end
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
      for id, entity in pairs(entities) do
         entity:draw()
      end
   end
end

function love.mousepressed(x, y, button, istouch)
   if button == 1 then
      imgx = x -- move image to where mouse clicked
      imgy = y
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