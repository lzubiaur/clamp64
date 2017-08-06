local Entity = require 'entities.base.entity'
local Button = require 'entities.ui.button'
local ImageButton = require 'entities.ui.imagebutton'
local Quad = require 'entities.base.quad'
local Node = require 'entities.base.node'

local HUD = Class('HUD')

function HUD:initialize(opt)
  opt = opt or {}

  self.world = Bump.newWorld(conf.cellSize)

  -- Quit gameplay (goto main menu)
  -- self.back = ImageButton:new(self.world,0,0,{
  --   path = 'resources/img/arrow-left.png',
  --   onSelected = function()
  --     Beholder.trigger('GotoMainMenu')
  --   end
  -- })
  -- Beholder.group(self,function()
  --   Beholder.observe('Win',function()
  --     self.back.hidden = true
  --   end)
  -- end)

  self.node = Node:new(game.visible:screen())

  local s = Assets.img.tilesheet
  local countLives = game.state.lives
  for i=0,countLives-1 do
    local quad = g.newQuad(0,24,12,12,s:getDimensions())
    local sprite = Quad:new(s,quad,3+(6*i),4)
    self.node:addChild(sprite,0,i+1)
  end

  -- Progress bar sprite
  local quad = g.newQuad(36,24,24,12,s:getDimensions())
  self.node:addChild(Quad:new(s,quad,conf.sw-12,4))

  self.progress = 0
  Beholder.group(self,function()
    Beholder.observe('progress',function(value)
      self.progress = math.ceil(Lume.clamp(value,0,1)*100)/100
    end)
    Beholder.observe('lose',function()
      local child = self.node:getChildByTag(countLives):setVisible(false)
      countLives = countLives - 1
    end)
  end)

end

function HUD:destroy()
  Beholder.stopObserving(self)
end

function HUD:createSwallowTouchLayer()
  self.swallowTouch = true
  local x,y,w,h = game.visible:screen()
  self.swallowLayer = Entity:new(self.world,x,y,w,h,{zOrder=11})
  self.swallowLayer.draw = function()
    g.setColor(30,30,30,200)
    g.rectangle('fill',30,0,conf.width-60,conf.height)
  end
end

function HUD:removeSwallowTouchLayer()
  if self.swallowLayer then
    self.swallowLayer:destroy()
  end
end

function HUD:draw(l,t,w,h)
  local items,len = self.world:queryRect(l,t,w,h)
  table.sort(items,Entity.sortByZOrderAsc)
  for i=1,len do
    if not items[i].hidden then
      items[i]:draw()
    end
  end
  g.setColor(0,226,50,255)
  g.line(44,4,44+16*self.progress,4)
  g.setColor(0,255,56,255)
  g.line(44,3,44+16*self.progress,3)
  self.node:draw()
end

function HUD:update(dt)
end

return HUD
