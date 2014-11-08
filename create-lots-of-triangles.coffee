NAMESPACE = 'http://www.w3.org/2000/svg'
# ステージサイズ
STAGE_WIDTH = 1000
STAGE_HEIGHT = 563
# 辺の長さ
SIDE = 100
SIDE_HALF = SIDE / 2
HEIGHT = SIDE_HALF * Math.sqrt 3

class Point
  @lerp: (a, b, ratio) -> b.sub(a).mul(ratio).add(a)
  constructor: (@x, @y) ->
  add: ({x, y}) -> new Point @x + x, @y + y
  sub: ({x, y}) -> new Point @x - x, @y - y
  mul: (v) -> new Point @x * v, @y * v
  div: (v) -> new Point @x / v, @y / v
  toString: -> "#{@x>>0},#{@y>>0}"

# polygonのstrokeはinsetやoutsetなど線をパスのどの位置に描画するかのオプションがSVGの仕様に定義されていない。
# clipPathによって描きたい図形と同じ形のクリッピングパスを作ってマスキングする。
clipIndex = 0
createTriangle = (a, b, c) ->
  clipId = "clip#{clipIndex++}"

  center = a.add(b).add(c).div(3)
  console.log center

  g = document.createElementNS NAMESPACE, 'g'

  # クリッピング用の三角形のDOMを追加
  clipPath = document.createElementNS NAMESPACE, 'clipPath'
  clipPath.setAttribute 'id', clipId
  polygon = document.createElementNS NAMESPACE, 'polygon'
  # そのままだと若干の隙間が開くので三角形の中心から外側に拡張したクリップにする
  # polygon.setAttribute 'points', "#{a.toString()} #{b.toString()} #{c.toString()}"
  polygon.setAttribute 'points', "#{Point.lerp(center, a, 1.05).toString()} #{Point.lerp(center, b, 1.05).toString()} #{Point.lerp(center, c, 1.05).toString()}"
  clipPath.appendChild polygon
  g.appendChild clipPath

  # 描画用の三角形のDOMを追加
  polygon = document.createElementNS NAMESPACE, 'polygon'
  polygon.setAttribute 'points', "#{a.toString()} #{b.toString()} #{c.toString()}"
  polygon.setAttribute 'clip-path', "url(##{clipId})"
  polygon.setAttribute 'style', 'fill: transparent; stroke: red; stroke-width: 10;'
  polygon.addEventListener 'mouseover', onMouseOver
  polygon.addEventListener 'mouseout', onMouseOut
  polygon.addEventListener 'click', onClick
  g.appendChild polygon

  g

# ポリゴンにマウスオーバーした際のイベントハンドラ
# アニメーションしてもよい
onMouseOver = (e) ->
  polygon = e.currentTarget
  polygon.setAttribute 'style', 'fill: transparent; stroke: red; stroke-width: 30;'

# ポリゴンからマウスアウトした際のイベントハンドラ
# アニメーションしてもよい
onMouseOut = (e) ->
  polygon = e.currentTarget
  polygon.setAttribute 'style', 'fill: transparent; stroke: red; stroke-width: 10;'

# click時に何かしてもよい
onClick = (e) ->
  polygon = e.currentTarget
  index = Array.prototype.indexOf.call polygon.parentNode.parentNode.children, polygon.parentNode
  alert "#{index}番目の要素です"

# coffeescriptを非同期コンパイルしている関係上、DOMのロードは完了しているのでDOMContentLoadedは待たない。
# document.addEventListener 'DOMContentLoaded', ->
svg = document.createElementNS NAMESPACE, 'svg'
svg.setAttribute 'width', STAGE_WIDTH
svg.setAttribute 'height', STAGE_HEIGHT
svg.setAttribute 'viewBox', "0 0 #{STAGE_WIDTH} #{STAGE_HEIGHT}"
for iy in [0..STAGE_HEIGHT / HEIGHT] by 1
  for ix in [0..STAGE_WIDTH / SIDE * 2 + 1] by 1
    # xのインデックスから△か▽を割り振る
    triangle = if ((ix + iy) % 2) is 0
      ix = ix / 2 >> 0
      createTriangle new Point(SIDE * (ix + 0.5), HEIGHT * iy),
        new Point(SIDE * (ix + 1), HEIGHT * (iy + 1)),
        new Point(SIDE * ix, HEIGHT * (iy + 1))
    else
      ix = ix / 2 >> 0
      createTriangle new Point(SIDE * (ix - 0.5), HEIGHT * iy),
        new Point(SIDE * (ix + 0.5), HEIGHT * iy),
        new Point(SIDE * ix, HEIGHT * (iy + 1))
    svg.appendChild triangle
document.querySelector('body').appendChild svg
# , false
