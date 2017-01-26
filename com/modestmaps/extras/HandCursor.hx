package com.modestmaps.extras;

import com.modestmaps.Map;
import com.modestmaps.extras.HandDown;
import com.modestmaps.extras.HandUp;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.filters.DropShadowFilter;
import openfl.ui.Mouse;



class HandCursor extends Sprite
{
	@:meta(Embed(source="hand.png"))

	private var HandUp : Class<Dynamic>;

	@:meta(Embed(source="hand_down.png"))

	private var HandDown : Class<Dynamic>;

	private var map : Map;
	private var enabled : Bool = false;
	private var hand : Sprite;
	private var handup : Bitmap;
	private var handdown : Bitmap;

	private var callbacks : Array<Dynamic> = [];

	public function new(map : Map)
	{
		super();
		this.map = map;

		mouseEnabled = false;
		cacheAsBitmap = true;
		mouseChildren = false;

		hand = new Sprite();

		handup = cast(Type.createInstance(HandUp, []), Bitmap);
		hand.addChild(handup);
		handdown = cast(Type.createInstance(HandDown, []), Bitmap);

		hand.x -= hand.width / 2;
		hand.y -= hand.height / 2;
		hand.visible = false;
		addChild(hand);

		filters = [new DropShadowFilter(1, 45, 0, 1, 3, 3, .7, 2)];

		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	public function onAddedToStage(event : Event) : Void
	{
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.CLICK, onMouseClick);
		stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);

		map.grid.addEventListener(MouseEvent.ROLL_OVER, enable);
		map.grid.addEventListener(MouseEvent.ROLL_OUT, disable);
	}
	public function onRemovedFromStage(event : Event) : Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.removeEventListener(MouseEvent.CLICK, onMouseClick);
		stage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeave);

		map.grid.removeEventListener(MouseEvent.ROLL_OVER, enable);
		map.grid.removeEventListener(MouseEvent.ROLL_OUT, disable);
	}

	public function onMouseLeave(event : Event) : Void
	{
		if (enabled)
		{
			hand.visible = false;
		}
	}

	public function onMouseMove(event : MouseEvent) : Void
	{
		if (enabled && !hand.visible)
		{
			hand.visible = true;
		}
		x = event.localX;
		y = event.localY;
	}

	public function onMouseUp(event : MouseEvent) : Void
	{
		if (enabled)
		{
			Mouse.hide();
			callNextFrame(Mouse.hide);
		}
		hand.removeChild(handdown);
		hand.addChild(handup);
	}
	public function onMouseClick(event : MouseEvent) : Void
	{
		if (enabled)
		{
			Mouse.hide();
			callNextFrame(Mouse.hide);
		}
	}
	public function onMouseDown(event : MouseEvent) : Void
	{
		if (enabled)
		{
			Mouse.hide();
			callNextFrame(Mouse.hide);
		}
		if (hand.contains(handup))
		{
			hand.removeChild(handup);
			hand.addChild(handdown);
		}
	}

	public function enable(event : Event = null) : Void
	{
		Mouse.hide();
		callNextFrame(Mouse.hide);
		hand.visible = true;
		enabled = true;
	}
	public function disable(event : Event = null) : Void
	{
		Mouse.show();
		callNextFrame(Mouse.show);
		hand.visible = false;
		enabled = false;
	}

	private function callNextFrame(callback : Function) : Void
	{
		if (!hasEventListener(Event.ENTER_FRAME))
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		callbacks.push(callback);
	}

	private function onEnterFrame(event : Event) : Void
	{
		while (callbacks.length > 0)
		{
			var callback : Function = cast(callbacks.shift(), Function);
			callback();
		}
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
}
