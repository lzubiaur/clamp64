-- pblink.lua

local Player = require 'entities.player'
local Animated = require 'entities.base.animated'
local Body = require 'entities.base.body'

local Blink = Player:addState('Blink')

function Blink:enteredState()
  Beholder.stopObserving(self)
  local anim = Animated:new(Assets.img.tilesheet,0,0,10,10)
  anim:setAnimation(game.tilesheetGrid(1,1,2,3),.08)
  self:addSprite(anim)
  Timer.after(.8,function()
    self:removeSprite(anim)
    anim:destroy()
    self:popState()
  end)
end

function Blink:exitedState()
  self:createEventHandlers()
end

function Blink:update(dt)
  Body.update(self,dt)
end

return Blink
