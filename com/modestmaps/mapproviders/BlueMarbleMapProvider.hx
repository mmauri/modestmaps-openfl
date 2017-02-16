/**
 * @author migurski
 * $Id$
 */
package com.modestmaps.mapproviders;

import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.IMapProvider;


class BlueMarbleMapProvider extends AbstractMapProvider implements IMapProvider
{
	public var baseURL : String;

	public function new(minZoom : Int = AbstractMapProvider.MIN_ZOOM, maxZoom : Int = AbstractMapProvider.MAX_ZOOM)
	{
		super(minZoom, Math.min(9, maxZoom));
		if (baseURL == null)             
			baseURL = "http://s3.amazonaws.com/com.modestmaps.bluemarble/";
	}

	public function toString() : String
	{
		return "BLUE_MARBLE";
	}

	public function getTileUrls(coord : Coordinate) : Array<Dynamic>
	{
		var sourceCoord : Coordinate = sourceCoordinate(coord);
		if (sourceCoord.row < 0 || sourceCoord.row >= Math.pow(2, coord.zoom))
		{
			return [];
		}
		return [baseURL + (sourceCoord.zoom) + "-r" + (sourceCoord.row) + "-c" + (sourceCoord.column) + ".jpg"];
	}
}

