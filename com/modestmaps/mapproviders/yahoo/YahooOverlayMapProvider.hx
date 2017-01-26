package com.modestmaps.mapproviders.yahoo;

import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.AbstractMapProvider;
import com.modestmaps.mapproviders.IMapProvider;

/**
	 * @author darren
	 * $Id$
	 */
class YahooOverlayMapProvider extends AbstractMapProvider implements IMapProvider
{
	public function new(minZoom : Int = MIN_ZOOM, maxZoom : Int = MAX_ZOOM)
	{
		super(minZoom, maxZoom);
	}

	public function toString() : String
	{
		return "YAHOO_OVERLAY";
	}

	public function getTileUrls(coord : Coordinate) : Array<Dynamic>
	{
		return ["http://us.maps3.yimg.com/aerial.maps.yimg.com/img?md=200608221700&v=2.0&t=h" + getZoomString(sourceCoordinate(coord))];
	}

	private function getZoomString(coord : Coordinate) : String
	{
		var row : Float = (Math.pow(2, coord.zoom) / 2) - coord.row - 1;
		return "&x=" + coord.column + "&y=" + row + "&z=" + (18 - coord.zoom);
	}
}
