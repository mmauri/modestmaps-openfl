package com.modestmaps.core.painter;

import com.modestmaps.core.painter.ITilePainter;

import com.modestmaps.core.Coordinate;
import com.modestmaps.core.Tile;
import com.modestmaps.core.TweenTile;
import com.modestmaps.events.MapEvent;
import com.modestmaps.mapproviders.IMapProvider;

import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.TimerEvent;
import openfl.geom.Point;
import openfl.utils.Dictionary;
import openfl.utils.Timer;

class GoogleTilePainter extends EventDispatcher implements ITilePainter
{
    private var type : IMapType;
    private var googleMap : Map;
    private var tileClass : Type;
    private var timer : Timer;
    private var cache : Dictionary = new Dictionary();
    
    public function new(googleMap : Map, type : IMapType)
    {
        super(null);
        this.type = type;
        this.googleMap = googleMap;
        this.tileClass = TweenTile;
        this.timer = new Timer(250);
        timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
        timer.start();
    }
    
    public function setTileClass(tileClass : Type) : Void
    {
        this.tileClass = tileClass;
    }
    
    public function setMapProvider(provider : IMapProvider) : Void
    {
        // nothing
        
    }
    
	public function getTileFromCache(key:String):Tile
	{
		if (key in cache) {
			var t:Tile = cast (cache[key], Tile);
			if (isPainted(t)) { 
				return t;
			}
		}
		return null;
	}
    
    public function retainKeysInCache(recentlySeen : Array<Dynamic>) : Void
    {
        /*  			var tempCache:Dictionary = new Dictionary();
			for each (var key:String in recentlySeen) {
				if (key in cache) tempCache[key] = cache[key];
			}
			this.cache = tempCache; */
        
    }
    
    public function createAndPopulateTile(coord : Coordinate, key : String) : Tile
    {
		if (key in cache) {
			return cast (cache[key], Tile); 
		}
        
        if (googleMap.getCurrentMapType().getName() != type.getName()) {
            googleMap.setMapType(type);
        }
        
        var tile : Tile = Type.createInstance(tileClass, [coord.column, coord.row, coord.zoom]);
        tile.name = key;
        
        if (coord.zoom > 1 && coord.zoom <= 19 && coord.row >= 0 && coord.row < Math.pow(2, coord.zoom)) {
            coord = coord.copy();
            while (coord.column < 0){
                coord.column += Math.pow(2, coord.zoom);
            }
            coord.column %= Math.pow(2, coord.zoom);
            var layers : Array<Dynamic> = googleMap.getCurrentMapType().getTileLayers();
            for (tileLayer in layers){
                var tileImage : DisplayObject = tileLayer.loadTile(new Point(coord.column, coord.row), coord.zoom);
                tile.addChild(tileImage);
            }
            tile.hide();
        }
        
        cache[key]= tile;
        
        return tile;
    }
    
    private function onTimer(event : Event) : Void
    {
        var unPaintedGridTile : Bool = false;
        for (tile/* AS3HX WARNING could not determine type for var: tile exp: EIdent(cache) type: Dictionary */ in cache){
            if (tile.parent) {
                if (isPainted(tile)) {
                    tile.show();
                }
                else {
                    unPaintedGridTile = true;
                }
            }
            else {
                tile.hide();
            }
        }
        if (!unPaintedGridTile) {
            dispatchEvent(new MapEvent(MapEvent.ALL_TILES_LOADED));
        }
    }
    
    public function isPainted(tile : Tile) : Bool
    {
        
		return tile.numChildren > 0 ? tile.getChildAt(0)['loadComplete'] : false;
    }
    
    public function cancelPainting(tile : Tile) : Void
    {
        while (tile.numChildren){
            tile.removeChildAt(0);
        }
        cache.remove(tile.name);
    }
    
    public function isPainting(tile : Tile) : Bool
    {
        var img : Dynamic = tile.numChildren > (0) ? (cast(tile.getChildAt(0), Dynamic)) : null;
        return img && img.exists("loadComplete") && ! img.loadComplete;
    }
    
    public function reset() : Void
    {
        this.cache = new Dictionary();
        dispatchEvent(new MapEvent(MapEvent.BEGIN_TILE_LOADING));
    }
    
    public function getLoaderCacheCount() : Int
    {
        return 0;
    }
    
    public function getQueueCount() : Int
    {
        return 0;
    }
    
    public function getRequestCount() : Int
    {
        return 0;
    }
    
    public function getCacheSize() : Int
    {
        return 0;
    }
}
