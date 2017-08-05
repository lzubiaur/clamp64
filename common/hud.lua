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
  for i=0,game.state.lives-1 do
    local quad = g.newQuad(0,20,10,10,s:getDimensions())
    local live = Quad:new(s,quad,3+(6*i),4)
    self.node:addChild(live)
  end

  local quad = g.newQuad(30,20,20,10,s:getDimensions())
  self.node:addChild(Quad:new(s,quad,conf.sw-10,4))

  self.progress = 0
  Beholder.group(self,function()
    Beholder.observe('progress',function(value)
      self.progress = Lume.clamp(value,0,1)
    end)
    Beholder.observe('killed',function()
      if game.state.lives > 0 then
        self.node:getChild(game.state.lives):setVisible(false)
      end
    end)
  end)

end

function HUD:destroy()
  Beholder.stopObserving(self)
end

function HUD:createSwallowTouchLayer()
  self.swallowTouch = true
  self.swallowLayer = Entity:new(self.world,0,0,conf.width,conf.height,{zOrder=11})
  self.swallowLayer.draw = function()
    g.setColor(30,30,30,200)
    g.rectangle('fill',30,0,conf.width-60,conf.height)
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
  g.line(46,4,46+16*self.progress,4)
  g.setColor(0,255,56,255)
  g.line(46,3,46+16*self.progress,3)
  self.node:draw()
end

function HUD:update(dt)
end

return HUD
