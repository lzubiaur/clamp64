//from "Share a Shader" forum thread

// Uniform (extern) variable can't be initialized on Android
extern number shift;
extern number alpha;

// vec2 scale = vec2(1.0/800.0, 1.0/600.0);
// vec2 scale = vec2(0.00125, 0.0016);
// amplitude/direction
vec2 scale = vec2(0.002,-0.002);

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc)
{
  vec4 c = Texel(texture, tc);
  return vec4(c.r,c.g,c.b,alpha);
  // vec4 r = Texel(texture, vec2(tc.x + shift * scale.x, tc.y - shift * scale.y));
  // vec4 g = Texel(texture, vec2(tc.x, tc.y + shift*scale.y));
  // vec4 b = Texel(texture, vec2(tc.x - shift*scale.x, tc.y - shift*scale.y));
}
