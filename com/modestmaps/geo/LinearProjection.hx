/*
 * $Id$
 */

package com.modestmaps.geo;


import openfl.geom.Point;
import com.modestmaps.geo.Transformation;
import com.modestmaps.geo.AbstractProjection;

class LinearProjection extends AbstractProjection
{
    private function new(zoom : Float, T : Transformation)
    {
        super(zoom, T);
    }
    
    /*
	    * String signature of the current projection.
	    */
    override public function toString() : String
    {
        return "Linear(" + zoom + ", " + Std.string(T) + ")";
    }
    
    /*
	    * Return raw projected point.
	    */
    override private function rawProject(point : Point) : Point
    {
        return new Point(point.x, point.y);
    }
    
    /*
	    * Return raw unprojected point.
	    */
    override private function rawUnproject(point : Point) : Point
    {
        return new Point(point.x, point.y);
    }
}
