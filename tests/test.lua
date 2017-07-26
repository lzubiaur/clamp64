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

function Test:drawAfterCamera(l,t,w,h)
  g.setColor(255,255,255,255)
  g.printf(self.name,0,0,w,'center')
end

function Test:drawBeforeCamera(l,t,w,h)
end

function Test:keypressed(key, scancode, isrepeat)
end

return Test
