-- create the base table for the class definition.
local EntityManager = {}

EntityManager.entities = {}
EntityManager.freshId = 1

--[[ external functions]]
function EntityManager:register(entity, id)
  id = id or self:getNewId() -- get new id if none is supplied
  self.entities[id] = entity
  return id
end

function EntityManager:get(id)
  return self.entities[id]
end

function EntityManager:delete(id)
  self.entities[id] = nil
end

function EntityManager:getNewId()
  local id = self.freshId
  self.freshId = id + 1
  return id
end

-- love callbacks
function EntityManager:update(dt)
  for id, entity in pairs(self.entities) do
    -- call entity.update(dt) on any entity which has that function
    local update = entity.update
    if update then
      entity:update(dt)
    end 
  end
end

function EntityManager:draw()
  for id, entity in pairs(self.entities) do
    -- call entity.draw() on any entity which has that function
    local draw = entity.draw
    if draw then
      entity:draw()
    end 
  end
end

--[[ internal functions ]]

return EntityManager