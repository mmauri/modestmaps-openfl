/*
 * $Id$
 */

package com.modestmaps.geo;


import openfl.geom.Point;
import com.modestmaps.geo.Transformation;
import com.modestmaps.geo.AbstractProjection;

class MercatorProjection extends AbstractProjection
{
    public function new(zoom : Float, T : Transformation)
    {
        super(zoom, T);
    }
    
    /*
	    * String signature of the current projection.
	    */
    override public function toString() : String
    {
        return "Mercator(" + zoom + ", " + Std.string(T) + ")";
    }
    
    /*
	    * Return raw projected point.
	    * See: http://mathworld.wolfram.com/MercatorProjection.html (2)
	    */
    override private function rawProject(point : Point) : Point
    {
        return new Point(point.x, 
        Math.log(Math.tan(0.25 * Math.PI + 0.5 * point.y)));
    }
    
    /*
	    * Return raw unprojected point.
	    * See: http://mathworld.wolfram.com/MercatorProjection.html (7)
	    */
    override private function rawUnproject(point : Point) : Point
    {
        return new Point(point.x, 2 * Math.atan(Math.pow(Math.exp(1.0), point.y)) - 0.5 * Math.PI);
    }
}
