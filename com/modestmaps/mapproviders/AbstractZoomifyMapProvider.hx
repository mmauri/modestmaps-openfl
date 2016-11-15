package com.modestmaps.mapproviders;

import com.modestmaps.mapproviders.IMapProvider;


import com.modestmaps.core.Coordinate;

/**
	 * @author migurski
	 * $Id$
	 */

class AbstractZoomifyMapProvider extends AbstractMapProvider implements IMapProvider
{
    private var __baseDirectory : String;
    private var __groups : Array<Coordinate>;
	public static inline var LN2 = 0.6931471805599453;
    
    public function new()
    {
        super();
    }
    
    public function toString() : String
    {
        return "ABSTRACT_ZOOMIFY";
    }
    
    /**
	    * Zoomifyer EZ (download: http://www.zoomify.com/express.htm) cuts a base
	    * image into tiles, and creates a metadata file named ImageProperties.xml
	    * in the same directory. Instead of parsing that file, pass the relevant
	    * bits to this method. Base directory *must* have a trailing slash.
	    *
	    * Example:
	    *
	    *   ImageProperties.xml content:
	    *       <IMAGE_PROPERTIES WIDTH="11258" HEIGHT="7085" NUMTILES="1650" NUMIMAGES="1" VERSION="1.8" TILESIZE="256" />
	    *
	    *   URL of ImageProperties.xml:
	    *       http://example.com/ImageProperties.xml
	    *
	    *   Corresponding call to defineImageProperties():
	    *       defineImageProperties('http://example.com/', 11258, 7085);
	    *
	    * Tiles created by Zoomifyer EZ are placed in folders named "TileGroup{0..n}",
	    * in groups of 256, so we need to quickly iterate through the entire set of
	    * tile coordinates to determine where the group boundaries are. These are
	    * stored in the __groups array.
	    */
    private function defineImageProperties(baseDirectory : String, width : Float, height : Float) : Void
    {
        __baseDirectory = baseDirectory;
        
        var zoom : Float = Math.ceil(Math.log(Math.max(width, height)) / LN2);
        
        __topLeftOutLimit = new Coordinate(0, 0, 0);
        __bottomRightInLimit = (new Coordinate(height, width, zoom)).zoomTo(zoom - 8);
        
        __groups = [];
        var i : Float = 0;
        
        /*
	        * Iterate over all possible tiles in order: left to right, top to
	        * bottom, zoomed-out to zoomed-in. Note the first tile coordinate
	        * in each group of 256.
	        */
        var c : Coordinate = __topLeftOutLimit.copy();
        while (c.zoom <= __bottomRightInLimit.zoom){
            
            // edges of the image at current zoom level
            var tlo : Coordinate = __topLeftOutLimit.zoomTo(c.zoom);
            var bri : Coordinate = __bottomRightInLimit.zoomTo(c.zoom);
            
            // left-to-right, top-to-bottom, like reading a book
            c.row = tlo.row;
            while (c.row <= bri.row){
                c.column = tlo.column;
                while (c.column <= bri.column){
                    
                    // zoomify groups tiles into folders of 256 each
                    if (i % 256 == 0) 
                        __groups.push(c.copy());
                    
                    i += 1;
                    c.column += 1;
                }
                c.row += 1;
            }
            c.zoom += 1;
        }
    }
    
    private function coordinateGroup(c : Coordinate) : Float
    {
        var i : Int = 0;
        while (i < __groups.length){
            if (i + 1 == __groups.length) 
                return i;
            
            var g : Coordinate = __groups[i + 1].copy();
            
            if (c.zoom < g.zoom || (c.zoom == g.zoom && (c.row < g.row || (c.row == g.row && c.column < g.column)))) 
                return i;
            i += 1;
        }
        return -1;
    }
    
    public function getTileUrls(coord : Coordinate) : Array<String>
    {
        return [__baseDirectory + "TileGroup" + coordinateGroup(coord) + "/" + (coord.zoom) + "-" + (coord.column) + "-" + (coord.row) + ".jpg"];
    }
}

