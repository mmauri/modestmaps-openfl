
package com.modestmaps.mapproviders.microsoft;


import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.AbstractMapProvider;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.util.BinaryUtil;
import haxe.ds.StringMap;

/**
	 * @author tom
	 * @author darren
	 * @author migurski
 	 * $Id:$
	 */

class MicrosoftProvider extends AbstractMapProvider implements IMapProvider
{
    public static inline var AERIAL : String = "AERIAL";
    public static inline var ROAD : String = "ROAD";
    public static inline var HYBRID : String = "HYBRID";
    
    public static var serverSalt : Int = Std.int(Math.random() * 4);
    
	private static var urlStart:StringMap<String> = [
		AERIAL => "http://a",
		ROAD => "http://r",
		HYBRID => "http://h"
	];
		
	private static var urlMiddle:StringMap<String> = [
		AERIAL => ".ortho.tiles.virtualearth.net/tiles/a",
		ROAD => ".ortho.tiles.virtualearth.net/tiles/r",
		HYBRID => ".ortho.tiles.virtualearth.net/tiles/h"
	];
	
	private static var urlEnd:StringMap<String> = [
		AERIAL => ".jpeg?g=90",
		ROAD => ".png?g=90",
		HYBRID => ".jpeg?g=90"
	];
    
    private var type : String;
    private var hillShading : Bool;
    
    public function new(type : String = ROAD, hillShading : Bool = true, minZoom : Int = AbstractMapProvider.MIN_ZOOM, maxZoom : Int = AbstractMapProvider.MAX_ZOOM)
    {
        super(minZoom, maxZoom);
        
        this.type = type;
        this.hillShading = hillShading;
        
        if (hillShading) {
            urlEnd.set(ROAD, urlEnd.get(ROAD) + "&shading=hill");
        }  
		// Microsoft don't have a zoom level 0 right now:  
        
        
        
        __topLeftOutLimit.zoomTo(1);
    }
    
    private function getZoomString(coord : Coordinate) : String
    {
        var sourceCoord : Coordinate = sourceCoordinate(coord);
        
        // convert row + col to zoom string
        // padded with zeroes so we end up with zoom digits after slicing:
        var rowBinaryString : String = BinaryUtil.convertToBinary(Std.int(sourceCoord.row));
        rowBinaryString = rowBinaryString.substring(Std.int(-sourceCoord.zoom));
        
        var colBinaryString : String = BinaryUtil.convertToBinary(Std.int(sourceCoord.column));
        colBinaryString = colBinaryString.substring(Std.int(-sourceCoord.zoom));
        
        // generate zoom string by combining strings
        var zoomString : String = "";
        
        var i : Int = 0;
        while (i < sourceCoord.zoom){
            zoomString += BinaryUtil.convertToDecimal(rowBinaryString.charAt(i) + colBinaryString.charAt(i));
            i += 1;
        }
        
        return zoomString;
    }
    
    public function toString() : String
    {
        return "MICROSOFT_" + type;
    }
    
    public function getTileUrls(coord : Coordinate) : Array<String>
    {
        if (coord.row < 0 || coord.row >= Math.pow(2, coord.zoom)) {
            return null;
        }  // this is so that requests will be consistent in this session, rather than totally random  
        
        var server : Int = Std.int(Math.abs(serverSalt + coord.row + coord.column + coord.zoom) % 4);
        return [urlStart.get(type) + server + urlMiddle.get(type) + getZoomString(coord) + urlEnd.get(type)];
    }
}
