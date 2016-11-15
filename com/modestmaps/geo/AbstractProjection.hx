/*
 * $Id$
 */

package com.modestmaps.geo;

import openfl.errors.Error;

import openfl.geom.Point;
import com.modestmaps.core.Coordinate;
import com.modestmaps.geo.Location;
import com.modestmaps.geo.Transformation;
import com.modestmaps.geo.IProjection;

class AbstractProjection implements IProjection
{
    // linear transformation, if any.
    private var T : Transformation;
    
    // required native zoom for which transformation above is valid.
    private var zoom : Float;
    
    public function new(zoom : Float, T : Transformation)
    {
        // a transformation is not strictly necessary
        if (T != null) 
            this.T = T;
        
        this.zoom = zoom;
    }
    
    /**
	    * String signature of the current projection.
	    */
    public function toString() : String
    {
        throw new Error("Abstract method not implemented by subclass.");
        return null;
    }
    
    /**
	    * @return raw projected point.
	    */
    private function rawProject(point : Point) : Point
    {
        throw new Error("Abstract method not implemented by subclass.");
        return null;
    }
    
    /**
	    * @return raw unprojected point.
	    */
    private function rawUnproject(point : Point) : Point
    {
        throw new Error("Abstract method not implemented by subclass.");
        return null;
    }
    
    /**
	    * @return projected and transformed point.
	    */
    public function project(point : Point) : Point
    {
        point = rawProject(point);
        
        if (T != null) 
            point = T.transform(point);
        
        return point;
    }
    
    /**
	    * @return untransformed and unprojected point.
	    */
    public function unproject(point : Point) : Point
    {
        if (T != null) 
            point = T.untransform(point);
        
        point = rawUnproject(point);
        
        return point;
    }
    
    /**
	    * @return projected and transformed coordinate for a location.
	    */
    public function locationCoordinate(location : Location) : Coordinate
    {
        var point : Point = new Point(Math.PI * location.lon / 180, Math.PI * location.lat / 180);
        point = project(point);
        return new Coordinate(point.y, point.x, zoom);
    }
    
    /**
	    * @return untransformed and unprojected location for a coordinate.
	    */
    public function coordinateLocation(coordinate : Coordinate) : Location
    {
        coordinate = coordinate.zoomTo(zoom);
        var point : Point = new Point(coordinate.column, coordinate.row);
        point = unproject(point);
        return new Location(180 * point.y / Math.PI, 180 * point.x / Math.PI);
    }
}
