/**
 * vim:et sts=4 sw=4 cindent:
 * @ignore
 *
 * @author tom
 *
 * com.modestmaps.TweenMap adds smooth animated panning and zooming to the basic Map class
 *
 */
package com.modestmaps;


import com.modestmaps.core.Coordinate;
import com.modestmaps.core.MapExtent;
import com.modestmaps.core.TweenTile;
import com.modestmaps.geo.Location;
import com.modestmaps.mapproviders.IMapProvider;

import openfl.events.MouseEvent;
import openfl.geom.Matrix;
import openfl.geom.Point;

import motion.Actuate;
import motion.easing.Linear;
import motion.easing.Quad;

class TweenMap extends Map
{
    private static inline var LN2 = 0.6931471805599453;
	//public var zoomEase:IEasing = Quad.easeOut;
    /** easing function used for panLeft, panRight, panUp, panDown */
    //public var panEase : Dynamic = quadraticEaseOut;
    /** time to pan using panLeft, panRight, panUp, panDown */
    public var panDuration : Float = 0.5;
    
    /** easing function used for zoomIn, zoomOut */
    //public var zoomEase : Dynamic = quadraticEaseOut;
    /** time to zoom using zoomIn, zoomOut */
    public var zoomDuration : Float = 0.2;
    
    /** time to pan and zoom using, uh, panAndZoom */
    public var panAndZoomDuration : Float = 0.3;
    
    private var mouseWheelingIn : Bool = false;
    private var mouseWheelingOut : Bool = false;
	
	private var enableOnCompleteMouseWheeling : Bool = false;
	
    
    /*
	    * Initialize the map: set properties, add a tile grid, draw it.
	    * Default extent covers the entire globe, (+/-85, +/-180).
	    *
	    * @param    Width of map, in pixels.
	    * @param    Height of map, in pixels.
	    * @param    Whether the map can be dragged or not.
	    * @param    Desired map provider, e.g. Blue Marble.
	    *
	    * @see com.modestmaps.core.TileGrid
	    */
    public function new(width : Float = 320, height : Float = 240, draggable : Bool = true, provider : IMapProvider = null, rest : Array<Dynamic> = null)
    {
        super(width, height, draggable, provider, rest);
        grid.setTileClass(true);
		//addChild(grid.debugField);
    }
    
    /** Pan by px and py, in panDuration (used by panLeft, panRight, panUp and panDown) */
    override public function panBy(px : Float, py : Float) : Void
    {
        if (!grid.panning && !grid.zooming) {
            grid.prepareForPanning();
            Actuate.tween(grid, panDuration, {
                        tx : grid.tx + px,
                        ty : grid.ty + py
                    }).ease(Quad.easeOut)
					.onComplete(grid.donePanning);
        }
    }
    
    
    private var enforceToRestore : Bool = false;
    
    public function tweenToMatrix(m : Matrix, duration : Float) : Void
    {
        grid.prepareForZooming();
        grid.prepareForPanning();
        enforceToRestore = grid.enforceBoundsEnabled;
        grid.enforceBoundsEnabled = false;
        
        grid.enforceBoundsOnMatrix(m);
		
		//TweenLite.to(grid, duration, { a: m.a, b: m.b, c: m.c, d: m.d, tx: m.tx, ty: m.ty, onComplete: panAndZoomComplete });
		
		//grid.setMatrix(m);
       Actuate.tween(grid, duration, {
                    a: m.a,
					b: m.b,
					c: m.c,
                    d: m.d,
					tx: m.tx,
					ty: m.ty
                    }).ease(Linear.easeNone)
					.onComplete(panAndZoomComplete);
					
		//panAndZoomComplete();	
	}
    
    /** call grid.donePanning() and grid.doneZooming(), used by tweenExtent, 
		 *  panAndZoomBy and zoomByAbout as a TweenLite onComplete function */
    private function panAndZoomComplete() : Void
    {
        grid.enforceBoundsEnabled = enforceToRestore;
        
        grid.donePanning();
        grid.doneZooming();
    }
    
    /** zoom in or out by sc, moving the given location to the requested target (or map center, if omitted) */
    override public function panAndZoomBy(sc : Float, location : Location, targetPoint : Point = null, duration : Float = -1) : Void
    {
        if (duration < 0)             duration = panAndZoomDuration;
        if (targetPoint == null)             targetPoint = new Point(mapWidth / 2, mapHeight / 2);
        
        var p : Point = locationPoint(location);
        
        var constrainedDelta : Float = Math.log(sc) / LN2;
        
        if (grid.zoomLevel + constrainedDelta < grid.minZoom) {
            constrainedDelta = grid.minZoom - grid.zoomLevel;
        }
        // round the zoom delta up or down so that we end up at a power of 2
        else if (grid.zoomLevel + constrainedDelta > grid.maxZoom) {
            constrainedDelta = grid.maxZoom - grid.zoomLevel;
        }
        
        
        
        var preciseZoomDelta : Float = constrainedDelta + (Math.round(grid.zoomLevel + constrainedDelta) - (grid.zoomLevel + constrainedDelta));
        
        sc = Math.pow(2, preciseZoomDelta);
        
        var m : Matrix = grid.getMatrix();
        
        m.translate(-p.x, -p.y);
        m.scale(sc, sc);
        m.translate(targetPoint.x, targetPoint.y);
        
        tweenToMatrix(m, duration);
    }
    
    /** zoom in or out by zoomDelta, keeping the requested point in the same place */
    override public function zoomByAbout(zoomDelta : Float, targetPoint : Point = null, duration : Float = -1) : Void
    {
        if (duration < 0) {
			duration = panAndZoomDuration;
		}
			
        if (targetPoint == null) {
			targetPoint = new Point(mapWidth / 2, mapHeight / 2);
		}
        
        var constrainedDelta : Float = zoomDelta;
        
        if (grid.zoomLevel + constrainedDelta < grid.minZoom) {
            constrainedDelta = grid.minZoom - grid.zoomLevel;
        }
        // round the zoom delta up or down so that we end up at a power of 2
        else if (grid.zoomLevel + constrainedDelta > grid.maxZoom) {
            constrainedDelta = grid.maxZoom - grid.zoomLevel;
        }
        
        var preciseZoomDelta : Float = constrainedDelta + (Math.round(grid.zoomLevel + constrainedDelta) - (grid.zoomLevel + constrainedDelta));
        
        var sc : Float = Math.pow(2, preciseZoomDelta);
        
        var m : Matrix = grid.getMatrix();
        
        m.translate(-targetPoint.x, -targetPoint.y);
        m.scale(sc, sc);
        m.translate(targetPoint.x, targetPoint.y);
        
        tweenToMatrix(m, duration);
    }
    
    /** EXPERIMENTAL! */
    public function tweenExtent(extent : MapExtent, duration : Float = -1) : Void
    {
        if (duration < 0)             duration = panAndZoomDuration;
        
        var coord : Coordinate = locationsCoordinate([extent.northWest, extent.southEast]);
        
        var sc : Float = Math.pow(2, coord.zoom - grid.zoomLevel);
        
        var p : Point = grid.coordinatePoint(coord, grid);
        
        var m : Matrix = grid.getMatrix();
        
        m.translate(-p.x, -p.y);
        m.scale(sc, sc);
        m.translate(mapWidth / 2, mapHeight / 2);
        
        tweenToMatrix(m, duration);
    }
    
    /**
		 * Put the given location in the middle of the map, animated in panDuration using panEase.
		 * 
		 * Use setCenter or setCenterZoom for big jumps, set forceAnimate to true
		 * if you really want to animate to a location that's currently off screen.
		 * But no promises! 
		 * 
		 * @see com.modestmaps.TweenMap#panDuration
		 * @see com.modestmaps.TweenMap#panEase
  		 * @see com.modestmaps.TweenMap#tweenTo
  		 */
    public function panTo(location : Location, forceAnimate : Bool = false) : Void
    {
        var p : Point = locationPoint(location, grid);
        
        if (forceAnimate || (p.x >= 0 && p.x <= mapWidth && p.y >= 0 && p.y <= mapHeight)) 
        {
            var centerPoint : Point = new Point(mapWidth / 2, mapHeight / 2);
            var pan : Point = centerPoint.subtract(p);
            
            grid.prepareForPanning();
            Actuate.tween(grid, panDuration, {
                        ty : grid.ty + pan.y,
                        tx : grid.tx + pan.x
                    })
					.ease(Quad.easeOut)
					.onComplete(grid.donePanning);
        }
        else 
        {
            setCenter(location);
        }
    }
    
    /**
		 * Animate to put the given location in the middle of the map.
		 * Use setCenter or setCenterZoom for big jumps, or panTo for pre-defined animation.
		 * 
		 * @see com.modestmaps.Map#panTo
		 */
    public function tweenTo(location : Location, duration : Float, easing : Dynamic = null) : Void
    {
        var pan : Point = new Point(mapWidth / 2, mapHeight / 2).subtract(locationPoint(location, grid));
        grid.prepareForPanning();
        Actuate.tween(grid, duration, {
                    ty : grid.ty + pan.y,
                    tx : grid.tx + pan.x
                })
				.ease(easing)
				.onComplete(grid.donePanning);
    }
    
    // keeping it DRY, as they say
    // dir should be 1, for in, or -1, for out
    override private function zoomBy(dir : Int) : Void
    {
        if (!grid.panning) 
        {
            var target : Float = ((dir < 0)) ? Math.floor(grid.zoomLevel + dir) : Math.ceil(grid.zoomLevel + dir);
            target = Math.max(grid.minZoom, Math.min(grid.maxZoom, target));
            grid.prepareForZooming();
            Actuate.tween(grid, zoomDuration, {zoomLevel: target})
					.ease(Quad.easeOut)
					.onComplete(grid.doneZooming);
        }
    }
    
    /** 
     * Zooms in or out of mouse-wheeled location, rounded off to nearest whole zoom level when zooming ends.
     *
     * @see http://blog.pixelbreaker.com/flash/swfmacmousewheel/ for Mac mouse wheel support  
     */
    override public function onMouseWheel(event : MouseEvent) : Void
    {
        if (!__draggable || grid.panning)             return;
        
        //todo TweenLite.killTweensOf(grid);
        Actuate.stop(grid,null,false,false);
		//TweenLite.killDelayedCallsTo(doneMouseWheeling);
		enableOnCompleteMouseWheeling = false;

        var sc : Float = 0;
		var delta:Int = event.delta;
		//fix for openfl -> AS3 returns +3/-3 whereas openfl returns delta +100/-100
		if (delta >= 100 || delta <= -100) delta = Std.int(delta / 33);
		
        if (delta < 0) {  
            if (grid.zoomLevel > grid.minZoom) {
                mouseWheelingOut = true;
                mouseWheelingIn = false;
                sc = Math.max(0.5, 1.0 + delta / 20.0);
            }
        }
        else if (event.delta > 0) {
            if (grid.zoomLevel < grid.maxZoom) {
                mouseWheelingIn = true;
                mouseWheelingOut = false;
                sc = Math.min(2.0, 1.0 + delta / 20.0);
            }
        }
        
      
        if (sc != 0) {
            var p : Point = grid.globalToLocal(new Point(event.stageX, event.stageY));
            var m : Matrix = grid.getMatrix();
            m.translate(-p.x, -p.y);
            m.scale(sc, sc);
            m.translate(p.x, p.y);
            grid.setMatrix(m);
        }

        event.updateAfterEvent();
		enableOnCompleteMouseWheeling = true;
		Actuate.timer(0.1).onComplete(doneMouseWheeling);
    }
    
    private function doneMouseWheeling() : Void
    {
		
		
		if (enableOnCompleteMouseWheeling) {
			var p : Point = grid.globalToLocal(new Point(stage.mouseX, stage.mouseY));
			if (mouseWheelingIn) {
				zoomByAbout(Math.ceil(grid.zoomLevel) - grid.zoomLevel, p, panAndZoomDuration);

			}
			else if (mouseWheelingOut) {
				zoomByAbout(Math.floor(grid.zoomLevel) - grid.zoomLevel, p, panAndZoomDuration);
			}
			else {
				zoomByAbout(Math.round(grid.zoomLevel) - grid.zoomLevel, p, panAndZoomDuration);
			}
			mouseWheelingOut = false;
			mouseWheelingIn = false;
			enableOnCompleteMouseWheeling = false;
		}
    }
/*	override public function onGestureZoom(event : TransformGestureEvent) : Void {
		var a = 0;
		trace(event.toString);
	}*/
}


