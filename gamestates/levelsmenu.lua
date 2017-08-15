-- gamestate/levelsmenu.lua
local Game = require 'common.game'
local Button = require 'entities.ui.button'

local LevelsMenu = Game:addState('LevelsMenu')

function LevelsMenu:enteredState()
  self:createHUD()
  self.hud:gotoState('LevelsMenu')


  local level,points,d,unlocked = 1,{},0,#self.state.levels
  for j=1,3 do
    local d = 1 - Lume.pingpong(j)
    for i=1,4 do
      local button = self:createButton(math.abs(d*4-i)+d,j,level)
      if level > unlocked + 1 then
        button:setEnabled(false)
      end
      Lume.push(points,button:getCenter())
      level = level + 1
    end
  end
  self.points = points
  self:fadeIn(function()
    Push:setShader()
  end)
end

function LevelsMenu:drawBeforeCamera()
  g.draw(Assets.img.levelsmenu,0,0)
  g.setColor(171,82,54,255)
  g.line(self.points)
end

function LevelsMenu:createButton(i,j,level)
  local w,h,sx,sy = 10,10,3,4
  local x = sx + (i-1) * (w+sx)
  local y = sy + (j-1) * (h+sy)
  return Button:new(self.world,x,y,w,h,{
    text = tostring(level),
    corner = 0, os = 1, oy = 1,
    color = {255,163,0,255},
    textColor = {255,241,233,255},
    onSelected = function()
      self.state.cli = level
      self:gotoState('Play')
    end
  })
end

function LevelsMenu:keypressed(key, scancode, isRepeat)
  -- On Android the back button is mapped to the 'escape' key
  if key == 'escape' then
    self:gotoState('Start')
  end
end

return LevelsMenu
