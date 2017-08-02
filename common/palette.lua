-- palette.lua

function createPalette()
  return {
    main = Hue.new('#4d78cc'),
    -- fg   = Hue.new('#de5a4c'),
    bg   = Hue.new('#000000'),
    -- line = c:desaturate_by(.5),
    -- fill = c:desaturate_by(.2),
    text = Hue.new('#fffff6'),
  }
end

function offsetHuePalette(o)
  for k,v in pairs(palette) do
    palette[k] = v:hue_offset(o)
  end
end

palette = createPalette()
-- offsetHuePalette(60)

function to_rgb(c,alpha)
  local r,g,b = Hue.hsl_to_rgb(c.H,c.S,c.L)
  return r*256,g*256,b*256,alpha or 255
  -- Using Lume.color is slower/more expensive
  -- return Lume.color(color:to_rgb(),255)
end

function rgb_to_color(r,g,b)
   r, g, b = r/255, g/255, b/255
  return Hue.new(Hue.rgb_to_hsl(r,g,b))
end

-- TODO run stress testing on both to_rgb functions
-- function to_rgb(color)
--   local r,g,b = Hue.hsl_to_rgb(color.H,color.S,color.L)
--   return r*256,g*256,b*256
-- end
