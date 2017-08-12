-- hud/gameover.lua

local HUD = require 'hud.base'

local Gameover = HUD:addState('Gameover')

function Gameover:enteredState()
  self:createSwallowTouchLayer(function()
    Beholder.trigger('GotoMainMenu')
  end)
end

function Gameover:exitedState()
  self:removeSwallowTouchLayer()
end

return Gameover
