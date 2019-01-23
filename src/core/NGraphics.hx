package core;

import core.FillUtils.FillMethod;
import utils.ToolSet;
import gml.ds.ArrayList;
import gml.Mathf;
import gml.NativeArray;
import gml.ds.Color;
import geom.Point;
import geom.Rectangle;

@:keep
@:native("ngraphics")
class NGraphics {
    // 启用状态
    public var enable:Bool = true;

    // 三角形顶点索引
    public var vertIndex:Array<Int> = cast 0;

    // 顶点数量
    public var vertCount:Int = 0;

    // 顶点属性
    public var texture:NTexture;
    public var pos:Array<Point>;
    public var uv:Array<Point>;
    public var colors:Array<Color>;

    // 构造
    public function new() { }

    // 清理
    public function clearMesh():Void {
        this.vertCount = 0;
    }

    /// 常用的三角形顶点索引,避免每次new
    ///  1 - 2
    ///  | \ |
    ///  0 - 3
    public static var TRIANGLES:Array<Int> = [0, 1, 2, 2, 3, 0 ];

    ///  3 - 7 - 11- 15
    ///  | \ | \ | \ |
    ///  2 - 6 - 10- 14
    ///  | \ | \ | \ |
    ///  1 - 5 - 9 - 13
    ///  | \ | \ | \ |
    ///  0 - 4 - 8 - 12
    public static var TRIANGLES_9_GRID:Array<Int> = [
        4, 0, 1, 1, 5, 4,
        5, 1, 2, 2, 6, 5,
        6, 2, 3, 3, 7, 6,
        8, 4, 5, 5, 9, 8,
        9, 5, 6, 6, 10, 9,
        10, 6, 7, 7, 11, 10,
        12, 8, 9, 9, 13, 12,
        13, 9, 10, 10, 14, 13,
        14, 10, 11, 11, 15, 14
    ];

    ///  1 - 6 - 2
    ///  | \ | / |
    ///  5 - 4 - 7
    ///  | / | \ |
    ///  0 - 8 - 3
    public static var TRIANGLES_4_GRID:Array<Int> = [
        4, 0, 5, 4, 5, 1,
        4, 1, 6, 4, 6, 2,
        4, 2, 7, 4, 7, 3,
        4, 3, 8, 4, 8, 0
    ];

    /// 分配顶点3个属性的缓存数组
    public function alloc(vertCount:Int) {
        if (this.vertCount == 0 || this.vertCount != vertCount) {
            this.pos = NativeArray.create(vertCount);
            this.uv = NativeArray.create(vertCount);
            this.colors = NativeArray.create(vertCount);
        }
    }

    /// 分配顶点索引缓存数组
    private function allocVertexIndex(requestSize:Int):Void {
        this.vertIndex = NativeArray.create(requestSize);
    }

    /// <summary>
    /// 从顶点位置缓冲区的当前索引,开始填入一个矩形的四个顶点
    /// </summary>
    /// <param name="index">填充位置顶点索引</param>
    /// <param name="rect"></param>
    private function fillPos(index:Int, rect:Rectangle):Void {
        this.pos[index] = new Point(rect.left, rect.bottom);
        this.pos[index + 1] = new Point(rect.left, rect.top);
        this.pos[index + 2] = new Point(rect.right, rect.top);
        this.pos[index + 3] = new Point(rect.right, rect.bottom);
    }

    private function fillUV(index:Int, rect:Rectangle):Void {
        this.uv[index] = new Point(rect.left, rect.bottom);
        this.uv[index + 1] = new Point(rect.left, rect.top);
        this.uv[index + 2] = new Point(rect.right, rect.top);
        this.uv[index + 3] = new Point(rect.right, rect.bottom);
    }

    private function fillColors(color:Color):Void {
        this.colors = NativeArray.create(this.vertCount, color);
    }

    private function fillShapeUV(posRect:Rectangle, uvRect:Rectangle):Void {
        var len = this.pos.length;

        for (i in 0...len) {
            var _pos:Point;
            _pos = this.pos[i];
            this.uv[i] = new Point(Mathf.lerp(uvRect.left, uvRect.right, (_pos.x - posRect.left) / posRect.width),
            Mathf.lerp(uvRect.bottom, uvRect.top, (_pos.y - posRect.bottom) / posRect.height));
        }
    }

    private function fillVertexIndexs():Void {

        allocVertexIndex((this.vertCount >> 1) * 3);

        var k:Int = 0;
        var loopTimes:Int = Math.floor(vertCount / 4);
        for (loopIndex in 0...loopTimes) {
            var i = loopIndex * 4;

            this.vertIndex[k++] = i;
            this.vertIndex[k++] = i + 1;
            this.vertIndex[k++] = i + 2;

            this.vertIndex[k++] = i + 2;
            this.vertIndex[k++] = i + 3;
            this.vertIndex[k++] = i;
        }
    }

    /// <summary>
    /// 填充四边形的4个点的位置
    /// </summary>
    /// <param name="verts"></param>
    /// <param name="index"></param>
    /// <param name="rect"></param>
    public static function fillVertsOfQuad(verts:Array<Point>, index:Int, rect:Rectangle):Void {
        verts[index] = new Point(rect.x, rect.bottom);
        verts[index + 1] = new Point(rect.x, rect.y);
        verts[index + 2] = new Point(rect.right, rect.y);
        verts[index + 3] = new Point(rect.right, rect.bottom);
    }

    /// <summary>
    /// 填充四边形的4个点的uv
    /// </summary>
    /// <param name="uv"></param>
    /// <param name="index"></param>
    /// <param name="rect"></param>
    public static function fillUVOfQuad(uv:Array<Point>, index:Int, rect:Rectangle):Void {
        uv[index] = new Point(rect.x, rect.bottom);
        uv[index + 1] = new Point(rect.x, rect.y);
        uv[index + 2] = new Point(rect.right, rect.y);
        uv[index + 3] = new Point(rect.right, rect.bottom);
    }

    /// <summary>
    /// 旋转UV坐标
    /// </summary>
    public static function RotateUV(uv:Array<Point>, baseUVRect:Rectangle):Void {
        var vertCount:Int = uv.length;
        var X:Float = Math.min(baseUVRect.x, baseUVRect.right);
        var Y:Float = baseUVRect.y;
        var Bottom:Float = baseUVRect.bottom;
        if (Y > Bottom) {
            Y = Bottom;
            Bottom = baseUVRect.y;
        }

        var tmp:Float;

        for (i in 0 ... vertCount) {
            var m:Point = uv[i];
            tmp = m.y;
            m.y = Y + m.x - X;
            m.x = X + Bottom - tmp;
            uv[i] = m;
        }
    }

    /// 构建一个矩形
    public function buildRect(posRect:Rectangle, uvRect:Rectangle, fillColor:Color):Void {
        alloc(4);

        fillPos(0, posRect);
        fillUV(0, uvRect);
        fillColors(fillColor);

        this.vertIndex = TRIANGLES;
    }

    /// <summary>
    ///	构建一个带边框线的矩形
    /// </summary>
    /// <param name="vertRect"></param>
    /// <param name="uvRect"></param>
    /// <param name="lineSize"></param>
    /// <param name="lineColor"></param>
    /// <param name="fillColor"></param>
    public function buildRectWithLine(vertRect:Rectangle, uvRect:Rectangle, lineSize:Int, lineColor:Color,
                                      fillColor:Color):Void {
        if (lineSize == 0) {
            buildRect(vertRect, uvRect, fillColor);
        }
        else {
            alloc(20);

            var rect:Rectangle;
            //left,right
            rect = new Rectangle(0, 0, lineSize, vertRect.height);
            fillPos(0, rect);
            rect = new Rectangle(vertRect.width - lineSize, 0, lineSize, vertRect.height);
            fillPos(4, rect);

            //top, bottom
            rect = new Rectangle(lineSize, 0, vertRect.width - lineSize * 2, lineSize);
            fillPos(8, rect);

            rect = new Rectangle(lineSize, vertRect.height - lineSize, vertRect.width - lineSize * 2, lineSize);
            fillPos(12, rect);

            //middle
            rect = new Rectangle(lineSize, lineSize, vertRect.width - lineSize * 2, vertRect.height - lineSize * 2);
            fillPos(16, rect);

            fillShapeUV(vertRect, uvRect);

            var arr = this.colors;
            for (i in 0...16) {
                arr[i] = lineColor;
            }

            for (i in 16...20) {
                arr[i] = fillColor;
            }

            fillVertexIndexs();
        }
    }

    private static var _CornerRadius:Array<Float> = [0, 0, 0, 0];

    /// <summary>
    /// 构建圆角矩形
    /// </summary>
    /// <param name="vertRect"></param>
    /// <param name="uvRect"></param>
    /// <param name="fillColor"></param>
    /// <param name="topLeftRadius"></param>
    /// <param name="topRightRadius"></param>
    /// <param name="bottomLeftRadius"></param>
    /// <param name="bottomRightRadius"></param>
    public function buildRoundRect(vertRect:Rectangle, uvRect:Rectangle, fillColor:Color, topLeftRadius:Float,
                                   topRightRadius:Float, bottomLeftRadius:Float, bottomRightRadius:Float):Void {
        NGraphics._CornerRadius[0] = topRightRadius;
        NGraphics._CornerRadius[1] = topLeftRadius;
        NGraphics._CornerRadius[2] = bottomLeftRadius;
        NGraphics._CornerRadius[3] = bottomRightRadius;

        var numSides:Int = 0;
        for (i in 0 ... 4) {
            var radius:Float = NGraphics._CornerRadius[i];

            if (radius != 0) {
                var radiusX:Float = Mathf.min(radius, vertRect.width / 2);
                var radiusY:Float = Mathf.min(radius, vertRect.height / 2);

                numSides += Mathf.max(1, Math.ceil(Math.PI * (radiusX + radiusY) / 4 / 4)) + 1;
            }
            else
                numSides++;
        }

        alloc(numSides + 1);

        this.pos[0] = new Point(vertRect.width / 2, vertRect.height / 2);
        var k:Int = 1;

        /*
			 2 - 3
			 | / |
			 1 - 0
			 */
        for (i in 0 ... 4) {
            var radius:Float = NGraphics._CornerRadius[i];

            var radiusX:Float = Math.min(radius, vertRect.width / 2);
            var radiusY:Float = Math.min(radius, vertRect.height / 2);

            var offsetX:Float = 0;
            var offsetY:Float = 0;

            if (i == 0 || i == 3)
                offsetX = vertRect.width - radiusX * 2;
            if (i == 0 || i == 1)
                offsetY = vertRect.height - radiusY * 2;

            if (radius != 0) {
                var partNumSides:Dynamic = Math.max(1, Math.ceil(Math.PI * (radiusX + radiusY) / 4 / 4)) + 1;
                var angleDelta:Float = Math.PI / 2 / partNumSides;
                var angle:Float = Math.PI / 2 * i;
                var startAngle:Float = angle;

                for (j in 1 ... partNumSides + 1) {
                    if (j == partNumSides) //消除精度误差带来的不对齐
                        angle = startAngle + Math.PI / 2;
                    this.pos[k] = new Point(offsetX + Math.cos(angle) * radiusX + radiusX, offsetY + Math.sin(angle) * radiusY + radiusY);
                    angle += angleDelta;
                    k++;
                }
            }
            else {
                this.pos[k] = new Point(offsetX, offsetY);
                k++;
            }
        }

        fillShapeUV(vertRect, uvRect);

        allocVertexIndex(numSides * 3);
        var triangles:Array<Int> = this.vertIndex;

        k = 0;
        for (i in 1 ... numSides) {
            triangles[k++] = 0;
            triangles[k++] = i;
            triangles[k++] = i + 1;
        }
        triangles[k++] = 0;
        triangles[k++] = numSides;
        triangles[k++] = 1;

        fillColors(fillColor);
    }

    /// <summary>
    ///  构建椭圆
    /// </summary>
    /// <param name="vertRect"></param>
    /// <param name="uvRect"></param>
    /// <param name="fillColor"></param>
    public function buildEllipse(vertRect:Rectangle, uvRect:Rectangle, fillColor:Color):Void {
        var radiusX:Float = vertRect.width / 2;
        var radiusY:Float = vertRect.height / 2;
        var numSides:Int = Math.ceil(Math.PI * (radiusX + radiusY) / 4);
        if (numSides < 6) numSides = 6;

        alloc(numSides + 1);
        var vertices:Array<Point> = this.pos;
        var angleDelta:Float = 2 * Math.PI / numSides;
        var angle:Float = 0;

        vertices[0] = new Point(radiusX, radiusY);
        var length = numSides + 1;
        for (i in 1 ... length) {
            vertices[i] = new Point(Math.cos(angle) * radiusX + radiusX, Math.sin(angle) * radiusY + radiusY);
            angle += angleDelta;
        }

        fillShapeUV(vertRect, uvRect);

        allocVertexIndex(numSides * 3);
        var triangles:Array<Int> = this.vertIndex;

        var k:Int = 0;
        for (i in 1 ... numSides) {
            triangles[k++] = 0;
            triangles[k++] = i;
            triangles[k++] = i + 1;
        }

        triangles[k++] = 0;
        triangles[k++] = numSides;
        triangles[k++] = 1;

        fillColors(fillColor);
    }

    private static var _RESTINDICES:ArrayList<Int> = new ArrayList<Int>();

    /// <summary>
    /// 构建一个多边形
    /// </summary>
    /// <param name="vertRect"></param>
    /// <param name="uvRect"></param>
    /// <param name="points"></param>
    /// <param name="fillColor"></param>
    public function buildPolygon(vertRect:Rectangle, uvRect:Rectangle, points:Array<Point>, fillColor:Color):Void {
        var numVertices:Int = points.length;
        if (numVertices < 3)
            return;

        var numTriangles:Int = numVertices - 2;
        var i, restIndexPos, numRestIndices:Int;
        var k:Int = 0;

        alloc(numVertices);
        var vertices:Array<Point> = this.pos;

        for (i in 0...numVertices) {
            vertices[i] = new Point(points[i].x, -points[i].y);
        }

        fillShapeUV(vertRect, uvRect);

        // Algorithm "Ear clipping method" described here:
        // -> https://en.wikipedia.org/wiki/Polygon_triangulation
        //
        // Implementation inspired by:
        // -> http://polyk.ivank.net
        // -> Starling

        allocVertexIndex(numTriangles * 3);
        var triangles:Array<Int> = this.vertIndex;

        _RESTINDICES.clear();
        for (i in 0 ... numVertices) {
            _RESTINDICES.add(i);
        }

        restIndexPos = 0;
        numRestIndices = numVertices;

        var a:Point, b:Point, c:Point, p:Point;
        var otherIndex:Int;
        var earFound:Bool;
        var i0:Int, i1:Int, i2:Int;

        while (numRestIndices > 3) {
            earFound = false;
            i0 = _RESTINDICES[restIndexPos % numRestIndices];
            i1 = _RESTINDICES[(restIndexPos + 1) % numRestIndices];
            i2 = _RESTINDICES[(restIndexPos + 2) % numRestIndices];

            a = points[i0];
            b = points[i1];
            c = points[i2];

            if ((a.y - b.y) * (c.x - b.x) + (b.x - a.x) * (c.y - b.y) >= 0) {
                earFound = true;
                for (i in 3...numRestIndices) {
                    otherIndex = _RESTINDICES[(restIndexPos + i) % numRestIndices];
                    p = points[otherIndex];

                    if (ToolSet.isPointInTriangle(p, a, b, c)) {
                        earFound = false;
                        break;
                    }
                }
            }

            if (earFound) {
                triangles[k++] = i0;
                triangles[k++] = i1;
                triangles[k++] = i2;
                _RESTINDICES.delete((restIndexPos + 1) % numRestIndices);

                numRestIndices--;
                restIndexPos = 0;
            }
            else {
                restIndexPos++;
                if (restIndexPos == numRestIndices) break; // no more ears
            }
        }
        triangles[k++] = _RESTINDICES[0];
        triangles[k++] = _RESTINDICES[1];
        triangles[k++] = _RESTINDICES[2];

        fillColors(fillColor);
    }

    /// <summary>
    /// 构建矩形,指定填充方式
    /// </summary>
    /// <param name="vertRect"></param>
    /// <param name="uvRect"></param>
    /// <param name="method"></param>
    /// <param name="amount"></param>
    /// <param name="origin"></param>
    /// <param name="clockwise"></param>
    public function buildRectWithFillMethod(vertRect:Rectangle, uvRect:Rectangle, fillColor:Color,
                                            method:FillMethod, amount:Float, origin:Int, clockwise:Bool):Void {
        amount = Mathf.clamp(amount, 0, 1);
        switch (method)
        {
            case FillMethod.None:
                return;
            case FillMethod.Horizontal:
                alloc(4);
                FillUtils.fillHorizontal(origin, amount, vertRect, uvRect, this.pos, this.uv);

            case FillMethod.Vertical:
                alloc(4);
                FillUtils.fillVertical(origin, amount, vertRect, uvRect, this.pos, this.uv);

            case FillMethod.Radial90:
                alloc(4);
                FillUtils.fillRadial90(origin, amount, clockwise, vertRect, uvRect, this.pos, this.uv);

            case FillMethod.Radial180:
                alloc(8);
                FillUtils.fillRadial180(origin, amount, clockwise, vertRect, uvRect, this.pos, this.uv);

            case FillMethod.Radial360:
                alloc(12);
                FillUtils.fillRadial360(origin, amount, clockwise, vertRect, uvRect, this.pos, this.uv);
        }

        fillColors(fillColor);
        fillVertexIndexs();
    }
}
