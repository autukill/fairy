package utils;

import gml.Mathf;
import gml.gpu.Matrix;
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

    public static function createMatrix(trans:Point, rotate:Float, scale:Point, ?skew:Point):Matrix {
        var matrix = new Matrix();

        // Scale
        if (scale.x != 0 || scale.y != 0) {
            var scaleMatrix = Matrix.build(0, 0, 0, 0, 0, 0, scale.x, scale.y, 1);
            matrix = matrix.multiply(scaleMatrix);
        }

        // Rotation
        if (rotate != 0) {
            var rotationMatrix = Matrix.build(0, 0, 0, 0, 0, rotate, 1, 1, 1);
            matrix = matrix.multiply(rotationMatrix);
        }

        // skew
        if (skew != null && (skew.x != 0 || skew.y != 0)) {
            var skewX = Mathf.degToRad(skew.x);
            var skewY = Mathf.degToRad(skew.y);
            var sinX = Math.sin(skewX);
            var cosX = Math.cos(skewX);
            var sinY = Math.sin(skewY);
            var cosY = Math.cos(skewY);

            var fakeMatrix:Dynamic = matrix;
            fakeMatrix[0] = fakeMatrix[0] * cosY - fakeMatrix[1] * sinX;
            fakeMatrix[1] = fakeMatrix[0] * sinY + fakeMatrix[1] * cosX;
            fakeMatrix[4] = fakeMatrix[4] * cosY - fakeMatrix[5] * sinX;
            fakeMatrix[5] = fakeMatrix[4] * sinY + fakeMatrix[5] * cosX;
        }

        // translate
        if (trans.x != 0 || trans.y != 0) {
            var transMatrix = Matrix.build(trans.x, trans.y, 0, 0, 0, 0, 1, 1, 1);
            matrix = matrix.multiply(transMatrix);
        }

        return matrix;
    }
}
