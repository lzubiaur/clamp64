-- test.lua

local Test = Class('Test')

function Test:initialize(world,name)
  self.name = 'Test draw'
end

function Test:setResolution(w,h)
  love.window.setMode(w,h)
  setupMultiResolution()
  game:createCamera()
end


function Test:update(dt)
end

function Test:draw(l,t,w,h)
  g.setColor(255,255,255,255)
  g.printf(self.name,0,0,w,'center')
end

return Test
