local Entity = require 'entities.base.entity'
local Button = require 'entities.ui.button'
local ImageButton = require 'entities.ui.imagebutton'

local HUD = Class('HUD')

function HUD:initialize(opt)
  opt = opt or {}

  self.world = Bump.newWorld(conf.cellSize)

  -- Quit gameplay (goto main menu)
  self.back = ImageButton:new(self.world,0,0,{
    path = 'resources/img/arrow-left.png',
    onSelected = function()
      Beholder.trigger('GotoMainMenu')
    end
  })
  Beholder.group(self,function()
    Beholder.observe('Win',function()
      self.back.hidden = true
    end)
  end)
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
end

function HUD:update(dt)
end

return HUD
