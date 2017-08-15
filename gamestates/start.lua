-- start.lua

local Game = require 'common.game'
local Entity = require 'entities.base.entity'
local Button = require 'entities.ui.button'

local Start = Game:addState('Start')

function Start:enteredState()
  Log.info('Entered the state "Start"')

  Timer.clear()

  if not self.music then
    self.music = love.audio.newSource('resources/music/dream_candy.xm','stream')
    self.music:setVolume(.7)
    self.music:setLooping(true)
    love.audio.play(self.music)
  end

  self:createWorld()
  self:createCamera()
  self:setFont('resources/fonts/pzim3x5.ttf',self.visible:pointToPixel(10))
  -- self:setFont('resources/fonts/pzim3x5.fnt','resources/fonts/pzim3x5.png')

  local ent = Entity:new(self.world,self.visible:screen())
  Beholder.group(self,function()
    Beholder.observe('Released',ent,function(x,y)
      self:startGame()
    end)
  end)

  self:createHUD('Start')

  self:fadeIn(function()
    Push:setShader()
  end)

  self.ps = g.newParticleSystem(Assets.img.star,100)
  self.ps:setParticleLifetime(1)
  self.ps:setLinearAcceleration(0,0,10,10)
  self.ps:setAreaSpread('normal',32,32)
  self.ps:setLinearDamping(0,-2)
  self.ps:setRadialAcceleration(20,50)
  self.sx,self.sy = .05,.05
  self.tween = Tween.new(.5,self,{sx=1,sy=1})
  self.ps:emit(32)
  self.ps:setColors({32,51,123},{255,241,232})
end

function Start:exitedState()
  Beholder.stopObserving(self)
end

function Start:startGame()
  self.state.lives = conf.defaultLivesCount
  self.state.cli = 1
  -- self:fadeOut(function()
    Push:setShader()
    self:gotoState('Play')
  -- end)
end

function Start:keypressed(key, scancode, isRepeat)
  if key == 'space' or key == 'enter' then
    self:startGame()
  -- On Android the back button is mapped to the 'escape' key
  elseif key == 'escape' then
    love.event.push('quit')
  end
end

function Start:update(dt)
  self.ps:update(dt)
  Game.update(self,dt)
  self.ps:emit(1)
  self.tween:update(dt)
end

function Start:drawBeforeCamera()
  g.draw(Assets.img.bg,0,0)
  g.draw(self.ps,32,22)
  g.draw(Assets.img.logo,32,32,0,self.sx,self.sy,32,32)
end

return Start
