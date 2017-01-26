package com.modestmaps.extras;

import com.modestmaps.Map;
import com.modestmaps.events.MapEvent;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Point;


/** Overlay simplifies adding vector graphics to your map.
 * Subclass Overlay and override the redraw(sprite:Sprite) method to use it.
 */
class Overlay extends Sprite
{
	public var map : Map;

	private var panStart : Point;

	private var polySprite : Sprite = new Sprite();
	private var polyCont : Sprite = new Sprite();

	public function new(map : Map)
	{
		super();
		this.mouseEnabled = false;
		this.mouseChildren = false;
		this.map = map;
		this.cacheAsBitmap = true;
		//            this.blendMode = BlendMode.MULTIPLY;

		addChild(polyCont);
		polyCont.addChild(polySprite);
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	private function onAddedToStage(event : Event) : Void
	{
		refresh();
		onMapResize(null);
		map.addEventListener(MapEvent.START_PANNING, onMapStartPan);
		map.addEventListener(MapEvent.PANNED, onMapPanned);
		map.addEventListener(MapEvent.STOP_PANNING, onMapStopPan);
		map.addEventListener(MapEvent.ZOOMED_BY, onMapZoomedBy);
		map.addEventListener(MapEvent.STOP_ZOOMING, onEndZoom);
		map.addEventListener(MapEvent.EXTENT_CHANGED, onMapChange);
		map.addEventListener(MapEvent.RESIZED, onMapResize);
	}

	private function onMapResize(event : Event) : Void
	{
		/*             graphics.clear();
		graphics.beginFill(0xcccccc);
		var w:Number = map.getWidth();
		var h:Number = map.getHeight();
		graphics.drawRect(0, 0, w, h); */
		refresh();
	}

	public function refresh() : Void
	{
		polyCont.scaleX = polyCont.scaleY = 1.0;
		polyCont.x = stage.stageWidth / 2;
		polyCont.y = stage.stageHeight / 2;
		polySprite.x = stage.stageWidth / 2;
		polySprite.y = stage.stageHeight / 2;
		redraw(polySprite);
	}

	/** redraw the overlay onto the given Sprite - override this in your subclass */
	public function redraw(sprite : Sprite) : Void
	{
		trace("*** you should subclass Overlay and override redraw rather than using Overlay directly");
	}

	private function onMapZoomedBy(event : MapEvent) : Void
	{
		polyCont.scaleX = polyCont.scaleY = Math.pow(2, event.zoomDelta);
	}

	private function onEndZoom(event : MapEvent) : Void
	{
		refresh();
	}

	private function onMapChange(event : MapEvent) : Void
	{
		refresh();
	}

	private function onMapStartPan(event : MapEvent) : Void
	{
		panStart = new Point(polyCont.x, polyCont.y);
	}

	private function onMapStopPan(event : MapEvent) : Void
	{
		refresh();
	}

	private function onMapPanned(event : MapEvent) : Void
	{
		polyCont.x = panStart.x + event.panDelta.x;
		polyCont.y = panStart.y + event.panDelta.y;
	}
}
