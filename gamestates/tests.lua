-- teststate.lua
local Game = require 'common.game'
local Test = require 'tests.test'
local EntityTest = require 'tests.entity'
local TouchTest = require 'tests.touch'
local TestStates = require 'tests.states'
local TestMultiRes = require 'tests.multires'
local TestUI = require 'tests.ui'
local TestCamera = require 'tests.camera'
local TestHud = require 'tests.hud'

local TestState = Game:addState('TestState')

local tests = { TestMultiRes, EntityTest, TouchTest, TestUI, TestCamera, TestHud }

function TestState:enteredState()
  if not self.testid then self.testid = 1 end
  Log.info('Run test',self.testid)
  -- self.font = g.newFont('resources/fonts/roboto-condensed.fnt','resources/fonts/roboto-condensed.png')
  -- self.fontHeight = self.font:getHeight()
  self:createWorld()
  self:createCamera()

  self.test = tests[self.testid]:new(self.world)
end

function TestState:exitedState()
  Timer.clear()
  self.test:destroy()
end

local text = {}
local function log(id,format,...)
  text[id] = format and string.format(format,...) or nil
end

function TestState:drawInfo()
  local y,h = 0,g.getFont():getHeight()
  for _,s in pairs(text) do
    g.print(s,0,y)
    y = y + h
  end
end

function TestState:updateGridInfo()
  local mx,my = 0,0
  if love.mouse then
    mx,my = Push:toGame(love.mouse.getPosition())
    mx,my = mx and mx or 0, my and my or 0
  elseif love.touch then
    local touches = love.touch.getTouches()
    if #touches > 0 then
      mx,my = love.touch.getPosition(touches[1])
    end
  end
  local oScreenx, oScreeny = self.camera:toScreen(0, 0)
  local mWorldx, mWorldy = self.camera:toWorld(mx, my)
  local camx, camy = self.camera:getPosition()
  local scale = self.camera:getScale()
  local cx, cy = self.grid:convertCoords("screen","cell", mx, my)
  log('cam','Camera position: %.3f,%3f',camx,camy)
  log('scale','Camera zoom: %.3f',scale)
  log('mouse','Mouse position on Grid: %.3f %.3f',mWorldx,mWorldy)
  log('cell','Cell coordinate under mouse: %.0f,%.0f',cx,cy)
  log('screen','Grid origin position on screen: %.3f,%.3f',oScreenx,oScreeny)
  log('fps','FPS: %3f. Average frame time: %.3f ms',love.timer.getFPS(),1000 * love.timer.getAverageDelta())
end

function TestState:update(dt)
  self:updateGridInfo()
  Game.update(self,dt)
  self.test:update(dt)
end

function TestState:drawAfterCamera(l,t,w,h)
  self.test:drawAfterCamera(l,t,w,h)
  Game.drawAfterCamera(self,l,t,w,h)
end

function TestState:drawBeforeCamera(l,t,w,h)
  self.grid:draw()
  self:drawInfo()
  self.test:drawBeforeCamera(l,t,w,h)
  Game.drawBeforeCamera(self,l,t,w,h)
end

function TestState:keypressed(key, scancode, isrepeat)
  if key == 'space' then
    if self.testid < #tests then
      self.testid = self.testid + 1
    else
      self.testid = 1
    end
    self:gotoState('TestState')
  elseif key == 'escape' then
    love.event.push('quit')
  end
  self.test:keypressed(key,scancode,isrepeat)
end

return TestState
