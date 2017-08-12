-- hud/win.lua

local HUD = require 'hud.base'
local Label = require 'entities.ui.label'
local Quad = require 'entities.base.quad'
local Node = require 'entities.base.node'
local ColorLayer = require 'entities.base.colorlayer'

local Win = HUD:addState('Win')

function Win:enteredState()
  self:createSwallowTouchLayer(function()
    Beholder.trigger('NextLevel')
  end)

  self:createDitherLayer()

  Label:new(self.world,0,10,'Level '..game.state.cli..' cleared',{limit=64})

  local sl = self.node:addChild(Label:new(self.world,0,25,'Score:',{limit=64}))
  sl.score = 0
  sl.update = function(self,dt)
    self.text = 'Score:'..math.ceil(self.score)
  end
  self.timer:script(function(wait)
    self.tween = Tween.new(1,sl,{ score = game:getGrandScore() })
    wait(1)
    local level = game:getCurrentLevelState()
    local label = Label:new(self.world,0,40,'x0')
    for i=1,level.diamonds do
      label.text = 'x'..i
      wait(.3)
    end
  end)
end

function Win:createDitherLayer()
  self.node:addChild(ColorLayer:new(0,0,64,64,{color={0,30,63,120}}))
  local ditter = Assets.img.ditter
  ditter:setWrap('repeat','repeat')
  local quad = g.newQuad(0,0,64,64,ditter:getDimensions())
  quad = Quad:new(ditter,quad,0,0,{color={0,30,63,100},ax=0,ay=0})
  self.node:addChild(quad)
end

function Win:update(dt)
  if self.tween and self.tween:update(dt) then
    self.tween = nil
  end
  HUD.update(self,dt)
end

function Win:exitedState()
  self.timer:clear()
  self:removeSwallowTouchLayer()
end

return Win
