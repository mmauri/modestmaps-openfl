package com.modestmaps.overlays;

import com.modestmaps.Map;
import com.modestmaps.core.Coordinate;
import com.modestmaps.events.MapEvent;
import com.modestmaps.geo.Location;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Point;
import openfl.geom.Rectangle;


/**
	 * Polyline clip for rendering Polyline instances on your map.
	 *
	 * Polylines can be added using:
	 *
	 * <pre>
	 *  var polylineClip:PolylineClip = new PolylineClip(map);
	 *  map.addChild(polylineClip);
	 *
	 *  var polyline:Polyline = new Polyline('poly-id-1', [ new Location(10,10), new Location (20,20) ]);
	 *  polylineClip.addPolyline(polyline);
	 * </pre>
	 *
	 * @see Polyline
	 */
class PolylineClip extends Sprite
{
	private var dirty(get, set) : Bool;

	private var map : Map;

	private var drawCoord : Coordinate;

	private var polylines:Array<Polyline> = []; // all markers
	private var polylinesByName:StringMap<Polyline>= new StringMap<Polyline>();

	// enable this if you want intermediate zooming steps to
	// stretch your graphics instead of reprojecting the points
	// you'll probably want to set scaleMode to "none" in your polyline
	// if you enable this
	public var scaleZoom : Bool = true;

	private var _dirty : Bool = true;

	public function new(map : Map)
	{
		super();
		this.map = map;
		this.x = map.getWidth() / 2;
		this.y = map.getHeight() / 2;

		drawCoord = map.grid.centerCoordinate.copy();

		map.addEventListener(MapEvent.START_ZOOMING, onMapStartZooming);
		map.addEventListener(MapEvent.STOP_ZOOMING, onMapStopZooming);
		map.addEventListener(MapEvent.ZOOMED_BY, onMapZoomedBy);
		map.addEventListener(MapEvent.START_PANNING, onMapStartPanning);
		map.addEventListener(MapEvent.STOP_PANNING, onMapStopPanning);
		map.addEventListener(MapEvent.PANNED, onMapPanned);
		map.addEventListener(MapEvent.RESIZED, onMapResized);
		map.addEventListener(MapEvent.EXTENT_CHANGED, onMapExtentChanged);
		map.addEventListener(MapEvent.RENDERED, updatePolylines);
	}

	public function removePolylines() : Void
	{
		for (key in polylinesByName.keys))
		{
			polylinesByName.set(key) = null;
			polylinesByName.remove(key);
		}
		polylines = [];
		dirty = true;
	}

	public function addPolyline(polyline : Polyline) : Void
	{
		polylinesByName[polyline.id] = polyline;
		polylines.push(polyline);
		dirty = true;
	}

	public function getPolyline(id : String) : Polyline
	{
		return polylinesByName.get(id);
	}

	public function removePolyline(id : String) : Void
	{
		var polyline : Polyline = getPolyline(id);
		if (polyline != null)
		{
			//var index : Int = Lambda.indexOf(polylines, polyline);
			var index : Int = polylines.indexOf(polyline);
			if (index >= 0)
			{
				polylines.splice(index, 1);
			}
			;
		}
	}

	/**
		* Redraw each active polyline
		*/
	public function updatePolylines(event : Event = null) : Void
	{
		if (!dirty)             return;

		drawCoord = map.grid.centerCoordinate.copy();

		scaleX = scaleY = 1;

		x = map.getWidth() / 2;
		y = map.getHeight() / 2;

		this.graphics.clear();
		for (polyline in polylines)
		{
			updatePolyline(polyline);
		}

		dirty = false;
	}

	/**
		* Update an individual polyline - determine its visibility and draw if so
		*/
	public function updatePolyline(polyline : Polyline) : Void
	{
		var w : Float = map.getWidth() * 2;
		var h : Float = map.getHeight() * 2;

		var localPointsArray : Array<Dynamic> = new Array<Dynamic>();
		var i : Int = 0;

		this.graphics.lineStyle(polyline.lineThickness, polyline.lineColor, polyline.lineAlpha, polyline.pixelHinting, polyline.scaleMode, polyline.caps, polyline.joints, polyline.miterLimit);

		var boundaryWindow : Rectangle = new Rectangle(-w / 2, -h / 2, w, h);

		// Calculate local coordinates for each point
		for (i in 0...polyline.locationsArray.length)
		{
			var tLocation : Location = polyline.locationsArray[i];
			var point : Point = map.locationPoint(tLocation, this);
			localPointsArray.push(point);
		}

		for (i in 1...polyline.locationsArray.length)
		{
			// Create duplicates of each point for clipping
			var tPoint1 : Point = new Point(localPointsArray[i - 1].x, localPointsArray[i - 1].y);
			var tPoint2 : Point = new Point(localPointsArray[i].x, localPointsArray[i].y);

			// Clip each point and draw if visible
			if (clipLineToRect(tPoint1, tPoint2, boundaryWindow))
			{
				this.graphics.moveTo(tPoint1.x, tPoint1.y);
				this.graphics.lineTo(tPoint2.x, tPoint2.y);
			}
		}
	}

	/**
		* Test for a line intersection. TODO - tidy up as no need to calc line equation twice
		*/
	private function lineIntersectLine(v1 : Point, v2 : Point, v3 : Point, v4 : Point) : Bool
	{
		var denom : Float = ((v4.y - v3.y) * (v2.x - v1.x)) - ((v4.x - v3.x) * (v2.y - v1.y));
		var numerator : Float = ((v4.x - v3.x) * (v1.y - v3.y)) - ((v4.y - v3.y) * (v1.x - v3.x));
		var numerator2 : Float = ((v2.x - v1.x) * (v1.y - v3.y)) - ((v2.y - v1.y) * (v1.x - v3.x));
		if (denom == 0.0)
		{
			if (numerator == 0.0 && numerator2 == 0.0)                 return false  //COINCIDENT;  ;
				return false;
		}
		var ua : Float = numerator / denom;
		var ub : Float = numerator2 / denom;
		return (ua >= 0.0 && ua <= 1.0 && ub >= 0.0 && ub <= 1.0);
	}

	/**
		 * Clips a line (passed as 2 points) to a rectangle. Returns true if the line is at all visible, false if not
		 */
	private function clipLineToRect(v1 : Point, v2 : Point, r : Rectangle) : Bool
	{
		var lowerLeft : Point = new Point(r.x, r.y + r.height);
		var upperRight : Point = new Point(r.x + r.width, r.y);
		var upperLeft : Point = new Point(r.x, r.y);
		var lowerRight : Point = new Point(r.x + r.width, r.y + r.height);

		// Check completely out the box
		if (v1.x > upperRight.x && v2.x > upperRight.x)             return false;
		if (v1.x < upperLeft.x && v2.x < upperLeft.x)             return false;
		if (v1.y < upperRight.y && v2.y < upperRight.y)             return false;
		if (v1.y > lowerRight.y && v2.y > lowerRight.y)             return false  // check if it is inside  ;

			if (v1.x > lowerLeft.x && v1.x < upperRight.x && v1.y < lowerLeft.y && v1.y > upperRight.y &&
			v2.x > lowerLeft.x && v2.x < upperRight.x && v2.y < lowerLeft.y && v2.y > upperRight.y)
			{
				return true;
			}  // Calc gradient

		var gradient : Float = (v2.y - v1.y) / (v2.x - v1.x);
		// Calc constant
		var lineConstant : Float = v1.y - gradient * v1.x;

		// Check intersection with left of viewbox and clip
		if (lineIntersectLine(v1, v2, upperLeft, lowerLeft))
		{
			if (v1.x < v2.x)
			{
				v1.x = lowerLeft.x; v1.y = v1.x * gradient + lineConstant;
			}
			else
			{
				v2.x = lowerLeft.x; v2.y = v2.x * gradient + lineConstant;
			}
		}  // Check intersection with bottom of viewbox and clip

		if (lineIntersectLine(v1, v2, lowerLeft, lowerRight))
		{
			if (v1.y > v2.y)
			{
				v1.y = lowerRight.y; v1.x = (v1.y - lineConstant) / gradient;
			}
			else
			{
				v2.y = lowerRight.y; v2.x = (v2.y - lineConstant) / gradient;
			}
		}  // Check intersection with top of viewbox and clip

		if (lineIntersectLine(v1, v2, upperLeft, upperRight))
		{
			if (v1.y < v2.y)
			{
				v1.y = upperLeft.y; v1.x = (v1.y - lineConstant) / gradient;
			}
			else
			{
				v2.y = upperLeft.y; v2.x = (v2.y - lineConstant) / gradient;
			}
		}  // Check intersection with right of viewbox and clip

		if (lineIntersectLine(v1, v2, upperRight, lowerRight))
		{
			if (v1.x > v2.x)
			{
				v1.x = lowerRight.x; v1.y = v1.x * gradient + lineConstant;
			}
			else
			{
				v2.x = lowerRight.x; v2.y = v2.x * gradient + lineConstant;
			}
		}
		return true;
	}

	private function onMapStartPanning(event : MapEvent) : Void
	{
		cacheAsBitmap = true;
	}

	private function onMapExtentChanged(event : MapEvent) : Void
	{
		onMapPanned(event);
		onMapZoomedBy(event);
	}

	private function onMapPanned(event : MapEvent) : Void
	{
		var pt : Point = map.grid.coordinatePoint(drawCoord);
		x = pt.x;
		y = pt.y;
	}

	private function onMapStopPanning(event : MapEvent) : Void
	{
		cacheAsBitmap = false;
		dirty = true;
	}

	private function onMapResized(event : MapEvent) : Void
	{
		dirty = true;
		// Flash doesn't always dispatch a rendered event during resize
		// so...
		updatePolylines();
	}

	private function onMapStartZooming(event : MapEvent) : Void
	{
		cacheAsBitmap = false;
	}

	private function onMapStopZooming(event : MapEvent) : Void
	{
		dirty = true;
	}

	private function onMapZoomedBy(event : MapEvent) : Void
	{
		cacheAsBitmap = false;
		if (scaleZoom)
		{
			scaleX = scaleY = Math.pow(2, map.grid.zoomLevel - drawCoord.zoom);
		}
		else {
			dirty = true;
		}
	}

	private function set_Dirty(d : Bool) : Bool
	{
		_dirty = d;
		if (d)
		{
			// this requests an Event.RENDER which Map will
			// respond to and dispatch MapEvent.RENDERED
			// when it's done shuffling tiles
			if (stage)                 stage.invalidate();
		}
		return d;
	}

	private function get_Dirty() : Bool
	{
		return _dirty;
	}
}
