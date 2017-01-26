package com.modestmaps.overlays;

import com.modestmaps.Map;
import com.modestmaps.core.Coordinate;
import com.modestmaps.core.MapExtent;
import com.modestmaps.core.TileGrid;
import com.modestmaps.geo.Location;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.overlays.Redrawable;
import openfl.display.BitmapData;
import openfl.display.LineScaleMode;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Matrix;
import openfl.geom.Point;



class PolygonMarker extends Sprite implements Redrawable
{
	private var map : Map;
	private var provider : IMapProvider;
	private var drawZoom : Float;

	public var zoomTolerance : Float = 4;

	public var locations : Array<Dynamic>;
	private var coordinates : Array<Dynamic>;  // cached after converting locations with the map provider
	public var extent : MapExtent;
	public var location : Location;

	public var line : Bool = true;
	public var lineThickness : Float = 0;
	public var lineColor : Int = 0xffffff;
	public var lineAlpha : Float = 1;
	public var linePixelHinting : Bool = false;
	public var lineScaleMode : String = LineScaleMode.NONE;
	public var lineCaps : String = null;
	public var lineJoints : String = null;
	public var lineMiterLimit : Float = 3;

	public var autoClose : Bool = true;

	public var fill : Bool = true;
	public var fillColor : Int = 0xff0000;
	public var fillAlpha : Float = 0.2;

	public var bitmapFill : Bool = false;
	public var bitmapData : BitmapData = null;
	public var bitmapMatrix : Matrix = null;
	public var bitmapRepeat : Bool = false;
	public var bitmapSmooth : Bool = false;

	/**
		 * Creates a polygon from the given array (or array of arrays) of Locations.
		 *
		 * The polygon will use the given map to project the locations, and should be added to an
		 * instance of PolygonClip, which will add and remove it from the stage and position it
		 * as required.
		 *
		 * If an array of arrays of Locations is given, the first array will be drawn as the outer
		 * ring of the polygon, and subsequent arrays will be treated as holes if they overlap it.
		 *
		 */
	public function new(map : Map, locations : Array<Dynamic>, autoClose : Bool = true)
	{
		super();
		this.map = map;
		this.provider = map.getMapProvider();
		this.mouseEnabled = false;
		this.autoClose = autoClose;

		if (locations != null && locations.length > 0)
		{
			if (locations.length > 0 && Std.is(locations[0], Location))
			{
				locations = [locations];
			}
			if (locations[0].length > 0 && Std.is(locations[0], Array))
			{
				this.locations = [locations[0]];
				this.extent = MapExtent.fromLocations(locations[0]);
				this.location = try cast(locations[0][0], Location) catch (e:Dynamic) null;
				this.coordinates = [locations[0].map(l2c)];

				for (hole/* AS3HX WARNING could not determine type for var: hole exp: ECall(EField(EIdent(locations),slice),[EConst(CInt(1))]) type: null */ in locations.substring(1))
				{
					addHole(hole);
				}
			}
		}
	}

	public function addHole(hole : Array<Dynamic>) : Void
	{
		this.locations.push(hole);
		this.extent.encloseExtent(MapExtent.fromLocations(hole));
		this.coordinates.push(hole.map(l2c));
		updateGraphics();
	}

	private function l2c(l : Location) : Coordinate
	{
		return provider.locationCoordinate(l);
	}

	public function redraw(event : Event = null) : Void
	{
		if (event != null && drawZoom != 0 && Math.abs(map.grid.zoomLevel - drawZoom) < zoomTolerance)
		{
			scaleX = scaleY = Math.pow(2, map.grid.zoomLevel - drawZoom);
		}
		else {
			updateGraphics();
		}
	}

	public function updateGraphics() : Void
	{
		var grid : TileGrid = map.grid;

		drawZoom = grid.zoomLevel;
		scaleX = scaleY = 1;

		graphics.clear();
		if (line)
		{
			graphics.lineStyle(lineThickness, lineColor, lineAlpha, linePixelHinting, lineScaleMode, lineCaps, lineJoints, lineMiterLimit);
		}
		else {
			graphics.lineStyle();
		}
		if (fill)
		{
			if (bitmapFill && bitmapData != null)
			{
				graphics.beginBitmapFill(bitmapData, bitmapMatrix, bitmapRepeat, bitmapSmooth);
			}
			else
			{
				graphics.beginFill(fillColor, fillAlpha);
			}
		}

		if (location != null)
		{
			var firstPoint : Point = grid.coordinatePoint(coordinates[0][0]);
			for (ring in coordinates)
			{
				var ringPoint : Point = grid.coordinatePoint(ring[0]);
				graphics.moveTo(ringPoint.x - firstPoint.x, ringPoint.y - firstPoint.y);
				var p : Point;
				for (coord/* AS3HX WARNING could not determine type for var: coord exp: ECall(EField(EIdent(ring),slice),[EConst(CInt(1))]) type: null */ in ring.substring(1))
				{
					p = grid.coordinatePoint(coord);
					graphics.lineTo(p.x - firstPoint.x, p.y - firstPoint.y);
				}
				if (autoClose && !ringPoint.equals(p))
				{
					graphics.lineTo(ringPoint.x - firstPoint.x, ringPoint.y - firstPoint.y);
				}
			}
		}

		if (fill)
		{
			graphics.endFill();
		}
	}
}
