package com.modestmaps.mapproviders;

import com.modestmaps.mapproviders.IMapProvider;

import com.modestmaps.core.Coordinate;
import com.modestmaps.geo.LinearProjection;
import com.modestmaps.geo.Transformation;

class DailyPlanetProvider extends AbstractMapProvider implements IMapProvider
{
    private static inline var MIN_ZOOM : Int = 1;
    private static inline var MAX_ZOOM : Int = 6;
    
    /** WARNING: this is extremely experimental, and 
		 * it might not make the correct calls to NASA every time 
		 * we are still testing 512px providers, too */
    public function new(minZoom : Int = MIN_ZOOM, maxZoom : Int = MAX_ZOOM)
    {
        super();
        
        var t : Transformation = new Transformation(0.3183098861837907, 0, 1, 
        0, -0.3183098861837907, 0.5);
        
        __projection = new LinearProjection(1, t);
        
        __topLeftOutLimit = new Coordinate(0, Float.NEGATIVE_INFINITY, 0).zoomTo(minZoom);
        __bottomRightInLimit = (new Coordinate(1, Float.POSITIVE_INFINITY, 0)).zoomTo(maxZoom);
    }
    
    public function getTileUrls(coord : Coordinate) : Array<String>
    {
        // zoom level 0 is a 512x512 tile containing a linearly projected map of the world in the top half:
        // http://wms.jpl.nasa.gov/wms.cgi?request=GetMap&width=512&height=512&layers=daily_planet&styles=&srs=EPSG:4326&format=image/jpeg&bbox=-180,-270,180,90
        // the -270 there works, and kind of makes sense, and gives the same image as:
        // http://wms.jpl.nasa.gov/wms.cgi?request=GetMap&width=512&height=512&layers=daily_planet&styles=&srs=EPSG:4326&format=image/jpeg&bbox=-180,-90,180,90
        
        coord = sourceCoordinate(coord);
        
        var tilesWide : Float = Math.pow(2, coord.zoom);
        var tilesHigh : Float = Math.pow(2, coord.zoom - 1);
        
        var w : Float = -180.0 + (360.0 * coord.column / tilesWide);
        var n : Float = 90 - (180.0 * coord.row / tilesHigh);
        var e : Float = w + (360.0 / tilesWide);
        var s : Float = n + (180.0 / tilesHigh);
        
        var bbox : String = [w, s, e, n].join(",");
        
        // don't use URLVariables to build this URL, because there's a chance that the cache might require things in a particular order
        // here's the pattern: request=GetMap&layers=daily_planet&srs=EPSG:4326&format=image/jpeg&styles=&width=512&height=512&bbox=-180,88,-178,90
        // from http://onearth.jpl.nasa.gov/wms.cgi?request=GetTileService
        var url : String = "http://wms.jpl.nasa.gov/wms.cgi?" +
        "request=GetMap" +
        "&layers=daily_planet" +
        "&srs=EPSG:4326" +
        "&format=image/jpeg" +
        "&styles=" +
        "&width=512" +
        "&height=512" +
        "&bbox=" + bbox;
        
        //trace(coord, bbox);
        //trace(url);
        return [url];
    }
    
    public function toString() : String
    {
        return "DAILY_PLANET";
    }
    
    override public function sourceCoordinate(coord : Coordinate) : Coordinate
    {
        var tilesWide : Float = Math.pow(2, coord.zoom);
        var tilesHigh : Float = Math.ceil(Math.pow(2, coord.zoom - 1));
        coord = coord.copy();
        while (coord.row < 0)coord.row += tilesHigh;
        while (coord.column < 0)coord.column += tilesWide;
        coord.row %= tilesHigh;
        coord.column %= tilesWide;
        return coord;
    }
    
    override private function get_TileWidth() : Float
    {
        return 512;
    }
    
    override private function get_TileHeight() : Float
    {
        return 512;
    }
}
