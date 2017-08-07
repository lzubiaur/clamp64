-- entities/ui/progressbar.lua

local Entity = require 'entities.base.entity'

local ProgressBar = Class('ProgressBar',Entity):include(Stateful)

function ProgressBar:initialize(world,x,y,w,h,image,percent,opt)
  Entity.initialize(self,world,x,y,w,h,opt)

  local stencil = function()
    g.rectangle('fill',self.x,self.y,self.w*percent,self.w)
  end

  self.setPercent = function(self,value)
    percent = value
  end

  self.draw = function(self)
    g.stencil(stencil,'replace',1)
    g.setStencilTest('greater',0)
    g.draw(image,self.x,self.y)
    g.setStencilTest()
  end

end

return ProgressBar
