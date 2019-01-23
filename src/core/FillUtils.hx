package core;

import geom.Rectangle;
import geom.Point;
@:keep @:enum
abstract FillMethod(Int) from Int to Int {
    var None = 0;

    /// <summary>
    /// The Image will be filled Horizontally
    /// </summary>
    var Horizontal = 1;

    /// <summary>
    /// The Image will be filled Vertically.
    /// </summary>
    var Vertical = 2;

    /// <summary>
    /// The Image will be filled Radially with the radial center in one of the corners.
    /// </summary>
    var Radial90 = 3;

    /// <summary>
    /// The Image will be filled Radially with the radial center in one of the edges.
    /// </summary>
    var Radial180 = 4;

    /// <summary>
    /// The Image will be filled Radially with the radial center at the center.
    /// </summary>
    var Radial360 = 5;
}

@:keep @:enum
abstract OriginHorizontal(Int) from Int to Int{
    var Left = 0;
    var Right = 1;
}

@:keep @:enum
abstract OriginVertical(Int) from Int to Int{
    var Top = 0;
    var Bottom = 1;
}

@:keep @:enum
abstract Origin90(Int) from Int to Int{
    var TopLeft = 0;
    var TopRight = 1;
    var BottomLeft = 2;
    var BottomRight = 3;
}

@:keep @:enum
abstract Origin180(Int) from Int to Int{
    var Top = 0;
    var Bottom = 1;
    var Left = 2;
    var Right = 3;
}

@:keep @:enum
abstract Origin360(Int) from Int to Int{
    var Top = 0;
    var Bottom = 1;
    var Left = 2;
    var Right = 3;
}

@:keep
@:native('fill_utils')
class FillUtils {
    /// <summary>
    /// The Image will be filled Horizontally
    /// </summary>
    /// <param name="origin"></param>
    /// <param name="amount"></param>
    /// <param name="vertRect"></param>
    /// <param name="uvRect"></param>
    /// <param name="verts"></param>
    /// <param name="uv"></param>
    @:native('horizontal')
    public static function fillHorizontal(origin:Int, amount:Float, vertRect:Rectangle, uvRect:Rectangle, verts:Array<Point>, uv:Array<Point>):Void {
        if (origin == OriginHorizontal.Left) {
            vertRect.width = vertRect.width * amount;
            uvRect.width = uvRect.width * amount;
        }
        else {
            vertRect.x += vertRect.width * (1 - amount);
            vertRect.width = vertRect.width * amount;
            uvRect.x += uvRect.width * (1 - amount);
            uvRect.width = uvRect.width * amount;
        }

        NGraphics.fillVertsOfQuad(verts, 0, vertRect);
        NGraphics.fillUVOfQuad(uv, 0, uvRect);
    }

    @:native('vertical')
    public static function fillVertical(origin:Int, amount:Float, vertRect:Rectangle, uvRect:Rectangle, verts:Array<Point>, uv:Array<Point>):Void {
        if (origin == OriginVertical.Top) {
            vertRect.height = vertRect.height * amount;
            uvRect.height = uvRect.height * amount;
        }
        else {
            vertRect.y += vertRect.height * (1 - amount);
            vertRect.height = vertRect.height * amount;
            uvRect.y += uvRect.height * (1 - amount);
            uvRect.height = uvRect.height * amount;
        }

        NGraphics.fillVertsOfQuad(verts, 0, vertRect);
        NGraphics.fillUVOfQuad(uv, 0, uvRect);
    }

    @:native('radial90')
    public static function fillRadial90(origin:Int, amount:Float, clockwise:Bool, vertRect:Rectangle, uvRect:Rectangle, verts:Array<Point>, uv:Array<Point>):Void {
        NGraphics.fillVertsOfQuad(verts, 0, vertRect);
        NGraphics.fillUVOfQuad(uv, 0, uvRect);
        if (amount < 0.001) {
            verts[0] = verts[1] = verts[2] = verts[3];
            uv[0] = uv[1] = uv[2] = uv[3];
            return;
        }
        if (amount > 0.999)
            return;

        //	1 -- 2
        //	|	 |
        //	0 -- 3
        switch (origin)
        {
            case Origin90.BottomLeft:
                {
                    if (clockwise) {
                        var v:Float = Math.tan(Math.PI / 2 * (1 - amount));
                        var h:Float = vertRect.width * v;
                        if (h > vertRect.height) {
                            var ratio:Float = (h - vertRect.height) / h;
                            verts[2].x -= vertRect.width * ratio;
                            verts[3] = verts[2];

                            uv[2].x -= uvRect.width * ratio;
                            uv[3] = uv[2];
                        }
                        else {
                            var ratio:Float = h / vertRect.height;
                            verts[3].y -= h;
                            uv[3].y -= uvRect.height * ratio;
                        }
                    }
                    else {
                        var v:Float = Math.tan(Math.PI / 2 * amount);
                        var h:Float = vertRect.width * v;
                        if (h > vertRect.height) {
                            var ratio:Float = (h - vertRect.height) / h;
                            verts[1].x += vertRect.width * (1 - ratio);
                            uv[1].x += uvRect.width * (1 - ratio);
                        }
                        else {
                            var ratio:Float = h / vertRect.height;
                            verts[2].y += vertRect.height * (1 - ratio);
                            verts[1] = verts[2];

                            uv[2].y += uvRect.height * (1 - ratio);
                            uv[1] = uv[2];
                        }
                    }
                }

            case Origin90.BottomRight:
                {
                    if (clockwise) {
                        var v:Float = Math.tan(Math.PI / 2 * amount);
                        var h:Float = vertRect.width * v;
                        if (h > vertRect.height) {
                            var ratio = (h - vertRect.height) / h;
                            verts[2].x -= vertRect.width * (1 - ratio);
                            uv[2].x -= uvRect.width * (1 - ratio);
                        }
                        else {
                            var ratio = h / vertRect.height;
                            verts[1].y += vertRect.height * (1 - ratio);
                            verts[2] = verts[3];

                            uv[1].y += uvRect.height * (1 - ratio);
                            uv[2] = uv[3];
                        }
                    }
                    else {
                        var v = Math.tan(Math.PI / 2 * (1 - amount));
                        var h = vertRect.width * v;
                        if (h > vertRect.height) {
                            var ratio = (h - vertRect.height) / h;
                            verts[1].x += vertRect.width * ratio;
                            verts[0] = verts[1];

                            uv[1].x += uvRect.width * ratio;
                            uv[0] = uv[1];
                        }
                        else {
                            var ratio = h / vertRect.height;
                            verts[0].y -= h;
                            uv[0].y -= uvRect.height * ratio;
                        }
                    }
                }

            case Origin90.TopLeft:
                {
                    if (clockwise) {
                        var v = Math.tan(Math.PI / 2 * amount);
                        var h = vertRect.width * v;
                        if (h > vertRect.height) {
                            var ratio = (h - vertRect.height) / h;
                            verts[0].x += vertRect.width * (1 - ratio);
                            uv[0].x += uvRect.width * (1 - ratio);
                        }
                        else {
                            var ratio = h / vertRect.height;
                            verts[3].y -= vertRect.height * (1 - ratio);
                            verts[0] = verts[3];

                            uv[3].y -= uvRect.height * (1 - ratio);
                            uv[0] = uv[3];
                        }
                    }
                    else {
                        var v = Math.tan(Math.PI / 2 * (1 - amount));
                        var h = vertRect.width * v;
                        if (h > vertRect.height) {
                            var ratio = (h - vertRect.height) / h;
                            verts[3].x -= vertRect.width * ratio;
                            verts[2] = verts[3];
                            uv[3].x -= uvRect.width * ratio;
                            uv[2] = uv[3];
                        }
                        else {
                            var ratio = h / vertRect.height;
                            verts[2].y += h;
                            uv[2].y += uvRect.height * ratio;
                        }
                    }
                }

            case Origin90.TopRight:
                {
                    if (clockwise) {
                        var v = Math.tan(Math.PI / 2 * (1 - amount));
                        var h = vertRect.width * v;
                        if (h > vertRect.height) {
                            var ratio = (h - vertRect.height) / h;
                            verts[0].x += vertRect.width * ratio;
                            verts[1] = verts[2];
                            uv[0].x += uvRect.width * ratio;
                            uv[1] = uv[2];
                        }
                        else {
                            var ratio = h / vertRect.height;
                            verts[1].y += vertRect.height * ratio;
                            uv[1].y += uvRect.height * ratio;
                        }
                    }
                    else {
                        var v = Math.tan(Math.PI / 2 * amount);
                        var h = vertRect.width * v;
                        if (h > vertRect.height) {
                            var ratio = (h - vertRect.height) / h;
                            verts[3].x -= vertRect.width * (1 - ratio);
                            uv[3].x -= uvRect.width * (1 - ratio);
                        }
                        else {
                            var ratio = h / vertRect.height;
                            verts[0].y -= vertRect.height * (1 - ratio);
                            verts[3] = verts[0];
                            uv[0].y -= uvRect.height * (1 - ratio);
                            uv[3] = uv[0];
                        }
                    }
                }
        }
    }

    @:native('radial180')
    public static function fillRadial180(origin:Int, amount:Float, clockwise:Bool, vertRect:Rectangle, uvRect:Rectangle, verts:Array<Point>, uv:Array<Point>):Void {
        switch (origin)
        {
            case Origin180.Top:
                if (amount <= 0.5) {
                    vertRect.width /= 2;
                    uvRect.width /= 2;
                    if (clockwise) {
                        vertRect.x += vertRect.width;
                        uvRect.x += uvRect.width;
                    }
                    amount = amount / 0.5;
                    fillRadial90(clockwise ? Origin90.TopLeft : Origin90.TopRight, amount, clockwise, vertRect, uvRect, verts, uv);
                    verts[4] = verts[5] = verts[6] = verts[7] = verts[0];
                    uv[4] = uv[5] = uv[6] = uv[7] = uv[0];
                }
                else {
                    vertRect.width /= 2;
                    uvRect.width /= 2;
                    if (!clockwise) {
                        vertRect.x += vertRect.width;
                        uvRect.x += uvRect.width;
                    }
                    amount = (amount - 0.5) / 0.5;
                    fillRadial90(clockwise ? Origin90.TopRight : Origin90.TopLeft, amount, clockwise, vertRect, uvRect, verts, uv);

                    if (clockwise) {
                        vertRect.x += vertRect.width;
                        uvRect.x += uvRect.width;
                    }
                    else {
                        vertRect.x -= vertRect.width;
                        uvRect.x -= uvRect.width;
                    }
                    NGraphics.fillVertsOfQuad(verts, 4, vertRect);
                    NGraphics.fillUVOfQuad(uv, 4, uvRect);
                }

            case Origin180.Bottom:
                if (amount <= 0.5) {
                    vertRect.width /= 2;
                    uvRect.width /= 2;
                    if (!clockwise) {
                        vertRect.x += vertRect.width;
                        uvRect.x += uvRect.width;
                    }
                    amount = amount / 0.5;
                    fillRadial90(clockwise ? Origin90.BottomRight : Origin90.BottomLeft, amount, clockwise, vertRect, uvRect, verts, uv);
                    verts[4] = verts[5] = verts[6] = verts[7] = verts[0];
                    uv[4] = uv[5] = uv[6] = uv[7] = uv[0];
                }
                else {
                    vertRect.width /= 2;
                    uvRect.width /= 2;
                    if (clockwise) {
                        vertRect.x += vertRect.width;
                        uvRect.x += uvRect.width;
                    }
                    amount = (amount - 0.5) / 0.5;
                    fillRadial90(clockwise ? Origin90.BottomLeft : Origin90.BottomRight, amount, clockwise, vertRect, uvRect, verts, uv);

                    if (clockwise) {
                        vertRect.x -= vertRect.width;
                        uvRect.x -= uvRect.width;
                    }
                    else {
                        vertRect.x += vertRect.width;
                        uvRect.x += uvRect.width;
                    }
                    NGraphics.fillVertsOfQuad(verts, 4, vertRect);
                    NGraphics.fillUVOfQuad(uv, 4, uvRect);
                }

            case Origin180.Left:
                if (amount <= 0.5) {
                    vertRect.height /= 2;
                    uvRect.height /= 2;
                    if (!clockwise) {
                        vertRect.y += vertRect.height;
                        uvRect.y += uvRect.height;
                    }
                    amount = amount / 0.5;
                    fillRadial90(clockwise ? Origin90.BottomLeft : Origin90.TopLeft, amount, clockwise, vertRect, uvRect, verts, uv);
                    verts[4] = verts[5] = verts[6] = verts[7] = verts[0];
                    uv[4] = uv[5] = uv[6] = uv[7] = uv[0];
                }
                else {
                    vertRect.height /= 2;
                    uvRect.height /= 2;
                    if (clockwise) {
                        vertRect.y += vertRect.height;
                        uvRect.y += uvRect.height;
                    }
                    amount = (amount - 0.5) / 0.5;
                    fillRadial90(clockwise ? Origin90.TopLeft : Origin90.BottomLeft, amount, clockwise, vertRect, uvRect, verts, uv);

                    if (clockwise) {
                        vertRect.y -= vertRect.height;
                        uvRect.y -= uvRect.height;
                    }
                    else {
                        vertRect.y += vertRect.height;
                        uvRect.y += uvRect.height;
                    }
                    NGraphics.fillVertsOfQuad(verts, 4, vertRect);
                    NGraphics.fillUVOfQuad(uv, 4, uvRect);
                }

            case Origin180.Right:
                if (amount <= 0.5) {
                    vertRect.height /= 2;
                    uvRect.height /= 2;
                    if (clockwise) {
                        vertRect.y += vertRect.height;
                        uvRect.y += uvRect.height;
                    }
                    amount = amount / 0.5;
                    fillRadial90(clockwise ? Origin90.TopRight : Origin90.BottomRight, amount, clockwise, vertRect, uvRect, verts, uv);
                    verts[4] = verts[5] = verts[6] = verts[7] = verts[0];
                    uv[4] = uv[5] = uv[6] = uv[7] = uv[0];
                }
                else {
                    vertRect.height /= 2;
                    uvRect.height /= 2;
                    if (!clockwise) {
                        vertRect.y += vertRect.height;
                        uvRect.y += uvRect.height;
                    }
                    amount = (amount - 0.5) / 0.5;
                    fillRadial90(clockwise ? Origin90.BottomRight : Origin90.TopRight, amount, clockwise, vertRect, uvRect, verts, uv);

                    if (clockwise) {
                        vertRect.y += vertRect.height;
                        uvRect.y += uvRect.height;
                    }
                    else {
                        vertRect.y -= vertRect.height;
                        uvRect.y -= uvRect.height;
                    }
                    NGraphics.fillVertsOfQuad(verts, 4, vertRect);
                    NGraphics.fillUVOfQuad(uv, 4, uvRect);
                }
        }
    }

    @:native('radial360')
    public static function fillRadial360(origin:Int, amount:Float, clockwise:Bool, vertRect:Rectangle, uvRect:Rectangle, verts:Array<Point>, uv:Array<Point>):Void {
        switch (origin)
        {
            case Origin360.Top:
                if (amount < 0.5) {
                    vertRect.width /= 2;
                    uvRect.width /= 2;
                    if (clockwise) {
                        vertRect.x += vertRect.width;
                        uvRect.x += uvRect.width;
                    }
                    amount = amount / 0.5;
                    fillRadial180(clockwise ? Origin180.Left : Origin180.Right, amount, clockwise, vertRect, uvRect, verts, uv);
                    verts[8] = verts[9] = verts[10] = verts[11] = verts[7];
                    uv[8] = uv[9] = uv[10] = uv[11] = uv[7];
                }
                else {
                    vertRect.width /= 2;
                    uvRect.width /= 2;
                    if (!clockwise) {
                        vertRect.x += vertRect.width;
                        uvRect.x += uvRect.width;
                    }
                    amount = (amount - 0.5) / 0.5;
                    fillRadial180(clockwise ? Origin180.Right : Origin180.Left, amount, clockwise, vertRect, uvRect, verts, uv);

                    if (clockwise) {
                        vertRect.x += vertRect.width;
                        uvRect.x += uvRect.width;
                    }
                    else {
                        vertRect.x -= vertRect.width;
                        uvRect.x -= uvRect.width;
                    }
                    NGraphics.fillVertsOfQuad(verts, 8, vertRect);
                    NGraphics.fillUVOfQuad(uv, 8, uvRect);
                }

            case Origin360.Bottom:
                if (amount < 0.5) {
                    vertRect.width /= 2;
                    uvRect.width /= 2;
                    if (!clockwise) {
                        vertRect.x += vertRect.width;
                        uvRect.x += uvRect.width;
                    }
                    amount = amount / 0.5;
                    fillRadial180(clockwise ? Origin180.Right : Origin180.Left, amount, clockwise, vertRect, uvRect, verts, uv);
                    verts[8] = verts[9] = verts[10] = verts[11] = verts[7];
                    uv[8] = uv[9] = uv[10] = uv[11] = uv[7];
                }
                else {
                    vertRect.width /= 2;
                    uvRect.width /= 2;
                    if (clockwise) {
                        vertRect.x += vertRect.width;
                        uvRect.x += uvRect.width;
                    }
                    amount = (amount - 0.5) / 0.5;
                    fillRadial180(clockwise ? Origin180.Left : Origin180.Right, amount, clockwise, vertRect, uvRect, verts, uv);

                    if (clockwise) {
                        vertRect.x -= vertRect.width;
                        uvRect.x -= uvRect.width;
                    }
                    else {
                        vertRect.x += vertRect.width;
                        uvRect.x += uvRect.width;
                    }
                    NGraphics.fillVertsOfQuad(verts, 8, vertRect);
                    NGraphics.fillUVOfQuad(uv, 8, uvRect);
                }

            case Origin360.Left:
                if (amount < 0.5) {
                    vertRect.height /= 2;
                    uvRect.height /= 2;
                    if (!clockwise) {
                        vertRect.y += vertRect.height;
                        uvRect.y += uvRect.height;
                    }
                    amount = amount / 0.5;
                    fillRadial180(clockwise ? Origin180.Bottom : Origin180.Top, amount, clockwise, vertRect, uvRect, verts, uv);
                    verts[8] = verts[9] = verts[10] = verts[11] = verts[7];
                    uv[8] = uv[9] = uv[10] = uv[11] = uv[7];
                }
                else {
                    vertRect.height /= 2;
                    uvRect.height /= 2;
                    if (clockwise) {
                        vertRect.y += vertRect.height;
                        uvRect.y += uvRect.height;
                    }
                    amount = (amount - 0.5) / 0.5;
                    fillRadial180(clockwise ? Origin180.Top : Origin180.Bottom, amount, clockwise, vertRect, uvRect, verts, uv);

                    if (clockwise) {
                        vertRect.y -= vertRect.height;
                        uvRect.y -= uvRect.height;
                    }
                    else {
                        vertRect.y += vertRect.height;
                        uvRect.y += uvRect.height;
                    }
                    NGraphics.fillVertsOfQuad(verts, 8, vertRect);
                    NGraphics.fillUVOfQuad(uv, 8, uvRect);
                }

            case Origin360.Right:
                if (amount < 0.5) {
                    vertRect.height /= 2;
                    uvRect.height /= 2;
                    if (clockwise) {
                        vertRect.y += vertRect.height;
                        uvRect.y += uvRect.height;
                    }
                    amount = amount / 0.5;
                    fillRadial180(clockwise ? Origin180.Top : Origin180.Bottom, amount, clockwise, vertRect, uvRect, verts, uv);
                    verts[8] = verts[9] = verts[10] = verts[11] = verts[7];
                    uv[8] = uv[9] = uv[10] = uv[11] = uv[7];
                }
                else {
                    vertRect.height /= 2;
                    uvRect.height /= 2;
                    if (!clockwise) {
                        vertRect.y += vertRect.height;
                        uvRect.y += uvRect.height;
                    }
                    amount = (amount - 0.5) / 0.5;
                    fillRadial180(clockwise ? Origin180.Bottom : Origin180.Top, amount, clockwise, vertRect, uvRect, verts, uv);

                    if (clockwise) {
                        vertRect.y += vertRect.height;
                        uvRect.y += uvRect.height;
                    }
                    else {
                        vertRect.y -= vertRect.height;
                        uvRect.y -= uvRect.height;
                    }
                    NGraphics.fillVertsOfQuad(verts, 8, vertRect);
                    NGraphics.fillUVOfQuad(uv, 8, uvRect);
                }
        }
    }
}
