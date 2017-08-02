-- test.lua
local Game = require 'common.game'

local Test = Class('Test')

function Test:initialize(world,name)
  self.name = 'Test draw'
end

function Test:destroy()
end

function Test:setResolution(w,h,cw,ch)
  love.window.setMode(w,h,select(3,love.window.getMode()))
  -- Push:resetSettings()
  setupMultiResolution()
  game:createCamera(game.visible:pointToPixel(cw or w, ch or h))
  game.camera:setPosition(0,0)
  -- Note the parenthesis because we only want the first argument
  g.setFont(g.newFont( (game.visible:pointToPixel(12)) ))
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
