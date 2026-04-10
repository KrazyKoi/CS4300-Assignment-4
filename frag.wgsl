@group(0) @binding(0) var<uniform> res:   vec2f;
@group(0) @binding(1) var<storage> state: array<AB>;

struct AB {
  A: f32,
  B: f32
}


@fragment 
fn fs( @builtin(position) pos : vec4f ) -> @location(0) vec4f {

  let idx : u32 = u32( floor(pos.y) * res.x + floor(pos.x));
  let v : AB = state[ idx ];
  let vA = v.A;
  let vB = v.B;
  return vec4f(vA, vA*0.5, vB, 1.);
}
