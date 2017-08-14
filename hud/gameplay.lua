-- hud/gameplay.lua

local HUD = require 'hud.base'
local Quad = require 'entities.base.quad'
local ProgressBar = require 'entities.ui.progressbar'
local Segment = require 'entities.segment'
local Label = require 'entities.ui.label'

local GamePlay = HUD:addState('GamePlay')

function GamePlay:enteredState()
  local s = Assets.img.tilesheet

  self:addTells()

  -- Lives
  for i=1,conf.maxLives do
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
    Beholder.observe('warning',function(cx,cy,t,len)
      -- cx,cy = game:worldToScreen(cx,cy)
      for i=1,len do
        local x,y = game:worldToScreen(unpack(t[i]))
        local info,len = self.world:querySegmentWithCoords(32,32,x,y,function(item) return item.class.name == 'Segment' end)
        if len == 1 then
          Lume.push(self.warnings,{info[1].x1,info[1].y1})
        end
      end
    end)
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
    Beholder.observe('slowmo',function(obj,timeout)
      love.audio.play(Assets.sounds.sfx_sounds_powerup16)
      local i = timeout
      local label = self.node:addChild(Label:new(self.world,0,10,tostring(i),{limit=64}))
      local countdown = self.timer:every(1,function()
        i = i - 1
        label.text = tostring(i)
        if i < 0 then label:destroy() end
      end,i+1)
    end)
    Beholder.observe('xup',function()
      if countLives < conf.maxLives then
        love.audio.play(Assets.sounds.sfx_sounds_powerup9)
        countLives = countLives + 1
        local sprite = self.node:getChildByTag(countLives)
        sprite:setVisible(true)
        self.timer:every(.1,function()
          local blink = sprite:getChildByTag(1)
          blink:setVisible(not blink:isVisible())
        end,11)
      end
    end)
    local after
    Beholder.observe('area',function(area)
      area = math.ceil(area * conf.areaScoreScale)
      if area > 1000 * conf.areaScoreScale then
        if self.label then
          self.label = self.label:destroy()
          after = self.timer:cancel(after)
        end
        love.audio.play(Assets.sounds.sfx_sounds_powerup6)
        self.label = self.node:addChild(Label:new(self.world,0,10,'+'..area,{limit=64}))
        after = self.timer:after(1,function() self.label = self.label:destroy() end)
      end
    end)
  end)
end

function GamePlay:exitedState()
  Beholder.stopObserving(self)
  self.timer:clear()
  self.node:setVisible(false)
  if self.label then self.label = self.label:destroy() end
end

function GamePlay:addTells()
  self.tells = {}
  for i=1,conf.tellsCount do
    local quad = Quad:new(Assets.img.tilesheet,game:tilesheetFrame(4,7))
    table.insert(self.tells,quad)
    quad:setVisible(false)
    self.node:addChild(quad)
  end

  local t = {
    {0,0,64,0},
    {64,0,64,64},
    {0,64,64,64},
    {0,0,0,64}
  }
  for i=1,4 do
    local segment = Segment:new(self.world,unpack(t[i]))
    segment:setVisible(false)
  end
end

local count,len,tell
function GamePlay:update(dt)
  count,len = 0,#self.tells
  for i=1,#self.warnings do
    if i > len then break end
    count,tell = i,self.tells[i]
    tell:setVisible(true)
    local x,y = unpack(self.warnings[i])
    x,y = math.floor(x),math.floor(y)
    -- Rotate
    if x == 0 then x = 3; tell.angle = math.rad(90)
    elseif y == 0 then y = 3; tell.angle = math.rad(180)
    elseif x == 63 then x=61; tell.angle = math.rad(270)
    else y = 61; tell.angle = 0 end
    tell:setPosition(x,y)
  end
  count = count + 1
  for i=count,len do
    self.tells[i]:setVisible(false)
  end
  self.warnings = {}
  HUD.update(self,dt)
end

return GamePlay
