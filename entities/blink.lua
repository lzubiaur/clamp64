-- pblink.lua

local Player = require 'entities.player'
local Animated = require 'entities.base.animated'
local Body = require 'entities.base.body'

local Blink = Player:addState('Blink')

function Blink:enteredState()
  self.isInvincible = true
  local anim = Animated:new(Assets.img.tilesheet,0,0,10,10)
  anim:setAnimation(game.tilesheetGrid(1,1,2,3),.08)
  self.ship:addChild(anim)
  Timer.after(3,function()
    self.ship:removeChild(anim)
    anim:destroy()
    self:popState()
  end)
end

function Blink:exitedState()
  Beholder.trigger('beatable')
  self.isInvincible = false
end

return Blink
