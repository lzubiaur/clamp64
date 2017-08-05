-- laser.lua

local Body = require 'entities.base.Body'
local Quad = require 'entities.base.quad'

local Laser = Class('Laser',Body)

function Laser:initialize(world,x,y)
  local w,h = game.visible:pointToPixel(8,8)
  Body.initialize(self,world,x,y,w,h)

  local quad = g.newQuad(24,24,12,12,Assets.img.tilesheet:getDimensions())
  self:addSprite(Quad:new(Assets.img.tilesheet,quad,4,4))

  local quad = g.newQuad(60,12,12,12,Assets.img.tilesheet:getDimensions())
  self.red = Quad:new(Assets.img.tilesheet,quad,4,4)
  self.red:setVisible(false)
  self:addSprite(self.red)
end

function Laser:filter(other)
  return other.class.name == 'Segment' and 'bounce' or nil
end

function Laser:update(dt)
  self:applyVelocity(dt)
  self:handleCollisions()
  local cx,cy = self:getCenter()
  local items,len = self.world:queryRect(cx-20,cy-20,40,40,function(item)
    return item.class.name == 'Player'
  end)
  if len > 0 then
    local px,py = items[1]:getCenter()
    local dir = (Vector(px,py)-Vector(cx,cy)):normalized()
    self.vx,self.vy = dir.x * 25,dir.y * 25
    self.red:setVisible(true)
    local info,len = self.world:querySegmentWithCoords(cx,cy,px,py,function(item)
      return item.class.name == 'Player' or item.class.name == 'Segment'
    end)
    if len > 0 then
      self.info = info[1]
      if info[1].item.class.name == 'Player' and not self.timer then
        self.timer = Timer.after(3,function()
          Beholder.trigger('killed')
          self.timer = Timer.cancel(self.timer)
        end)
      end
    end
  else
    if self.timer then
      self.timer = Timer.cancel(self.timer)
    end
    self.red:setVisible(false)
    self.vx,self.vy = 0,0
  end
  Body.update(self,dt)
end

function Laser:handleCollisions()
  local cols,len = self:move(self.x,self.y,Laser.filter)
  for i=1,len do
    local other = cols[i].other
    if other.class.name == 'Segment' then
      local n = cols[i].normal
      self:applyCollisionNormal(self.x*n.x,self.y*n.y,1)
    -- elseif other.class.name == 'Player' then
    --   Beholder.trigger('killed',self)
    end
  end
end

function Laser:draw()
  Body.draw(self)
  if self.info then
    local cx,cy = self:getCenter()
    g.setColor(255,0,77,255)
    g.line(cx,cy,self.info.x2,self.info.y2)
    self.info = nil
  end
end

return Laser
