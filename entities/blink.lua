-- pblink.lua

local Player = require 'entities.player'
local Animated = require 'entities.base.animated'
local Body = require 'entities.base.body'

local Blink = Player:addState('Blink')

function Blink:enteredState()
  self.isInvincible = true
  self.anim = self:createAnimation()
  Timer.after(3,function() self:popState() end)
  -- Use self.anim to group handler because self is already used by player state
  Beholder.group(self.anim,function()
    Beholder.observe('right',function() self:popState() end)
    Beholder.observe('left',function() self:popState() end)
    Beholder.observe('up',function() self:popState() end)
    Beholder.observe('down',function() self:popState() end)
  end)
end

function Blink:createAnimation()
  local anim = Animated:new(Assets.img.tilesheet,0,0,12,12)
  anim:setAnimation(game.tilesheetGrid(1,1,2,3),.08)
  self.ship:addChild(anim)
  return anim
end

function Blink:exitedState()
  Beholder.stopObserving(self.anim)
  self.ship:removeChild(self.anim)
  self.anim:destroy()
  Beholder.trigger('beatable')
  self.isInvincible = false
end

return Blink
