package com.modestmaps.overlays;


/**
	 * Polyline class that takes polyline data and draws it in the given style.
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
	 * @see PolylineClip
	 * 
	 * Originally contributed by simonoliver.
	 * 
	 */
class Polyline
{
    public var id : String;
    public var locationsArray : Array<Dynamic>;
    public var lineThickness : Float;
    public var lineColor : Float;
    public var lineAlpha : Float;
    public var pixelHinting : Bool;
    public var scaleMode : String;
    public var caps : String;
    public var joints : String;
    public var miterLimit : Float;
    
    public function new(id : String,
            locationsArray : Array<Dynamic>,
            lineThickness : Float = 3,
            lineColor : Float = 0xFF0000,
            lineAlpha : Float = 1,
            pixelHinting : Bool = false,
            scaleMode : String = "normal",
            caps : String = null,
            joints : String = null,
            miterLimit : Float = 3)
    {
        this.id = id;
        this.locationsArray = locationsArray;
        this.lineThickness = lineThickness;
        this.lineColor = lineColor;
        this.lineAlpha = lineAlpha;
        this.pixelHinting = pixelHinting;
        this.scaleMode = scaleMode;
        this.caps = caps;
        this.joints = joints;
        this.miterLimit = miterLimit;
    }
}
