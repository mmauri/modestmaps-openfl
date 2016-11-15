package com.modestmaps.mapproviders.yahoo;


import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.AbstractMapProvider;
import com.modestmaps.mapproviders.IMapProvider;

/**
	 * @author darren
	 * $Id$
	 */
class YahooAerialMapProvider extends AbstractMapProvider implements IMapProvider
{
    public function new(minZoom : Int = AbstractMapProvider.MIN_ZOOM, maxZoom : Int = AbstractMapProvider.MAX_ZOOM)
    {
        super(minZoom, maxZoom);
    }
    
    public function toString() : String
    {
        return "YAHOO_AERIAL";
    }
    
    public function getTileUrls(coord : Coordinate) : Array<String>
    {
        return ["http://us.maps3.yimg.com/aerial.maps.yimg.com/tile?v=1.7&t=a" + getZoomString(sourceCoordinate(coord))];
    }
    
    private function getZoomString(coord : Coordinate) : String
    {
        var row : Float = (Math.pow(2, coord.zoom) / 2) - coord.row - 1;
        return "&x=" + coord.column + "&y=" + row + "&z=" + (18 - coord.zoom);
    }
}
