-- laser.lua

local Body = require 'entities.base.body'
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
  if other.class.name == 'Segment' or other.class.name == 'Barrier' then
    return 'slide'
  end
  return nil
end

function Laser:update(dt)
  self:applyVelocity(dt)
  self:move(self.x,self.y,Laser.filter)
  local cx,cy = self:getCenter()
  local items,len = self.world:queryRect(cx-20,cy-20,40,40,function(item)
    return item.class.name == 'Player'
  end)
  if len > 0 then
    love.audio.play(Assets.sounds.sfx_alarm_loop6)
    local px,py = items[1]:getCenter()
    local dir = (Vector(px,py)-Vector(cx,cy)):normalized()
    self.vx,self.vy = dir.x * 25,dir.y * 25
    self.red:setVisible(true)
    local info,len = self.world:querySegmentWithCoords(cx,cy,px,py,function(item)
      return item.class.name == 'Player' or item.class.name == 'Segment' or item.class.name == 'Barrier'
    end)
    if len > 0 then
      self.info = { info[1].x1,info[1].y1 }
      if info[1].item.class.name == 'Player' then
        self.info = { info[1].x2,info[1].y2 }
        if info[1].item.isInvincible then
          self:cancelTimer()
        elseif not self.timer then
          self.timer = Timer.after(conf.laserTimeout,function()
            Beholder.trigger('killed')
            self:cancelTimer()
          end)
        end
      else
        self:cancelTimer()
      end
    end
  else
    self:cancelTimer()
    self.red:setVisible(false)
    self.vx,self.vy = 0,0
  end
  Body.update(self,dt)
end

function Laser:cancelTimer()
  if self.timer then self.timer = Timer.cancel(self.timer) end
end

function Laser:draw()
  Body.draw(self)
  if self.info then
    local cx,cy = self:getCenter()
    g.setColor(255,0,77,255)
    g.line(cx,cy,unpack(self.info))
    self.info = nil
  end
end

return Laser
