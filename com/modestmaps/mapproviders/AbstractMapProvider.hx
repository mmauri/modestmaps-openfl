/**
 * vim:et sts=4 sw=4 cindent:
 * @ignore
 *
 * @author darren
 * @author migurski
 * $Id$
 *
 * AbstractMapProvider is the base class for all MapProviders.
 *
 * @description AbstractMapProvider is the base class for all
 * 				MapProviders. MapProviders are primarily responsible
 * 				for "painting" map Tiles with the correct
 * 				graphic imagery.
 */

package com.modestmaps.mapproviders;

import com.modestmaps.core.Coordinate;
import com.modestmaps.geo.IProjection;
import com.modestmaps.geo.Location;
import com.modestmaps.geo.MercatorProjection;
import com.modestmaps.geo.Transformation;

class AbstractMapProvider
{
	public var tileWidth(get, never) : Int;
	public var tileHeight(get, never) : Int;

	private static inline var MIN_ZOOM : Int = 1;
	private static inline var MAX_ZOOM : Int = 20;

	private var __projection : IProjection;

	// boundaries for the current provider
	private var __topLeftOutLimit : Coordinate;
	private var __bottomRightInLimit : Coordinate;

	/*
		 * Abstract constructor, should not be instantiated directly.
		 */
	public function new(minZoom : Int = MIN_ZOOM, maxZoom : Int = MAX_ZOOM)
	{
		// see: http://modestmaps.mapstraction.com/trac/wiki/TileCoordinateComparisons#TileGeolocations
		var t : Transformation = new Transformation(1.068070779e7, 0, 3.355443185e7,
				0, -1.068070890e7, 3.355443057e7);

		__projection = new MercatorProjection(26, t);

		__topLeftOutLimit = new Coordinate(0, Math.NEGATIVE_INFINITY, minZoom);
		__bottomRightInLimit = (new Coordinate(1, Math.POSITIVE_INFINITY, 0)).zoomTo(maxZoom);
	}

	/*
	    * String signature of the current map provider's geometric behavior.
	    */
	public function geometry() : String
	{
		return Std.string(__projection);
	}

	/**
		 * Wraps the column around the earth, doesn't touch the row.
		 *
		 * Row coordinates shouldn't be outside of outerLimits,
		 * so we shouldn't need to worry about them here.
		 *
		 * @param coord The Coordinate to wrap.
		 */
	public function sourceCoordinate(coord : Coordinate) : Coordinate
	{
		var wrappedColumn : Float = coord.column % Math.pow(2, coord.zoom);

		while (wrappedColumn < 0)
		{
			wrappedColumn += Math.pow(2, coord.zoom);
		}  // we don't wrap rows here because the map/grid should be enforcing outerLimits :)

		return new Coordinate(coord.row, wrappedColumn, coord.zoom);
	}

	/**
	    * Get top left outer-zoom limit and bottom right inner-zoom limits,
	    * as Coordinates in a two element array.
	    */
	public function outerLimits() : Array<Coordinate>
	{
		return [__topLeftOutLimit.copy(), __bottomRightInLimit.copy()];
	}

	/*
	    * Return projected and transformed coordinate for a location.
	    */
	public function locationCoordinate(location : Location) : Coordinate
	{
		return __projection.locationCoordinate(location);
	}

	/*
	    * Return untransformed and unprojected location for a coordinate.
	    */
	public function coordinateLocation(coordinate : Coordinate) : Location
	{
		return __projection.coordinateLocation(coordinate);
	}

	private function get_tileWidth() : Int
	{
		return 256;
	}

	private function get_tileHeight() : Int
	{
		return 256;
	}
}
