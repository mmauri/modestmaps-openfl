package com.modestmaps.extras;

import com.modestmaps.Map;
import com.modestmaps.core.MapExtent;
import com.modestmaps.events.MapEvent;
import com.modestmaps.geo.Location;
import openfl.display.LineScaleMode;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.filters.DropShadowFilter;
import openfl.geom.Point;


/**
	 * NavigatorWindow creates a small navigator map that will stick to the bottom
	 * right-hand edge of a map and provide a zoomed-out context for the current
	 * visible area.
	 *
	 * The main 'magic' performed by this class is suppressing the map events from
	 * the nav map so that they don't bubble up and confused overlays that are
	 * listening to the map. This would be an issue because the navigator window
	 * might be added as a child of map.  I considered making it an option in
	 * Map and TileGrid to disable events, but then I realised I wanted the navMap
	 * to be interactive after all so that it could update the main map.
	 *
	 * Hat tip to http://www.cartogrammar.com/blog/map-panning-and-zooming-methods/
	 * for prompting the development of this class.
	 *
	 * Exercises for the reader:
	 * 1) add alignment options (top left etc.)?
	 * 2) add show and hide buttons
	 * 3) add dragging for resizing
	 * 4) add optional alternate map providers (a la maps.live.com)?
	 *
	 */
class NavigatorWindow extends Sprite
{
	private var map : Map;
	private var navMap : Map;
	private var box : Shape;

	private var zoomOffset : Int = 4;

	private var ignoreMap : Bool = false;
	private var ignoreNav : Bool = false;

	private var navWidth : Float;
	private var navHeight : Float;
	private var navBorder : Float;
	private var navBorderColor : Int;

	private var boxLineThickness : Float;
	private var boxLineColor : Int;
	private var boxFillColor : Int;
	private var boxFillAlpha : Float;

	/** create a new navigator window with optional size and style parameters */
	public function new(map : Map,
						navWidth : Int = 128,
						navHeight : Int = 128,
						navBorder : Float = 5,
						navBorderColor : Int = 0xffffff,
						boxLineThickness : Float = 0,
						boxLineColor : Int = 0xff0000,
						boxFillColor : Int = 0x000000,
						boxFillAlpha : Float = 0.2)
	{
		super();
		this.map = map;

		this.navWidth = navWidth;
		this.navHeight = navHeight;
		this.navBorder = navBorder;
		this.navBorderColor = navBorderColor;

		this.boxLineThickness = boxLineThickness;
		this.boxLineColor = boxLineColor;
		this.boxFillColor = boxFillColor;
		this.boxFillAlpha = boxFillAlpha;

		navMap = new Map(navWidth, navHeight, true, map.getMapProvider());
		navMap.name = "navMap";
		navMap.grid.enforceBoundsEnabled = false;
		// TODO: should this zoom offset depend on the relative sizes?
		navMap.setCenterZoom(map.getCenter(), map.getZoom() - zoomOffset);
		addChild(navMap);

		// this makes sure that the nav exists for filters
		navMap.graphics.clear();
		navMap.graphics.beginFill(0xeeeeee);
		navMap.graphics.drawRect(0, 0, navWidth, navHeight);

		navMap.filters = [new DropShadowFilter(2, 45, 0, 0.5, 4, 4, 1, 1, true)];

		box = new Shape();
		navMap.addChild(box);

		setPosition(null);

		navMap.addEventListener(MouseEvent.DOUBLE_CLICK, onNavDoubleClick, true);
		navMap.addEventListener(MouseEvent.MOUSE_WHEEL, onNavMouseWheel, true);

		navMap.addEventListener(MapEvent.ALL_TILES_LOADED, stopEvent);
		navMap.addEventListener(MapEvent.BEGIN_EXTENT_CHANGE, stopEvent);
		navMap.addEventListener(MapEvent.BEGIN_TILE_LOADING, stopEvent);
		navMap.addEventListener(MapEvent.COPYRIGHT_CHANGED, stopEvent);
		navMap.addEventListener(MapEvent.MAP_PROVIDER_CHANGED, stopEvent);
		navMap.addEventListener(MapEvent.RENDERED, stopEvent);
		navMap.addEventListener(MapEvent.RESIZED, stopEvent);
		navMap.addEventListener(MapEvent.START_ZOOMING, stopEvent);
		navMap.addEventListener(MapEvent.STOP_ZOOMING, stopEvent);
		navMap.addEventListener(MapEvent.ZOOMED_BY, stopEvent);

		navMap.addEventListener(MapEvent.EXTENT_CHANGED, syncMap);
		navMap.addEventListener(MapEvent.START_PANNING, onStartPanning);
		navMap.addEventListener(MapEvent.PANNED, syncMap);
		navMap.addEventListener(MapEvent.STOP_PANNING, onStopPanning);

		map.addEventListener(MapEvent.MAP_PROVIDER_CHANGED, onProviderChanged);
		map.addEventListener(MapEvent.EXTENT_CHANGED, syncNavMap);
		map.addEventListener(MapEvent.PANNED, syncNavMap);
		map.addEventListener(MapEvent.RESIZED, setPosition);
		map.addEventListener(MapEvent.START_PANNING, syncNavMap);
		map.addEventListener(MapEvent.START_ZOOMING, syncNavMap);
		map.addEventListener(MapEvent.STOP_PANNING, syncNavMap);
		map.addEventListener(MapEvent.STOP_ZOOMING, syncNavMap);
		map.addEventListener(MapEvent.ZOOMED_BY, syncNavMap);
	}

	private function onNavDoubleClick(event : MouseEvent) : Void
	{
		var l : Location = navMap.pointLocation(new Point(event.localX, event.localY));
		if (event.shiftKey)
		{
			map.panAndZoomOut(l);
		}
		else {
			map.panAndZoomIn(l);
		}
		event.stopImmediatePropagation();
	}

	private function onNavMouseWheel(event : MouseEvent) : Void
	{
		// TODO, if map is a TweenMap, do a version of TweenMap.onMouseWheel here
		event.stopImmediatePropagation();
	}

	private function setPosition(event : MapEvent) : Void
	{
		navMap.x = map.getWidth() - navWidth;
		navMap.y = map.getHeight() - navHeight;

		syncNavMap(event);

		graphics.clear();
		graphics.beginFill(navBorderColor);
		graphics.drawRect(navMap.x - navBorder, navMap.y - navBorder, navWidth + navBorder, navHeight + navBorder);
	}

	private function onProviderChanged(event : MapEvent) : Void
	{
		navMap.setMapProvider(event.newMapProvider);
	}

	private function syncNavMap(event : MapEvent) : Void
	{
		if (!ignoreMap)
		{

			if (event != null && event.currentTarget != map)                 return;

			ignoreNav = true;
			navMap.setCenter(map.getCenter());
			navMap.grid.zoomLevel = map.grid.zoomLevel - zoomOffset;
			ignoreNav = false;

			var extent : MapExtent = map.getExtent();

			var nw : Point = navMap.locationPoint(extent.northWest);
			var se : Point = navMap.locationPoint(extent.southEast);

			box.graphics.clear();
			box.graphics.lineStyle();
			box.graphics.beginFill(boxFillColor, boxFillAlpha);
			box.graphics.drawRect(0, 0, navWidth, navHeight);
			box.graphics.lineStyle(boxLineThickness, boxLineColor, 1, false, LineScaleMode.NONE);
			box.graphics.drawRect(nw.x, nw.y, se.x - nw.x, se.y - nw.y);
			box.graphics.endFill();
		}
	}

	private function onStartPanning(event : MapEvent) : Void
	{
		ignoreMap = true;
		stopEvent(event);
	}
	private function onStopPanning(event : MapEvent) : Void
	{
		ignoreMap = false;
		stopEvent(event);
	}

	private function syncMap(event : MapEvent) : Void
	{
		if (!ignoreNav)
		{
			map.setCenter(navMap.getCenter());
			map.grid.zoomLevel = navMap.grid.zoomLevel + zoomOffset;
		}

		stopEvent(event);
	}

	private function stopEvent(event : MapEvent) : Void
	{
		event.stopImmediatePropagation();
	}
}

