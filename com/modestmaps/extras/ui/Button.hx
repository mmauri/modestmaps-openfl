package com.modestmaps.extras.ui;

import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.ColorTransform;

class Button extends Sprite
{
	public static inline var LEFT : String = "left";
	public static inline var RIGHT : String = "right";
	public static inline var UP : String = "up";
	public static inline var DOWN : String = "down";
	public static inline var IN : String = "in";
	public static inline var OUT : String = "out";

	public var overTransform : ColorTransform;
	public var outTransform : ColorTransform;

	public function new(type : String = null, radius : Float = 9, bgColor : Int = 0xFFFFFF, fgColor : Int = 0x000000, beveled : Bool = true)
	{
		super();
		if (overTransform == null)             overTransform = new ColorTransform(1, 1, 1);
		if (outTransform == null)             outTransform = new ColorTransform(1, .9, .6);

		useHandCursor = true;
		buttonMode = true;
		cacheAsBitmap = true;

		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

		graphics.clear();
		if (beveled)
		{
			graphics.beginFill(0xdddddd);
			graphics.drawRoundRect(0, 0, 20, 20, radius, radius);
			graphics.beginFill(bgColor);
			graphics.drawRoundRect(0, 0, 18, 18, radius, radius);
			graphics.beginFill(0xbbbbbb);
			graphics.drawRoundRect(2, 2, 18, 18, radius, radius);
			graphics.beginFill(0xdddddd);
			graphics.drawRoundRect(1, 1, 18, 18, radius, radius);
		}
		else
		{
			graphics.beginFill(bgColor);
			graphics.drawRoundRect(0, 0, 20, 20, radius, radius);
		}

		switch (type)
		{

			// draw arrows...
			case LEFT:
				graphics.beginFill(fgColor);
				graphics.moveTo(14, 6);
				graphics.lineTo(6, 10);
				graphics.lineTo(14, 14);
				graphics.lineTo(14, 6);

			case RIGHT:
				graphics.beginFill(fgColor);
				graphics.moveTo(6, 6);
				graphics.lineTo(14, 10);
				graphics.lineTo(6, 14);
				graphics.lineTo(6, 6);

			case UP:
				graphics.beginFill(fgColor);
				graphics.moveTo(6, 14);
				graphics.lineTo(10, 6);
				graphics.lineTo(14, 14);
				graphics.lineTo(6, 14);

			case DOWN:
				graphics.beginFill(fgColor);
				graphics.moveTo(6, 6);
				graphics.lineTo(10, 14);
				graphics.lineTo(14, 6);
				graphics.lineTo(6, 6);

			case IN:
				// draw plus...
				graphics.lineStyle(2, fgColor, 1.0, true);
				graphics.moveTo(7, 10);
				graphics.lineTo(13, 10);
				graphics.lineTo(7, 10);
				graphics.moveTo(10, 7);
				graphics.lineTo(10, 13);
				graphics.lineTo(10, 7);

			case OUT:
				// draw minus...
				graphics.lineStyle(2, fgColor, 1.0, true);
				graphics.moveTo(7, 10);
				graphics.lineTo(13, 10);
				graphics.lineTo(7, 10);
		}

		transform.colorTransform = outTransform;
	}

	public function onMouseOver(event : MouseEvent = null) : Void
	{
		transform.colorTransform = overTransform;
	}

	public function onMouseOut(event : MouseEvent = null) : Void
	{
		transform.colorTransform = outTransform;
	}
}

