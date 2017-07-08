-- visible.lua

local Visible = Class('Visible')

function Visible:initialize()
end

function Visible:pointAt(x,y)
  return conf.sw * x, conf.sh * y
end

function Visible:screen()
  return 0,0,conf.sw,conf.sh
end

function Visible:rect(x,y,w,h)
  return x * conf.scaleX, y * conf.scaleY, w * conf.scaleX, h * conf.scaleY
end

function Visible:size()
  return conf.sw, conf.sh
end

-- From design point to screen pixel
function Visible:pointToPixel(x,y)
  return x * conf.scaleX, y * conf.scaleY
end

function Visible:left()
  return 0, conf.sh /2
end

function Visible:right()
  return conf.sw, conf.sh /2
end

function Visible:top()
  return conf.sw / 2, 0
end

function Visible:bottom()
  return conf.sw /2, conf.sh
end

function Visible:center()
  return conf.sw /2, conf.sh /2
end

function Visible:leftTop()
  return 0, 0
end

function Visible:rightTop()
  return conf.sw, 0
end

function Visible:leftBottom()
  return 0, conf.sh
end

function Visible:rightBottom()
  return conf.sw, conf.sh
end

return Visible
