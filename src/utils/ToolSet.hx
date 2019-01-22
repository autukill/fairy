package utils;

import geom.Point;
@:keep
class ToolSet {
    public static function isPointInTriangle(p:Point, a:Point, b:Point, c:Point) {
        // This algorithm is described well in this article:
        // http://www.blackpawn.com/texts/pointinpoly/default.html

        var v0x:Float = c.x - a.x;
        var v0y:Float = c.y - a.y;
        var v1x:Float = b.x - a.x;
        var v1y:Float = b.y - a.y;
        var v2x:Float = p.x - a.x;
        var v2y:Float = p.y - a.y;

        var dot00:Float = v0x * v0x + v0y * v0y;
        var dot01:Float = v0x * v1x + v0y * v1y;
        var dot02:Float = v0x * v2x + v0y * v2y;
        var dot11:Float = v1x * v1x + v1y * v1y;
        var dot12:Float = v1x * v2x + v1y * v2y;

        var invDen:Float = 1.0 / (dot00 * dot11 - dot01 * dot01);
        var u:Float = (dot11 * dot02 - dot01 * dot12) * invDen;
        var v:Float = (dot00 * dot12 - dot01 * dot02) * invDen;

        return (u >= 0) && (v >= 0) && (u + v < 1);
    }
}
