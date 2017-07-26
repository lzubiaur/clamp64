-- camera.lua

local Test = require 'tests.test'
local Entity = require 'entities.base.entity'
local Node = require 'entities.base.node'
local Sprite = require 'entities.base.sprite'
local Button = require 'entities.ui.button'
local Label = require 'entities.ui.label'

local TestCamera = Class('TestCamera',Test)

function TestCamera:initialize(world)
  Test.initialize(self,world)
  self.name = 'Test Camera'

  love.keyboard.setKeyRepeat(true)

  local visible = game.visible

  love.window.setMode(1024,768)
  setupMultiResolution()
  local w,h = visible:pointToPixel(conf.width + 200,conf.height + 200)
  game:createCamera(w,h)

  local rand = love.math.random
  for i=1,200 do
    local x,y,w,h = game.visible:rectCenter(rand(w),rand(h),rand(20,40),rand(20,40))
    Entity:new(world,x,y,w,h)
  end

  game.follow = Entity:new(world,visible:rect(100,100,20,20))
  game.follow.color = { 0,255,0,255 }

end

function TestCamera:draw()
end

function TestCamera:keypressed(key, scancode, isrepeat)
  local x,y = game.follow:getPosition()
  if key == 'up' then
    game.follow:move(x,y-20)
  elseif key == 'down' then
    game.follow:move(x,y+20)
  elseif key == 'left' then
    game.follow:move(x-20,y)
  elseif key == 'right' then
    game.follow:move(x+20,y)
  end
end


return TestCamera
