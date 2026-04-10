import { default as seagulls } from '../../gulls.js'
import { default as Mouse } from './mouse.js'

const sg      = await seagulls.init(),
      frag    = await seagulls.import( './frag.wgsl' ),
      compute = await seagulls.import( './compute.wgsl' ),
      render  = seagulls.constants.vertex + frag,
      size    = (window.innerWidth * window.innerHeight * 2),
      state   = new Float32Array( size )

Mouse.init()

for( let i = 0; i < size; i += 2 ) {
  state[ i + 1 ] = 0
  state[ i ] = 1
}

//for( let i = 1100; i < 2100; i ++ ) {
//  for( let j = 150; j < 550; j ++ ) {
//      state[ i + (j * window.innerWidth * 2)] = 1
//  }
//}

const statebuffer1 = sg.buffer( state )
const statebuffer2 = sg.buffer( state )
const res = sg.uniform([ window.innerWidth, window.innerHeight ])

const renderPass = await sg.render({
  shader: render,
  data: [
    res,
    sg.pingpong( statebuffer1, statebuffer2 )
  ]
})


const feedSlider = document.querySelector('#feedSlider')
let feed_u = sg.uniform( feedSlider.value )
const killSlider = document.querySelector('#killSlider')
let kill_u = sg.uniform( killSlider.value )
const ASlider = document.querySelector('#ASlider')
let A_u = sg.uniform( ASlider.value )
const BSlider = document.querySelector('#BSlider')
let B_u = sg.uniform( BSlider.value )
const mouse = sg.uniform( Mouse.values )
const DSlider = document.querySelector('#DSlider')
let D_u = sg.uniform( DSlider.value )

const computePass = sg.compute({
  shader: compute,
  data: [ 
    res,
    feed_u,
    kill_u,
    A_u,
    B_u,
    mouse,
    D_u,
    sg.pingpong( statebuffer1, statebuffer2 ) ],
  dispatchCount:  [Math.round(seagulls.width / 8), Math.round(seagulls.height/8), 1],
  onframe() { mouse.value = Mouse.values }
})

feedSlider.oninput = () => feed_u.value = feedSlider.value
killSlider.oninput = () => kill_u.value = killSlider.value
ASlider.oninput = () => A_u.value = ASlider.value
BSlider.oninput = () => B_u.value = BSlider.value
DSlider.oninput = () => D_u.value = DSlider.value

sg.run( computePass, renderPass )
