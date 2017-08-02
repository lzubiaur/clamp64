-- hud.lua

local Test = require 'tests.test'
local Entity = require 'entities.base.entity'
local Node = require 'entities.base.node'
local Sprite = require 'entities.base.sprite'
local Button = require 'entities.ui.button'
local Label = require 'entities.ui.label'

local HudTest = Class('HudTest',Test)

function HudTest:initialize(world)
  Test.initialize(self,world)
  Log.info('Entered state tests')
  self.name = 'Test Head-up display (HUD)'

  local visible = game.visible

  self:setResolution(960,540,conf.width+500,conf.height+500)
  game:createHUD()

  local x,y = visible:center()
  local w,h = visible:pointToPixel(90,20)

  Button:new(game.hud.world, x,y, w,h, {
    text = 'Button',
    onSelected = function()
      Log.info('Button touched')
    end
  })

  x,y = visible:pointAt(.5,.6)
  Label:new(game.hud.world, x,y, 'This is a label.')

  local ax,ay
  local entity = Entity:new(world,x,y,60,50)

  entity:addChild(Label:new(world,x,y+20,'drag me'))

  Beholder.observe('Pressed',entity,function(x,y)
    ax,ay = entity:getLocalPoint(x,y)
    Log.info('pressed',x,y)
  end)

  Beholder.observe('Moved',entity,function(x,y,dx,dy)
    entity:teleport(x-ax,y-ay)
  end)

  Beholder.observe('Released',entity,function(x,y)
    Log.info('released',x,y)
  end)

  game.follow = entity
end

function HudTest:destroy()
  game.follow = nil
  game.hud = nil
end

function HudTest:keypressed(key, scancode, isrepeat)
  local filter = function(item,other)
    return false
  end
  local x,y = game.follow:getPosition()
  if key == 'up' then
    game.follow:move(x,y-20,filter)
  elseif key == 'down' then
    game.follow:move(x,y+20,filter)
  elseif key == 'left' then
    game.follow:move(x-20,y,filter)
  elseif key == 'right' then
    game.follow:move(x+20,y,filter)
  end
end

return HudTest
