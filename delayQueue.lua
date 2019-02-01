-- create the base table for the class definition.
local DelayQueue = {}

-- constructor
function DelayQueue:new()
    -- create a new table for the object instance
    local instance = {}
    -- hook up its metatable to the class definition
    setmetatable( instance, self )

    instance.__index = self
    self.__index = self

    instance.scripts = {}
    instance.scriptCount = 0

    -- return the instance
    return instance
end

-- Love2D callback
function DelayQueue:update(dt, ...)
  for i, scriptObj in pairs(self.scripts) do
    scriptObj.delay = scriptObj.delay - dt

    if(scriptObj.delay <= 0) then
      self.scripts[i] = nil
      scriptObj.script(...)
    end
  end
end

function DelayQueue:addDelayedScript(delay, script)
  self.scriptCount = self.scriptCount + 1
  scriptObj = {}
  scriptObj.delay = delay
  scriptObj.script = script
  self.scripts[self.scriptCount] = scriptObj
end

return DelayQueue