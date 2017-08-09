-- hud/gameplay.lua

local HUD = require 'hud.base'
local Quad = require 'entities.base.quad'
local ProgressBar = require 'entities.ui.progressbar'
local Segment = require 'entities.segment'

local GamePlay = HUD:addState('GamePlay')

function GamePlay:enteredState()
  local s = Assets.img.tilesheet

  -- Warnings are disabled
  -- self:addEnemyWarningSensors()

  -- Lives
  for i=1,conf.maxLives do
    local quad = g.newQuad(0,24,12,12,s:getDimensions())
    local sprite = Quad:new(s,game:tilesheetFrame(1,3),3+6*(i-1),4)
    self.node:addChild(sprite,0,i)
    local blink = Quad:new(s,game:tilesheetFrame(6,3))
    sprite:addChild(blink,0,1):setVisible(false)
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

  self.warnings = {}
  Beholder.group(self,function()
    -- Warnings are disabled
    -- Beholder.observe('warning',function(cx,cy,t,len)
    --   cx,cy = game:worldToScreen(cx,cy)
    --   for i=1,len do
    --     local x,y = game:worldToScreen(unpack(t[i]))
    --     local info,len = self.world:querySegmentWithCoords(cx,cy,x,y,function(item) return item.class.name == 'Segment' end)
    --     if len == 1 then
    --       Lume.push(self.warnings,info[1].x1,info[1].y1)
    --     end
    --   end
    -- end)
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
        love.audio.play(Assets.sounds.sfx_sounds_powerup9)
        countLives = countLives + 1
        local sprite = self.node:getChildByTag(countLives)
        sprite:setVisible(true)
        Timer.every(.1,function()
          local blink = sprite:getChildByTag(1)
          blink:setVisible(not blink:isVisible())
        end,11)
      end
    end)
  end)
end

function GamePlay:exitedState()
  self.node:setVisible(false)
  Beholder.stopObserving(self)
end


function GamePlay:addEnemyWarningSensors()
  local draw = function(self)
    if self.hidden then return end
    g.setColor(0,255,0,255)
    g.rectangle('fill',self.x,self.y,self.x+self.w,self.y+self.h)
    -- if self.isVertical then
      -- g.line(self.x+self.w/2,self.y,self.x+self.w/2,self.y+self.h)
    -- else
    --   g.line(self.x,self.y,self.x+self.w,self.y)
    -- end
  end
  local t = {
    {0,0,64,1},
    {64,0,65,64},
    {0,63,64,64},
    {0,0,1,64}
  }
  for i=1,4 do
    local segment = Segment:new(self.world,unpack(t[i]))
    segment:setVisible(false)
    segment.draw = draw
  end
end

function GamePlay:draw(l,t,w,h)
  HUD.draw(self,l,t,w,h)
  -- Warning are disabled
  -- g.setColor(255,0,0,255)
  -- g.points(self.warnings)
  -- self.warnings = {}
end

return GamePlay
