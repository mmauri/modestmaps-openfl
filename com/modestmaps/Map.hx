/**
 * vim:et sts=4 sw=4 cindent:
 * @ignore
 *
 * @author migurski
 * @author darren
 * @author tom
 *
 * com.modestmaps.Map is the base class and interface for Modest Maps.
 *
 * @description Map is the base class and interface for Modest Maps.
 * 				Correctly attaching an instance of this Sprite subclass
 * 				should result in a pannable map. Controls and event
 * 				handlers must be added separately.
 *
 * @usage <code>
 *          import com.modestmaps.Map;
 *          import com.modestmaps.geo.Location;
 *          import com.modestmaps.mapproviders.BlueMarbleMapProvider;
 *          ...
 *          var map:Map = new Map(640, 480, true, new BlueMarbleMapProvider());
 *          addChild(map);
 *        </code>
 *
 */
package com.modestmaps;

import com.modestmaps.core.*;
import com.modestmaps.core.Coordinate;
import com.modestmaps.core.MapExtent;
import com.modestmaps.core.TileGrid;
import com.modestmaps.events.*;
import com.modestmaps.events.MapEvent;
import com.modestmaps.geo.*;
import com.modestmaps.geo.Location;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.OpenStreetMapProvider;
import com.modestmaps.overlays.MarkerClip;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;



@:meta(Event(name="startZooming",type="com.modestmaps.events.MapEvent"))

@:meta(Event(name="stopZooming",type="com.modestmaps.events.MapEvent"))

@:meta(Event(name="zoomedBy",type="com.modestmaps.events.MapEvent"))

@:meta(Event(name="startPanning",type="com.modestmaps.events.MapEvent"))

@:meta(Event(name="stopPanning",type="com.modestmaps.events.MapEvent"))

@:meta(Event(name="panned",type="com.modestmaps.events.MapEvent"))

@:meta(Event(name="resized",type="com.modestmaps.events.MapEvent"))

@:meta(Event(name="mapProviderChanged",type="com.modestmaps.events.MapEvent"))

@:meta(Event(name="beginExtentChange",type="com.modestmaps.events.MapEvent"))

@:meta(Event(name="extentChanged",type="com.modestmaps.events.MapEvent"))

@:meta(Event(name="beginTileLoading",type="com.modestmaps.events.MapEvent"))

@:meta(Event(name="allTilesLoaded",type="com.modestmaps.events.MapEvent"))

@:meta(Event(name="rendered",type="com.modestmaps.events.MapEvent"))

@:meta(Event(name="markerRollOver",type="com.modestmaps.events.MarkerEvent"))

@:meta(Event(name="markerRollOut",type="com.modestmaps.events.MarkerEvent"))

@:meta(Event(name="markerClick",type="com.modestmaps.events.MarkerEvent"))

class Map extends Sprite
{
	public var size(get, set) : Point;

	private var mapWidth : Float;
	private var mapHeight : Float;
	private var __draggable : Bool = true;

	/** das grid */
	public var grid : TileGrid;

	/** markers are attached here */
	public var markerClip : MarkerClip;

	/** Who do we get our Map urls from? How far can we pan? */
	private var mapProvider : IMapProvider;

	/** fraction of width/height to pan panLeft, panRight, panUp, panDown
		 * @default 0.333333333
		 */
	private var panFraction : Float = 0.333333333;
	private static inline var LN2 = 0.6931471805599453;

	/**
	    * Initialize the map: set properties, add a tile grid, draw it.
	    * Default extent covers the entire globe, (+/-85, +/-180).
	    *
	    * @param    Width of map, in pixels.
	    * @param    Height of map, in pixels.
	    * @param    Whether the map can be dragged or not.
	    * @param    Desired map provider, e.g. Blue Marble.
	    * @param    Either a MapExtent or a Location and zoom (comma separated)
	    *
	    * @see com.modestmaps.core.TileGrid
	    */
	public function new(width : Float = 320, height : Float = 240, draggable : Bool = true,
						mapProvider : IMapProvider = null, rest : Array<Dynamic> = null)
	{
		super();
		if (mapProvider == null)             mapProvider = new OpenStreetMapProvider();  // TODO getter/setter for this that disables interaction in TileGrid  ;

		__draggable = draggable;

		// don't call setMapProvider here
		// the extent calculations are all squirrely
		this.mapProvider = mapProvider;

		// initialize the grid (so point/location/coordinate functions should be valid after this)
		grid = new TileGrid(width, height, draggable, mapProvider);
		grid.addEventListener(Event.CHANGE, onExtentChanged);
		addChild(grid);

		setSize(width, height);

		markerClip = new MarkerClip(this);
		addChild(markerClip);

		// if rest was passed in from super constructor in a subclass,
		// it will be an array...
		if (rest != null && rest.length > 0 && Std.is(rest[0], Array))
		{
			rest = rest[0];
		}  // look at ... rest arguments for MapExtent or Location/zoom    // (doing that is OK because none of the arguments we're expecting are Arrays)

		if (rest != null && rest.length > 0 && Std.is(rest[0], MapExtent))
		{
			setExtent(cast(rest[0], MapExtent));
		}
		//addChild(grid.debugField);
		else if (rest != null && rest.length > 1 && Std.is(rest[0], Location) && Std.is(rest[1], Float))
		{
			setCenterZoom(cast(rest[0], Location), cast(rest[1], Float));
		}
		else
		{
			// use the whole world as a default
			var extent : MapExtent = new MapExtent(85, -85, 180, -180);

			// but adjust to fit the mapprovider's outer limits if there are any:
			var l1 : Location = mapProvider.coordinateLocation(mapProvider.outerLimits()[0]);
			var l2 : Location = mapProvider.coordinateLocation(mapProvider.outerLimits()[1]);

			if (!Math.isNaN(l1.lat) && Math.isFinite(Math.abs(l1.lat)))
			{
				extent.north = l1.lat;
			}
			if (!Math.isNaN(l2.lat) && Math.isFinite(Math.abs(l2.lat)))
			{
				extent.south = l2.lat;
			}
			if (!Math.isNaN(l1.lon) && Math.isFinite(Math.abs(l1.lon)))
			{
				extent.west = l1.lon;
			}
			if (!Math.isNaN(l2.lon) && Math.isFinite(Math.abs(l2.lon)))
			{
				extent.east = l2.lon;
			}

			setExtent(extent);
		}
	}

	/**
	    * Based on an array of locations, determine appropriate map
	    * bounds using calculateMapExtent(), and inform the grid of
	    * tile coordinate and point by calling grid.resetTiles().
	    * Resulting map extent will ensure that all passed locations
	    * are visible.
	    *
	    * @param extent the minimum area to fit inside the map view
	    *
	    * @see com.modestmaps.Map#calculateMapExtent
	    * @see com.modestmaps.core.TileGrid#resetTiles
	    */
	public function setExtent(extent : MapExtent) : Void
	{
		//trace('applying extent', extent);
		onExtentChanging();
		// tell grid what the rock is cooking
		grid.resetTiles(locationsCoordinate([extent.northWest, extent.southEast]));
		onExtentChanged();
	}

	/**
	    * Based on a location and zoom level, determine appropriate initial
	    * tile coordinate and point using calculateMapCenter(), and inform
	    * the grid of tile coordinate and point by calling grid.resetTiles().
	    *
	    * @param    Location of center.
	    * @param    Desired zoom level.
	    *
	    * @see com.modestmaps.Map#calculateMapExtent
	    * @see com.modestmaps.core.TileGrid#resetTiles
	    */
	public function setCenterZoom(location : Location, zoom : Float) : Void
	{
		if (zoom == grid.zoomLevel)
		{
			setCenter(location);
		}
		else {
			onExtentChanging();
			zoom = Math.min(Math.max(zoom, grid.minZoom), grid.maxZoom);
			// tell grid what the rock is cooking
			grid.resetTiles(mapProvider.locationCoordinate(location).zoomTo(zoom));
			onExtentChanged();
		}
	}

	/**
	 * Based on a zoom level, determine appropriate initial
	 * tile coordinate and point using calculateMapCenter(), and inform
	 * the grid of tile coordinate and point by calling grid.resetTiles().
	 *
	 * @param    Desired zoom level.
	 *
	 * @see com.modestmaps.Map#calculateMapExtent
	 * @see com.modestmaps.core.TileGrid#resetTiles
	 */
	public function setZoom(zoom : Float) : Void
	{
		if (zoom != grid.zoomLevel)
		{
			// TODO: if grid enforces this in enforceBounds, do we need to do it here too?
			grid.zoomLevel = Std.int(Math.min(Math.max(zoom, grid.minZoom), grid.maxZoom));
		}
	}

	public function extentCoordinate(extent : MapExtent) : Coordinate
	{
		return locationsCoordinate([extent.northWest, extent.southEast]);
	}

	public function locationsCoordinate(locations : Array<Location>, fitWidth : Float = 0, fitHeight : Float = 0) : Coordinate
	{
		if (fitWidth == 0)             fitWidth = mapWidth;
		if (fitHeight == 0)             fitHeight = mapHeight;

		var TL : Coordinate = mapProvider.locationCoordinate(locations[0].normalize());
		var BR : Coordinate = TL.copy();

		// get outermost top left and bottom right coordinates to cover all locations
		for (i in 1...locations.length)
		{
			var coordinate : Coordinate = mapProvider.locationCoordinate(locations[i].normalize());
			TL.row = Math.min(TL.row, coordinate.row);
			TL.column = Math.min(TL.column, coordinate.column);
			TL.zoom = Math.min(TL.zoom, coordinate.zoom);
			BR.row = Math.max(BR.row, coordinate.row);
			BR.column = Math.max(BR.column, coordinate.column);
			BR.zoom = Math.max(BR.zoom, coordinate.zoom);
		}  // multiplication factor between horizontal span and map width

		var hFactor : Float = (BR.column - TL.column) / (fitWidth / mapProvider.tileWidth);

		// multiplication factor expressed as base-2 logarithm, for zoom difference
		var hZoomDiff : Float = Math.log(hFactor) / LN2;

		// possible horizontal zoom to fit geographical extent in map width
		var hPossibleZoom : Float = TL.zoom - Math.ceil(hZoomDiff);

		// multiplication factor between vertical span and map height
		var vFactor : Float = (BR.row - TL.row) / (fitHeight / mapProvider.tileHeight);

		// multiplication factor expressed as base-2 logarithm, for zoom difference
		var vZoomDiff : Float = Math.log(vFactor) / LN2;

		// possible vertical zoom to fit geographical extent in map height
		var vPossibleZoom : Float = TL.zoom - Math.ceil(vZoomDiff);

		// initial zoom to fit extent vertically and horizontally
		// additionally, make sure it's not outside the boundaries set by provider limits
		var initZoom : Float = Math.min(hPossibleZoom, vPossibleZoom);
		initZoom = Math.min(initZoom, mapProvider.outerLimits()[1].zoom);
		initZoom = Math.max(initZoom, mapProvider.outerLimits()[0].zoom);

		// coordinate of extent center
		var centerRow : Float = (TL.row + BR.row) / 2;
		var centerColumn : Float = (TL.column + BR.column) / 2;
		var centerZoom : Float = (TL.zoom + BR.zoom) / 2;
		var centerCoord : Coordinate = (new Coordinate(centerRow, centerColumn, centerZoom)).zoomTo(initZoom);

		return centerCoord;
	}

	/*
	    * Return a MapExtent for the current map view.
	    * TODO: MapExtent needs adapting to deal with non-rectangular map projections
	    *
	    * @return   MapExtent object
	    */
	public function getExtent() : MapExtent
	{
		var extent : MapExtent = new MapExtent();

		if (mapProvider == null)
		{
			throw new Error("WHOAH, no mapProvider in getExtent!");
		}

		extent.northWest = mapProvider.coordinateLocation(grid.topLeftCoordinate);
		extent.southEast = mapProvider.coordinateLocation(grid.bottomRightCoordinate);
		return extent;
	}

	/*
	    * Return the current center location and zoom of the map.
	    *
	    * @return   Array of center and zoom: [center location, zoom number].
	    */
	public function getCenterZoom() : Array<Dynamic>
	{
		return [mapProvider.coordinateLocation(grid.centerCoordinate), grid.zoomLevel];
	}

	/*
	    * Return the current center location of the map.
	    *
	    * @return center Location
	    */
	public function getCenter() : Location
	{
		return mapProvider.coordinateLocation(grid.centerCoordinate);
	}

	/*
	    * Return the current zoom level of the map.
	    *
	    * @return   zoom number
	    */
	public function getZoom() : Int
	{
		return Math.floor(grid.zoomLevel);
	}

	/**
	    * Set new map size, dispatch MapEvent.RESIZED.
	    * The MapEvent includes the newSize.
	    *
	    * @param w New map width.
	    * @param h New map height.
	    *
	    * @see com.modestmaps.events.MapEvent.RESIZED
	    */
	public function setSize(w : Float, h : Float) : Void
	{
		if (w != mapWidth || h != mapHeight)
		{
			mapWidth = w;
			mapHeight = h;

			// mask out out of bounds marker remnants
			scrollRect = new Rectangle(0, 0, mapWidth, mapHeight);

			grid.resizeTo(new Point(mapWidth, mapHeight));

			dispatchEvent(new MapEvent(MapEvent.RESIZED, [this.size]));
		}
	}

	/**
	    * Get map size.
	    *
	    * @return   Array of [width, height].
	    */
	/*  public function getSize() : Point
	  {
		return  new Point(mapWidth, mapHeight);
	  }*/

	private function get_size() : Point
	{
		return new Point(mapWidth, mapHeight);
	}

	private function set_size(value : Point) : Point
	{
		setSize(value.x, value.y);
		return value;
	}

	/** Get map width. */
	public function getWidth() : Float
	{
		return mapWidth;
	}

	/** Get map height. */
	public function getHeight() : Float
	{
		return mapHeight;
	}

	/**
	    * Get a reference to the current map provider.
	    *
	    * @return   Map provider.
	    *
	    * @see com.modestmaps.mapproviders.IMapProvider
	    */
	public function getMapProvider() : IMapProvider
	{
		return mapProvider;
	}

	/**
	    * Set a new map provider, repainting tiles and changing bounding box if necessary.
	    *
	    * @param   Map provider.
	    *
	    * @see com.modestmaps.mapproviders.IMapProvider
	    */
	public function setMapProvider(newProvider : IMapProvider) : Void
	{
		var previousGeometry : String=null;
		if (mapProvider != null)
		{
			previousGeometry = mapProvider.geometry();
		}
		var extent : MapExtent = getExtent();

		mapProvider = newProvider;
		if (grid != null)
		{
			grid.setMapProvider(mapProvider);
		}

		if (mapProvider.geometry() != previousGeometry)
		{
			setExtent(extent);
		}  // among other things this will notify the marker clip that its cached coordinates are invalid

		dispatchEvent(new MapEvent(MapEvent.MAP_PROVIDER_CHANGED, [{newProvider;}] ));
	}

	/**
	    * Get a point (x, y) for a location (lat, lon) in the context of a given clip.
	    *
	    * @param    Location to match.
	    * @param    Movie clip context in which returned point should make sense.
	    *
	    * @return   Matching point.
	    */
	public function locationPoint(location : Location, context : DisplayObject = null) : Point
	{
		var coord : Coordinate = mapProvider.locationCoordinate(location);
		return grid.coordinatePoint(coord, context);
	}

	/**
	    * Get a location (lat, lon) for a point (x, y) in the context of a given clip.
	    *
	    * @param    Point to match.
	    * @param    Movie clip context in which passed point should make sense.
	    *
	    * @return   Matching location.
	    */
	public function pointLocation(point : Point, context : DisplayObject = null) : Location
	{
		var coord : Coordinate = grid.pointCoordinate(point, context);
		return mapProvider.coordinateLocation(coord);
	}

	/** Pan up by 1/3 (or panFraction) of the map height. */
	public function panUp(event : Event = null) : Void
	{
		panBy(0, mapHeight * panFraction);
	}

	/** Pan down by 1/3 (or panFraction) of the map height. */
	public function panDown(event : Event = null) : Void
	{
		panBy(0, -mapHeight * panFraction);
	}

	/** Pan left by 1/3 (or panFraction) of the map width. */
	public function panLeft(event : Event = null) : Void
	{
		panBy((mapWidth * panFraction), 0);
	}

	/** Pan left by 1/3 (or panFraction) of the map width. */
	public function panRight(event : Event = null) : Void
	{
		panBy(-(mapWidth * panFraction), 0);
	}

	public function panBy(px : Float, py : Float) : Void
	{
		if (!grid.panning && !grid.zooming)
		{
			grid.prepareForPanning();
			grid.tx += px;
			grid.ty += py;
			grid.donePanning();
		}
	}

	/** zoom in, keeping the requested point in the same place */
	public function zoomInAbout(targetPoint : Point = null, duration : Float = -1) : Void
	{
		zoomByAbout(1, targetPoint, duration);
	}

	/** zoom out, keeping the requested point in the same place */
	public function zoomOutAbout(targetPoint : Point = null, duration : Float = -1) : Void
	{
		zoomByAbout(-1, targetPoint, duration);
	}

	/** zoom in or out by zoomDelta, keeping the requested point in the same place */
	public function zoomByAbout(zoomDelta : Float, targetPoint : Point = null, duration : Float = -1) : Void
	{
		if (targetPoint == null)             targetPoint = new Point(mapWidth / 2, mapHeight / 2);

		if (grid.zoomLevel + zoomDelta < grid.minZoom)
		{
			zoomDelta = grid.minZoom - grid.zoomLevel;
		}
		else if (grid.zoomLevel + zoomDelta > grid.maxZoom)
		{
			zoomDelta = grid.maxZoom - grid.zoomLevel;
		}

		var sc : Float = Math.pow(2, zoomDelta);

		grid.prepareForZooming();
		grid.prepareForPanning();

		var m : Matrix = grid.getMatrix();

		m.translate(-targetPoint.x, -targetPoint.y);
		m.scale(sc, sc);
		m.translate(targetPoint.x, targetPoint.y);

		grid.setMatrix(m);

		grid.doneZooming();
		grid.donePanning();
	}

	public function getRotation() : Float
	{
		var m : Matrix = grid.getMatrix();
		var px : Point = m.deltaTransformPoint(new Point(0, 1));
		return Math.atan2(px.y, px.x);
	}

	/** rotate to angle (radians), keeping the requested point in the same place */
	public function setRotation(angle : Float, targetPoint : Point = null) : Void
	{
		var rotation : Float = getRotation();
		rotateByAbout(angle - rotation, targetPoint);
	}

	/** rotate by angle (radians), keeping the requested point in the same place */
	public function rotateByAbout(angle : Float, targetPoint : Point = null) : Void
	{
		if (targetPoint == null)             targetPoint = new Point(mapWidth / 2, mapHeight / 2);

		grid.prepareForZooming();
		grid.prepareForPanning();

		var m : Matrix = grid.getMatrix();

		m.translate(-targetPoint.x, -targetPoint.y);
		m.rotate(angle);
		m.translate(targetPoint.x, targetPoint.y);

		grid.setMatrix(m);

		grid.doneZooming();
		grid.donePanning();
	}

	/** zoom in and put the given location in the center of the screen, or optionally at the given targetPoint */
	public function panAndZoomIn(location : Location, targetPoint : Point = null) : Void
	{
		panAndZoomBy(2, location, targetPoint);
	}

	/** zoom out and put the given location in the center of the screen, or optionally at the given targetPoint */
	public function panAndZoomOut(location : Location, targetPoint : Point = null) : Void
	{
		panAndZoomBy(0.5, location, targetPoint);
	}

	/** zoom in or out by sc, moving the given location to the requested target */
	public function panAndZoomBy(sc : Float, location : Location, targetPoint : Point = null, duration : Float = -1) : Void
	{
		if (targetPoint == null)             targetPoint = new Point(mapWidth / 2, mapHeight / 2);

		var p : Point = locationPoint(location);

		grid.prepareForZooming();
		grid.prepareForPanning();

		var m : Matrix = grid.getMatrix();

		m.translate(-p.x, -p.y);
		m.scale(sc, sc);
		m.translate(targetPoint.x, targetPoint.y);

		grid.setMatrix(m);

		grid.donePanning();
		grid.doneZooming();
	}

	/** put the given location in the middle of the map */
	public function setCenter(location : Location) : Void
	{
		onExtentChanging();
		// tell grid what the rock is cooking
		grid.resetTiles(mapProvider.locationCoordinate(location).zoomTo(grid.zoomLevel));
		onExtentChanged();
	}

	/**
	    * Zoom in by one zoom level (to 200%) immediately,
	    * rounding up to the nearest zoom level if we're currently between zooms.
	    *
	    * <p>Triggers MapEvent.START_ZOOMING and MapEvent.STOP_ZOOMING events.</p>
	    *
	    * @param event an optional event so that zoomIn can directly function as an event listener.
	    */
	public function zoomIn(event : Event = null) : Void
	{
		zoomBy(1);
	}

	/**
	    * Zoom out by one zoom level (to 50%) immediately,
	    * rounding down to the nearest zoom level if we're currently between zooms.
	    *
	    * <p>Triggers MapEvent.START_ZOOMING and MapEvent.STOP_ZOOMING events.</p>
	    *
	    * @param event an optional event so that zoomOut can directly function as an event listener.
	    */
	public function zoomOut(event : Event = null) : Void
	{
		zoomBy(-1);
	}

	/**
		 * Adds dir to grid.zoomLevel, and rounds up or down to the nearest whole number.
		 * Used internally by zoomIn and zoomOut (keeping it DRY, as they say)
		 * and overridden by TweenMap for animation.
		 *
		 * <p>grid.zoomLevel calls the grid.scale setter for us
		 * which will call grid.prepareForZooming if we didn't already
		 * and grid.doneZooming after modifying the zoom level.</p>
		 *
		 * <p>Animating/tweening grid.scale fires START_ZOOMING, and STOP_ZOOMING
		 * MapEvents unless you call grid.prepareForZooming first. Be sure
		 * to also call grid.stopZooming at the end of your animation.
		 *
		 * @param dir the direction of zoom, generally 1 for zooming in, or -1 for zooming out
		 *
		 */
	private function zoomBy(dir : Int) : Void
	{
		if (!grid.panning)
		{
			var target : Float = dir < (0) ? Math.floor(grid.zoomLevel + dir) : Math.ceil(grid.zoomLevel + dir);
			grid.zoomLevel = Std.int(Math.min(Math.max(grid.minZoom, target), grid.maxZoom));
		}
	}

	/**
	    * Add a marker at the given location (lat, lon)
	    *
	    * @param    Location of marker.
	    * @param	optionally, a sprite (where sprite.name=id) that will always be in the right place
	    */
	public function putMarker(location : Location, marker : DisplayObject = null) : Void
	{
		markerClip.attachMarker(marker, location);
	}

	/**
		 * Get a marker with the given id if one was created.
		 *
		 * @param    ID of marker, opaque string.
		 */
	public function getMarker(id : String) : DisplayObject
	{
		return markerClip.getMarker(id);
	}

	/**
	    * Remove a marker with the given id.
	    *
	    * @param    ID of marker, opaque string.
	    */
	public function removeMarker(id : String) : Void
	{
		markerClip.removeMarker(id);
	}

	public function removeAllMarkers() : Void
	{
		markerClip.removeAllMarkers();
	}

	/**
	    * Dispatches MapEvent.EXTENT_CHANGED when the map is recentered.
	    * The MapEvent includes the new extent.
	    *
	    * TODO: dispatch this on resize?
	    * TODO: should we move Map to com.modestmaps.core so that this could be made internal instead of public?
	    *
	    * @see com.modestmaps.events.MapEvent.EXTENT_CHANGED
	    */
	private function onExtentChanged(event : Event = null) : Void
	{
		if (hasEventListener(MapEvent.EXTENT_CHANGED))
		{
			dispatchEvent(new MapEvent(MapEvent.EXTENT_CHANGED,  [ {getExtent();}] ));
		}
	}

	/**
	    * Dispatches MapEvent.BEGIN_EXTENT_CHANGE when the map is about to be resized.
	    * The MapEvent includes the current.
	    *
	    * @see com.modestmaps.events.MapEvent.BEGIN_EXTENT_CHANGE
	    */
	private function onExtentChanging() : Void
	{
		if (hasEventListener(MapEvent.BEGIN_EXTENT_CHANGE))
		{
			dispatchEvent(new MapEvent(MapEvent.BEGIN_EXTENT_CHANGE, [ {getExtent();}] ));
		}
	}

	private function set_DoubleClickEnabled(enabled : Bool) : Bool
	{
		this.doubleClickEnabled = enabled;
		trace("doubleClickEnabled on Map is no longer necessary!");
		trace("\tto enable useful defaults, use:");
		trace("\tmap.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);");
		return enabled;
	}

	/** pans and zooms in on double clicked location */
	public function onDoubleClick(event : MouseEvent) : Void
	{
		if (!__draggable)             return;

		var p : Point = grid.globalToLocal(new Point(event.stageX, event.stageY));
		if (event.shiftKey)
		{
			if (grid.zoomLevel > grid.minZoom)
			{
				zoomOutAbout(p);
			}
			else
			{
				panBy(mapWidth / 2 - p.x, mapHeight / 2 - p.y);
			}
		}
		else if (event.ctrlKey)
		{
			panAndZoomIn(pointLocation(p));
		}
		else {
			if (grid.zoomLevel < grid.maxZoom)
			{
				zoomInAbout(p);
			}
			else {
				panBy(mapWidth / 2 - p.x, mapHeight / 2 - p.y);
			}
		}
	}

	private var previousWheelEvent : Float = 0;
	private var minMouseWheelInterval : Float = 100;

	public function onMouseWheel(event : MouseEvent) : Void
	{
		if (Math.round(haxe.Timer.stamp() * 1000) - previousWheelEvent > minMouseWheelInterval)
		{
			if (event.delta > 0)
			{
				zoomInAbout(new Point(mouseX, mouseY), 0);
			}
			else if (event.delta < 0)
			{
				zoomOutAbout(new Point(mouseX, mouseY), 0);
			}
			previousWheelEvent = Math.round(haxe.Timer.stamp() * 1000);
		}
	}

	/*	public function onGestureZoom(event : flash.events.TransformGestureEvent) : Void
		{
			var a = 0;
		}*/
}

