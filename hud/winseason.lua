-- hud/winseason.lua

local HUD = require 'hud.base'
local Label = require 'entities.ui.label'
local Quad = require 'entities.base.quad'
local Node = require 'entities.base.node'
local ColorLayer = require 'entities.base.colorlayer'

local WinSeason = HUD:addState('WinSeason')

local function theEndText()
  return {
    {255,163,0}, 'The End!\n',
    {255,241,232}, 'Thank you for playing.'
  }
end

function WinSeason:enteredState(score)
  self:createSwallowTouchLayer(function()
    Beholder.trigger('GotoMainMenu')
  end)

  self:createDitheredLayer()
  self.node:addChild(Label:new(self.world,0,10,theEndText(),{limit=64}))
end

function WinSeason:createDitheredLayer()
  self.node:addChild(ColorLayer:new(0,0,64,64,{color={0,30,63,120}}))
  local ditter = Assets.img.ditter
  ditter:setWrap('repeat','repeat')
  local quad = g.newQuad(0,0,64,64,ditter:getDimensions())
  quad = Quad:new(ditter,quad,0,0,{color={0,30,63,100},ax=0,ay=0})
  self.node:addChild(quad)
end

function WinSeason:exitedState()
  self:removeSwallowTouchLayer()
end

return WinSeason
