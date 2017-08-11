-- entities/transition.lua

local Entity = require 'entities.base.entity'

local Transition = Class('Transition',Entity):include(Stateful)

function Transition:initialize(world,pattern,len,backwards,callback)
  Entity.initialize(self,world,0,0,64,64)
  self.img,self.quad,self.callback = {},{},callback

  for i=1,len do
    local name = string.format(pattern,i)
    local image = Assets.img.patterns[name]
    image:setWrap('repeat','repeat')
    table.insert(self.img,image)
    table.insert(self.quad,g.newQuad(0,0,64,64,image:getDimensions()))
  end
  if backwards then
    self.i = len
    self.tween = Tween.new(.4,self,{i = 1})
  else
    self.i = 1
    self.tween = Tween.new(.4,self,{i = len})
  end
end

function Transition:update(dt)
  if self.tween:update(dt) then
    -- self:destroy()
    if self.callback then self.callback() end
  end
  self.i = math.ceil(self.i)
end

function Transition:draw()
  g.draw(self.img[self.i],self.quad[self.i],self.x,self.y)
end

return Transition
