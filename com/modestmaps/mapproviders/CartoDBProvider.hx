/**
 * MapProvider for Open Street Map data.
 * 
 * @author migurski
 * $Id$
 */
package com.modestmaps.mapproviders;

import com.modestmaps.core.Coordinate;
enum CARTODB_MAPTYPE {
	POSITRON;
	DARK_MATTER;
}

class CartoDBProvider extends AbstractMapProvider implements IMapProvider
{
	private var baseURL:String;
	private var retinaDisplay:Bool;
		
	public function new(MapType:CARTODB_MAPTYPE, useSSL:Bool = false, retinaDisplay:Bool = false,
		minZoom : Int = AbstractMapProvider.MIN_ZOOM, maxZoom : Int = AbstractMapProvider.MAX_ZOOM)
    {
        super(minZoom, maxZoom);
		if (useSSL) {
			baseURL = 'https://cartodb-basemaps-@S.global.ssl.fastly.net/';
		} else {
			baseURL = 'http://@S.basemaps.cartocdn.com/';
		}
		
		switch (MapType) 
		{
			case POSITRON : baseURL += "light_all" + "/";
			case DARK_MATTER: baseURL += "dark_all" +"/";
		}
		this.retinaDisplay = retinaDisplay;
		//todo _attribution =  "<font face='Verdana' size='10'>&#169;<a href='http://www.openstreetmap.org/copyright' target='_blank'>OpenStreetMap</a> contributors, &#169;<a href='https://cartodb.com/attributions' target='_blank'>CartoDB</a></font>";
		//todo crossdomain
    }
    
    public function toString() : String
    {
        return "CARTODB";
    }
    
    public function getTileUrls(coord : Coordinate) : Array<String>
    {
        var sourceCoord : Coordinate = sourceCoordinate(coord);
        if (sourceCoord.row < 0 || sourceCoord.row >= Math.pow(2, coord.zoom)) {
            return [];
        }
		
		var server : String = ["a", "b", "c", "d"][Math.floor(sourceCoord.row + sourceCoord.column + sourceCoord.zoom) % 4];
		var finalurl:String;
		if (retinaDisplay) {
			finalurl  = StringTools.replace(baseURL, "@S", server) + [sourceCoord.zoom, sourceCoord.column, sourceCoord.row ].join('/') + '@2x.png';
		} else {
			finalurl  = StringTools.replace(baseURL, "@S", server) + [sourceCoord.zoom, sourceCoord.column, sourceCoord.row ].join('/') + '.png';
		}
        return [finalurl];
    }
}
