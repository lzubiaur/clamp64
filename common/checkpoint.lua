-- checkpoint.lua

local Checkpoint = Class('Checkpoint')

function Checkpoint:initialize(world)
  self.pos,self.world = {},world
  Timer.every(1,function()
    self:trigger()
  end)
  self:trigger()
end

function Checkpoint:trigger()
  local t = {}
  Beholder.trigger('checkpoint',t)
  table.insert(self.pos,t)
  if #self.pos > 10 then
    table.remove(self.pos,1)
  end
end

function Checkpoint:getLastPosition()
  local p = self.pos
  for i=1,#p do
    local x,y = p[i][1],p[i][2]
    local item,len = self.world:queryPoint(x,y)
    if len == 0 then return x,y end
  end
end

return Checkpoint
