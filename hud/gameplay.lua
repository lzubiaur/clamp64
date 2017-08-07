-- hud/gameplay.lua

local HUD = require 'hud.base'
local Quad = require 'entities.base.quad'
local ProgressBar = require 'entities.ui.progressbar'

local GamePlay = HUD:addState('GamePlay')

function GamePlay:enteredState()
  local s = Assets.img.tilesheet

  -- Lives
  for i=1,conf.maxLives do
    local quad = g.newQuad(0,24,12,12,s:getDimensions())
    local sprite = Quad:new(s,quad,3+6*(i-1),4)
    self.node:addChild(sprite,0,i)
    if game.state.lives < i then
      sprite:setVisible(false)
    end
  end

  -- Progress bar sprite
  local quad = g.newQuad(36,24,24,12,s:getDimensions())
  self.node:addChild(Quad:new(s,quad,conf.sw-12,4))

  local p = Assets.img.progressbar
  local w,h = p:getDimensions()
  local progressBar = ProgressBar:new(self.world,44,3,w,h,p,0)
  self.node:addChild(progressBar)

  Beholder.group(self,function()
    Beholder.observe('progress',function(value)
      progressBar:setPercent(math.ceil(Lume.clamp(value,0,1)*100)/100)
    end)
    local countLives = game.state.lives
    Beholder.observe('lose',function()
      if countLives > 1 then
        self.node:getChildByTag(countLives):setVisible(false)
        countLives = countLives - 1
      end
    end)
    Beholder.observe('xup',function()
      if countLives < conf.maxLives then
        countLives = countLives + 1
        self.node:getChildByTag(countLives):setVisible(true)
      end
    end)
  end)
end

function GamePlay:exitedState()
  self.node:setVisible(false)
  Beholder.stopObserving(self)
end

function GamePlay:draw(l,t,w,h)
  HUD.draw(self,l,t,w,h)
  -- g.setColor(0,226,50,255)
  -- g.line(44,4,44+16*self.progress,4)
  -- g.setColor(0,255,56,255)
  -- g.line(44,3,44+16*self.progress,3)
end

return GamePlay
