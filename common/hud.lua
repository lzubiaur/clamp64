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
  for i=0,2 do
    local quad = g.newQuad(0,20,10,10,s:getDimensions())
    local live = Quad:new(s,quad,3+(6*i),4)
    self.node:addChild(live)
  end

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
  -- g.setColor(to_rgb(palette.text))
  -- g.printf('Level '..self.currentLevel,0,0,conf.width,'center')
  self.node:draw()
end

function HUD:update(dt)
end

return HUD
