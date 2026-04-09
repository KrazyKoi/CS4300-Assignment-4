@group(0) @binding(0) var<uniform> res: vec2f;
@group(0) @binding(1) var<uniform> feed: f32;
@group(0) @binding(2) var<uniform> kill: f32;
@group(0) @binding(3) var<uniform> diffA: f32;
@group(0) @binding(4) var<uniform> diffB: f32;
@group(0) @binding(5) var<storage> statein: array<AB>;
@group(0) @binding(6) var<storage, read_write> stateout: array<AB>;

struct AB {
  A: f32,
  B: f32
}

fn index( x:i32, y:i32 ) -> u32 {
  let _res = vec2i(res);
  return u32( (y % _res.y) * _res.x + ( x % _res.x ) );
}

@compute
@workgroup_size(8,8)
fn cs( @builtin(global_invocation_id) _cell:vec3u ) {
  let cell = vec3i(_cell);

  let i = index(cell.x, cell.y);

  let laplacianA = (statein[ i ].A * -1.0) + 
                    (statein[ index(cell.x + 1, cell.y) ].A * 0.2) + 
                    (statein[ index(cell.x - 1, cell.y) ].A * 0.2) +
                    (statein[ index(cell.x, cell.y + 1) ].A * 0.2) + 
                    (statein[ index(cell.x, cell.y - 1) ].A * 0.2) +
                    (statein[ index(cell.x + 1, cell.y + 1) ].A * 0.05) + 
                    (statein[ index(cell.x - 1, cell.y - 1) ].A * 0.05) +
                    (statein[ index(cell.x - 1, cell.y + 1) ].A * 0.05) + 
                    (statein[ index(cell.x + 1, cell.y - 1) ].A * 0.05);
  let laplacianB = (statein[ i ].B * -1.0) + 
                    (statein[ index(cell.x + 1, cell.y) ].B * 0.2) + 
                    (statein[ index(cell.x - 1, cell.y) ].B * 0.2) +
                    (statein[ index(cell.x, cell.y + 1) ].B * 0.2) + 
                    (statein[ index(cell.x, cell.y - 1) ].B * 0.2) +
                    (statein[ index(cell.x + 1, cell.y + 1) ].B * 0.05) + 
                    (statein[ index(cell.x - 1, cell.y - 1) ].B * 0.05) +
                    (statein[ index(cell.x - 1, cell.y + 1) ].B * 0.05) + 
                    (statein[ index(cell.x + 1, cell.y - 1) ].B * 0.05);
  let A = statein[i].A + ((diffA * pow(laplacianA, 2) * statein[i].A) - (statein[i].A * pow(statein[i].B, 2)) + (feed * (1 - statein[i].A)));
  let B = statein[i].B + ((diffB * pow(laplacianB, 2) * statein[i].B) + (statein[i].A * pow(statein[i].B, 2)) - ((kill + feed) * statein[i].B));
  
  var out = AB();
  out.A = A;
  out.B = B;

  stateout[ i ] = out;
}
