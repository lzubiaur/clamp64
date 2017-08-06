-- start.lua

local Game = require 'common.game'
local Entity = require 'entities.base.entity'
local Button = require 'entities.ui.button'
local ImageButton = require 'entities.ui.imagebutton'

local Start = Game:addState('Start')

function Start:enteredState()
  Log.info('Entered the state "Start"')

  Timer.clear()

  if not self.music then
    self.music = love.audio.newSource('resources/music/dream_candy.xm','stream')
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
      self:gotoState('Play')
    end)
  end)

  -- local x,y,w,h = self.visible:rectCenter(320,180,70,40)
  -- Button:new(self.world,x,y,w,h, {
  --   onSelected = function()
  --     self:gotoState('Play')
  --   end,
  --   text='Play!',
  -- })
end

function Start:exitedState()
  Beholder.stopObserving(self)
end

-- function Start:poppedState()
--   self.swallowTouch = false
-- end

function Start:keypressed(key, scancode, isRepeat)
  if key == 'space' then
    self:gotoState('Play')
  -- On Android the back button is mapped to the 'escape' key
  elseif key == 'escape' then
    love.event.push('quit')
  end
end

function Start:drawAfterCamera()
  g.draw(Assets.img.mainmenu,0,0)
end

return Start
