package com.modestmaps.extras;

import openfl.display.Graphics;

class LineStyle
{
	public var thickness : Float;
	public var color : Int;
	public var alpha : Float;
	public var pixelHinting : Bool;
	public var scaleMode : String;
	public var caps : String;
	public var joints : String;
	public var miterLimit : Float;

	public function new(thickness : Float = 0, color : Int = 0, alpha : Float = 1, pixelHinting : Bool = false, scaleMode : String = "normal", caps : String = null, joints : String = null, miterLimit : Float = 3.0)
	{
		this.thickness = thickness;
		this.color = color;
		this.alpha = alpha;
		this.pixelHinting = pixelHinting;
		this.scaleMode = scaleMode;
		this.caps = caps;
		this.joints = joints;
		this.miterLimit = miterLimit;
	}

	public function apply(graphics : Graphics, thicknessMod : Float = 1, alphaMod : Float = 1) : Void
	{
		graphics.lineStyle(thickness * thicknessMod, color, alpha * alphaMod, pixelHinting, scaleMode, caps, joints, miterLimit);
	}
}
