package core;
import gml.Mathf;
import gml.NativeArray;
import gml.ds.Color;
import geom.Point;
import geom.Rectangle;

@:keep
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
    public function ClearMesh():Void {
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
    public function Alloc(vertCount:Int) {
        if (this.vertCount == 0 || this.vertCount != vertCount) {
            this.pos = NativeArray.create(vertCount);
            this.uv = NativeArray.create(vertCount);
            this.colors = NativeArray.create(vertCount);
        }
    }

    /// 分配顶点索引缓存数组
    private function AllocVertexIndex(requestSize:Int):Void {
        this.vertIndex = NativeArray.create(requestSize);
    }

    /// <summary>
    /// 从顶点位置缓冲区的当前索引,开始填入一个矩形的四个顶点
    /// </summary>
    /// <param name="index">填充位置顶点索引</param>
    /// <param name="rect"></param>
    private function FillPos(index:Int, rect:Rectangle):Void {
        this.pos[index] = new Point(rect.left, rect.bottom);
        this.pos[index + 1] = new Point(rect.left, rect.top);
        this.pos[index + 2] = new Point(rect.right, rect.top);
        this.pos[index + 3] = new Point(rect.right, rect.bottom);
    }

    private function FillUV(index:Int, rect:Rectangle):Void {
        this.uv[index] = new Point(rect.left, rect.bottom);
        this.uv[index + 1] = new Point(rect.left, rect.top);
        this.uv[index + 2] = new Point(rect.right, rect.top);
        this.uv[index + 3] = new Point(rect.right, rect.bottom);
    }

    private function FillColor(color:Color):Void {
        this.colors = NativeArray.create(this.vertCount, color);
    }

    private function FillShapeUV(posRect:Rectangle, uvRect:Rectangle):Void {
        var len = this.pos.length;

        for (i in 0...len) {
            var _pos:Point;
            _pos = this.pos[i];
            this.uv[i] = new Point(Mathf.lerp(uvRect.left, uvRect.right, (_pos.x - posRect.left) / posRect.width),
            Mathf.lerp(uvRect.bottom, uvRect.top, (_pos.y - posRect.bottom) / posRect.height));
        }
    }

    private function FillVertexIndexs():Void {

        AllocVertexIndex((this.vertCount >> 1) * 3);

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

    /// 构建一个矩形
    public function BuildRect(posRect:Rectangle, uvRect:Rectangle, fillColor:Color):Void {
        Alloc(4);

        FillPos(0, posRect);
        FillUV(0, uvRect);
        FillColor(fillColor);

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
    public function BuildRectWithLine(vertRect:Rectangle, uvRect:Rectangle, lineSize:Int, lineColor:Color,
                                      fillColor:Color):Void {
        if (lineSize == 0) {
            BuildRect(vertRect, uvRect, fillColor);
        }
        else {
            Alloc(20);

            var rect:Rectangle;
            //left,right
            rect = new Rectangle(0, 0, lineSize, vertRect.height);
            FillPos(0, rect);
            rect = new Rectangle(vertRect.width - lineSize, 0, lineSize, vertRect.height);
            FillPos(4, rect);

            //top, bottom
            rect = new Rectangle(lineSize, 0, vertRect.width - lineSize * 2, lineSize);
            FillPos(8, rect);

            rect = new Rectangle(lineSize, vertRect.height - lineSize, vertRect.width - lineSize * 2, lineSize);
            FillPos(12, rect);

            //middle
            rect = new Rectangle(lineSize, lineSize, vertRect.width - lineSize * 2, vertRect.height - lineSize * 2);
            FillPos(16, rect);

            FillShapeUV(vertRect, uvRect);

            var arr = this.colors;
            for (i in 0...16) {
                arr[i] = lineColor;
            }

            for (i in 16...20) {
                arr[i] = fillColor;
            }

            FillVertexIndexs();
        }
    }

    private static var _CornerRadius:Array<Float> = [0, 0, 0, 0];

    /// <summary>
    ///
    /// </summary>
    /// <param name="vertRect"></param>
    /// <param name="uvRect"></param>
    /// <param name="fillColor"></param>
    /// <param name="topLeftRadius"></param>
    /// <param name="topRightRadius"></param>
    /// <param name="bottomLeftRadius"></param>
    /// <param name="bottomRightRadius"></param>
    public function DrawRoundRect(vertRect:Rectangle, uvRect:Rectangle, fillColor:Color, topLeftRadius:Float,
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

        Alloc(numSides + 1);

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

        FillShapeUV(vertRect, uvRect);

        AllocVertexIndex(numSides * 3);
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

        FillColor(fillColor);
    }
}
