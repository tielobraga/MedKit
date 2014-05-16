/**
 * User: booster
 * Date: 14/05/14
 * Time: 11:13
 */
package medkit.geom.shapes {
import medkit.geom.*;

import flash.geom.Matrix;
import flash.geom.Rectangle;

import medkit.collection.spatial.Spatial;

import medkit.object.Hashable;

public class Rectangle2D extends Rectangle implements Shape2D, Hashable, Spatial {
    public static const _tempRect:Rectangle2D = new Rectangle2D();

    public function Rectangle2D(x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0) {
        super(x, y, width, height);
    }

    public function getBounds(result:Rectangle2D = null):Rectangle2D {
        if(result == null) result = new Rectangle2D();

        result.x = x; result.y = y;
        result.width = width; result.height = height;

        return result;
    }

    public function intersectsRect(x:Number, y:Number, w:Number, h:Number):Boolean {
        _tempRect.setTo(x, y, w, h);

        return intersects(_tempRect);
    }

    public function intersectsRectangle2D(rect:Rectangle2D):Boolean {
        return intersects(rect);
    }

    public function containsPoint2D(point:Point2D):Boolean {
        return containsPoint(point);
    }

    public function containsRectangle2D(rect:Rectangle2D):Boolean {
        return containsRect(rect);
    }

    public function add(newX:Number, newY:Number):void {
        var x1:Number = x < newX ? x : newX;
        var x2:Number = x + width > newX ? x + width : newX;
        var y1:Number = y < newY ? y : newY;
        var y2:Number = y + height > newY ? y + height : newY;

        setTo(x1, y1, x2 - x1, y2 - y1);
    }

    public function addPoint2D(point:Point2D):void {
        add(point.x, point.y);
    }

    public function getPathIterator(transformMatrix:Matrix = null, flatness:Number = 0):PathIterator {
        return new RectIterator(this, transformMatrix);
    }

    override public function clone():Rectangle {
        return new Rectangle2D(x, y, width, height);
    }

    public function hashCode():int {
        return (height << 24) | (width << 16) | (y << 8) | x;
    }

    public function get indexCount():int { return 2; }
    public function minValue(index:int):Number { return index == 0 ? x : y; }
    public function maxValue(index:int):Number { return index == 0 ? x + width : y + height; }
}
}

import flash.geom.Matrix;

import medkit.geom.GeomUtil;
import medkit.geom.shapes.PathIterator;
import medkit.geom.shapes.Point2D;
import medkit.geom.shapes.Rectangle2D;
import medkit.geom.shapes.enum.SegmentType;
import medkit.geom.shapes.enum.WindingRule;

class RectIterator implements PathIterator {
    public var rect:Rectangle2D;
    public var matrix:Matrix;
    public var index:int;

    public function RectIterator(rect:Rectangle2D, matrix:Matrix = null) {
        this.rect   = rect;
        this.matrix = matrix;
        this.index  = 0;
    }

    public function getWindingRule():WindingRule { return WindingRule.NonZero; }

    public function isDone():Boolean {
        return index > 5;
    }

    public function next():void { ++index; }

    public function currentSegment(coords:Vector.<Point2D>):SegmentType {
        if (index > 5)
            throw new RangeError("rect iterator out of bounds");

        if (index == 5)
            return SegmentType.Close;

        coords[0].x = rect.x;
        coords[0].y = rect.y;

        if (index == 1 || index == 2)   coords[0].x += rect.width;
        if (index == 2 || index == 3)   coords[0].y += rect.height;

        if (matrix != null)
            GeomUtil.transformPoint2D(matrix, coords[0].x, coords[0].y, coords[0]);

        return index == 0 ? SegmentType.MoveTo : SegmentType.LineTo;
    }
}
