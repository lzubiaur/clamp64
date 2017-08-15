-- hud/Start.lua

local HUD = require 'hud.base'
local Quad = require 'entities.base.quad'
local Label = require 'entities.ui.label'

local Start = HUD:addState('Start')

function Start:enteredState()
  local py = 55
  if conf.mobile then
    local grid = Anim8.newGrid(12,12,Assets.img.tilesheet:getDimensions())
    local arrow = Quad:new(Assets.img.tilesheet,grid(6,7)[1],15,py)
    self.node:addChild(arrow)
    self.tween = Tween.new(.2,arrow,{ x = 18 })
    self.node:addChild(Label:new(self.world,0,py,'Play',{limit=64}))
  else
    local label = self.node:addChild(Label:new(self.world,0,py,'Press space',{limit=64,color={255,241,232,255}}))
    self.tween = Tween.new(.4,label,{ color={255,241,232,0}, shadowColor={53,58,80,0}})
  end
end

local dir = 1
function Start:update(dt)
  if self.tween:update(dt * dir) then
    dir = - dir
  end
  HUD.update(self,dt)
end

function Start:exitedState()
end

return Start
