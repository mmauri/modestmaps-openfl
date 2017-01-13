package com.modestmaps.extras;

import com.modestmaps.Map;
import com.modestmaps.events.MapEvent;
import motion.Actuate;
import openfl.errors.Error;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
//todo import openfl.filters.BevelFilter;
import openfl.filters.BitmapFilterType;
import openfl.filters.DropShadowFilter;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/** This is an example of a slider that modifies the zoom level of the given map.
	 * 
	 *  It is provided mainly for ModestMapsSample.as and to test the arbitrary 
	 *  zoom level functionality, but feel free to use it if you like yellow bevels. */
class ZoomSlider extends Sprite
{
    public var proportion(get, set) : Float;

    private var map : Map;
    
    private var track : Sprite;
    private var thumb : Sprite;
    
    private var dragging : Bool = false;
    private var trackHeight : Float;
    
    private static inline var DEFAULT_HEIGHT : Float = 100;
    
    public function new(map : Map, trackHeight : Float = DEFAULT_HEIGHT)
    {
        super();
        this.map = map;
        this.trackHeight = trackHeight;
        
        map.addEventListener(MapEvent.EXTENT_CHANGED, update);
        map.addEventListener(MapEvent.ZOOMED_BY, update);
        map.addEventListener(MapEvent.STOP_ZOOMING, update);
        map.addEventListener(MapEvent.START_ZOOMING, update);
        
        this.x = 15;
        this.y = 15;
        
        track = new Sprite();
        //todo track.filters = [new BevelFilter(4, 45, 0xffffff, 0.2, 0x000000, 0.2, 4, 4, 1, 1, BitmapFilterType.INNER, false)];
        track.addEventListener(MouseEvent.CLICK, onTrackClick);
        track.buttonMode = track.useHandCursor = true;
        track.graphics.lineStyle(5, 0xd9c588);
        track.graphics.moveTo(0, 0);
        track.graphics.lineTo(0, trackHeight);
        track.graphics.lineStyle(0, 0x000000, 0.2);
        /* 			for (var i:int = map.grid.minZoom; i <= map.grid.maxZoom; i++) {
				var tick:Number = trackHeight * (i - map.grid.minZoom) / (map.grid.maxZoom - map.grid.minZoom);
				track.graphics.moveTo(-2, tick);
				track.graphics.lineTo(2, tick);
			} */
        track.x = 5;
        addChild(track);
        
        thumb = new Sprite();
        //todo thumb.filters = [new BevelFilter(4, 45, 0xffffff, 0.2, 0x000000, 0.2, 0, 0, 1, 1, BitmapFilterType.INNER, false)];
        thumb.addEventListener(MouseEvent.MOUSE_DOWN, onThumbMouse);
        thumb.buttonMode = thumb.useHandCursor = true;
        thumb.graphics.beginFill(0xff8080);
        thumb.graphics.drawCircle(0, 0, 5);
        thumb.x = 5;
        addChild(thumb);
        
        filters = [new DropShadowFilter(1, 45, 0, 1, 3, 3, .7, 2)];
        
        update();
    }
    
    private function onTrackClick(event : MouseEvent) : Void
    {
        var p : Point = globalToLocal(new Point(event.stageX, event.stageY));
        thumb.y = p.y;
        
		//todo tweenlite marc
		/*TweenLite.to(map.grid, 0.25, {
                    zoomLevel : Math.round(map.grid.minZoom + (map.grid.maxZoom - map.grid.minZoom) * (1 - proportion))

                });*/
		Actuate.tween(map.grid,0.25,{
                    zoomLevel : Math.round(map.grid.minZoom + (map.grid.maxZoom - map.grid.minZoom) * (1 - proportion))
                });
    }
    
    private function onThumbMouse(event : Event) : Void
    {
        if (event.type == MouseEvent.MOUSE_MOVE) {
            proportion = thumb.y / trackHeight;
        }
        else if (event.type == MouseEvent.MOUSE_DOWN) {
            thumb.startDrag(false, new Rectangle(thumb.x, 0, 0, trackHeight));
            dragging = true;
            stage.addEventListener(MouseEvent.MOUSE_UP, onThumbMouse);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onThumbMouse);
            stage.addEventListener(Event.MOUSE_LEAVE, onThumbMouse);
        }
        else if (event.type == MouseEvent.MOUSE_UP || event.type == Event.MOUSE_LEAVE) {
            thumb.stopDrag();
            dragging = false;
            //todo TweenLite.to(map.grid, 0.1, {
            //            zoomLevel : Math.round(map.grid.zoomLevel)

            //        });
			Actuate.tween(map.grid, 0.1, {
					 zoomLevel : Math.round(map.grid.zoomLevel)
			});
            stage.removeEventListener(MouseEvent.MOUSE_UP, onThumbMouse);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onThumbMouse);
            stage.removeEventListener(Event.MOUSE_LEAVE, onThumbMouse);
        }
        if (Std.is(event, MouseEvent)) {
            cast((event), MouseEvent).updateAfterEvent();
        }
    }
    
    public function update(event : MapEvent = null) : Void
    {
        //if (event) trace(event.type, "in ZoomSlider.update");
        if (!dragging) {
            proportion = 1.0 - (map.grid.zoomLevel - map.grid.minZoom) / (map.grid.maxZoom - map.grid.minZoom);
        }
    }
    
    private function get_proportion() : Float
    {
        return thumb.y / trackHeight;
    }
    
    private function set_proportion(prop : Float) : Float
    {
        if (!dragging) {
            thumb.y = prop * trackHeight;
        }
        else {
            map.grid.zoomLevel = Std.int(map.grid.minZoom + (map.grid.maxZoom - map.grid.minZoom) * (1.0 - prop));
        }
        return prop;
    }
}

