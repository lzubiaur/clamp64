-- hud/win.lua

local HUD = require 'hud.base'
local Label = require 'entities.ui.label'
local Quad = require 'entities.base.quad'
local Node = require 'entities.base.node'
local ColorLayer = require 'entities.base.colorlayer'

local Win = HUD:addState('Win')

local function levelClearedText(i)
  return {
    {255,241,232}, 'Level ',
    {255,163,0}, tostring(i),
    {255,241,232}, ' cleared!'
  }
end

function Win:enteredState(score)
  self:createSwallowTouchLayer(function()
    Beholder.trigger('NextLevel')
  end)

  self:createDitheredLayer()
  self.node:addChild(Label:new(self.world,0,10,levelClearedText(game.state.cli),{limit=64}))
  if score.old < score.new then
    self:createNewHighScore(score)
  else
    self.node:addChild(Label:new(self.world,0,25,'Score:'..score.new,{limit=64}))
  end
end

function Win:createDitheredLayer()
  self.node:addChild(ColorLayer:new(0,0,64,64,{color={0,30,63,120}}))
  local ditter = Assets.img.ditter
  ditter:setWrap('repeat','repeat')
  local quad = g.newQuad(0,0,64,64,ditter:getDimensions())
  quad = Quad:new(ditter,quad,0,0,{color={0,30,63,100},ax=0,ay=0})
  self.node:addChild(quad)
end

function Win:createNewHighScore(score)
  self.node:addChild(Label:new(self.world,0,25,'New High Score!',{color={255,163,0},limit=64}))
  local sl = self.node:addChild(Label:new(self.world,0,40,'0',{limit=64}))
  sl.score = score.old
  sl.update = function(self,dt)
    self.text = tostring(math.ceil(self.score))
  end
  local diamonds = score.diamonds * conf.diamondScore
  self.timer:script(function(wait)
    wait(.4)
    self.tween = Tween.new(1,sl,{ score = score.new - diamonds })
    wait(1.4)
    self.node:addChild(Quad:new(Assets.img.tilesheet,game:tilesheetFrame(2,8),28,50),1)
    local label = self.node:addChild(Label:new(self.world,34,50,'x0'))
    for i=1,score.diamonds do
      sl.score = sl.score + conf.diamondScore
      label.text = 'x'..i
      love.audio.play(Assets.sounds.sfx_coin_cluster3)
      wait(.4)
    end
  end)
  love.audio.play(Assets.sounds.sfx_sounds_fanfare1)
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
