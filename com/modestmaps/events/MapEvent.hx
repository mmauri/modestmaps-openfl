/*
 * $Id$
 */

package com.modestmaps.events;

import com.modestmaps.core.MapExtent;
import com.modestmaps.mapproviders.IMapProvider;
import openfl.events.Event;
import openfl.geom.Point;


class MapEvent extends Event
{
	public static inline var INITIALIZED : String = "mapInitialized";
	public static inline var CHANGED : String = "mapChanged";

	public static inline var START_ZOOMING : String = "startZooming";
	public static inline var STOP_ZOOMING : String = "stopZooming";
	public var zoomLevel : Float;

	public static inline var ZOOMED_BY : String = "zoomedBy";
	public var zoomDelta : Float;

	public static inline var START_PANNING : String = "startPanning";
	public static inline var STOP_PANNING : String = "stopPanning";

	public static inline var PANNED : String = "panned";
	public var panDelta : Point;

	public static inline var RESIZED : String = "resized";
	public var newSize : Point;

	public static inline var COPYRIGHT_CHANGED : String = "copyrightChanged";
	public var newCopyright : String;

	public static inline var BEGIN_EXTENT_CHANGE : String = "beginExtentChange";
	public var oldExtent : MapExtent;

	public static inline var EXTENT_CHANGED : String = "extentChanged";
	public var newExtent : MapExtent;

	public static inline var MAP_PROVIDER_CHANGED : String = "mapProviderChanged";
	public var newMapProvider : IMapProvider;

	public static inline var BEGIN_TILE_LOADING : String = "beginTileLoading";
	public static inline var ALL_TILES_LOADED : String = "alLTilesLoaded";

	/** listen out for this if you want to be sure map is in its final state before reprojecting markers etc. */
	public static inline var RENDERED : String = "rendered";

	public function new(type : String, rest : Array<Dynamic>)
	{
		super(type, true, true);

		switch (type)
		{
			case PANNED:
				if (rest.length > 0 && Std.is(rest[0], Point))
				{
					panDelta = rest[0];
				}
			case ZOOMED_BY:
				if (rest.length > 0 && Std.is(rest[0], Float))
				{
					zoomDelta = rest[0];
				}
			case EXTENT_CHANGED:
				if (rest.length > 0 && Std.is(rest[0], MapExtent))
				{
					newExtent = rest[0];
				}
			case START_ZOOMING, STOP_ZOOMING:
				if (rest.length > 0 && Std.is(rest[0], Float))
				{
					zoomLevel = rest[0];
				}
			case RESIZED:
				if (rest.length > 0 && Std.is(rest[0], Point))
				{
					newSize = rest[0];
				}
			case COPYRIGHT_CHANGED:
				if (rest.length > 0 && Std.is(rest[0], String))
				{
					newCopyright = rest[0];
				}
			case BEGIN_EXTENT_CHANGE:
				if (rest.length > 0 && Std.is(rest[0], MapExtent))
				{
					oldExtent = rest[0];
				}
			case MAP_PROVIDER_CHANGED:
				if (rest.length > 0 && Std.is(rest[0], IMapProvider))
				{
					newMapProvider = rest[0];
				}
		}
	}

	override public function clone() : Event
	{
		return new MapEvent(this.type,null);
	}
}

