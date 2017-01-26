package com.modestmaps.extras.ui;

import openfl.display.CapsStyle;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.Shape;
import openfl.display.StageDisplayState;
import openfl.errors.Error;
import openfl.events.ContextMenuEvent;
import openfl.events.Event;
#if flash
	import flash.events.FullScreenEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
#end

class FullScreenButton extends Button
{
	private var outIcon:Shape = new Shape();
	private var inIcon:Shape = new Shape();

	public function new()
	{
		// draw out arrows
		super();
		outIcon.graphics.lineStyle(1, 0x000000, 1.0, true, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.BEVEL);
		outIcon.graphics.moveTo(8,5);
		outIcon.graphics.lineTo(4,4);
		outIcon.graphics.lineTo(5,8);

		outIcon.graphics.moveTo(11,5);
		outIcon.graphics.lineTo(15,4);
		outIcon.graphics.lineTo(14,8);

		outIcon.graphics.moveTo(8,14);
		outIcon.graphics.lineTo(4,15);
		outIcon.graphics.lineTo(5,11);

		outIcon.graphics.moveTo(11,14);
		outIcon.graphics.lineTo(15,15);
		outIcon.graphics.lineTo(14,11);
		addChild(outIcon);

		// draw out arrows
		inIcon.graphics.lineStyle(1, 0x000000, 1.0, true, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.BEVEL);
		inIcon.graphics.lineStyle(1, 0x000000);
		inIcon.graphics.moveTo(7,4);
		inIcon.graphics.lineTo(8,8);
		inIcon.graphics.lineTo(4,7);

		inIcon.graphics.moveTo(12,4);
		inIcon.graphics.lineTo(11,8);
		inIcon.graphics.lineTo(15,7);

		inIcon.graphics.moveTo(7,15);
		inIcon.graphics.lineTo(8,11);
		inIcon.graphics.lineTo(4,12);

		inIcon.graphics.moveTo(12,15);
		inIcon.graphics.lineTo(11,11);
		inIcon.graphics.lineTo(15,12);
		addChild(inIcon);

		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	/**
	 *
	 * @param	event
	 */
	private function onAddedToStage(event:Event):Void
	{
		stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenEvent);

		// create the context menu, remove the built-in items,
		// and add our custom items
		var fullScreenCM:ContextMenu = new ContextMenu();
		fullScreenCM.hideBuiltInItems();

		var fs:ContextMenuItem = new ContextMenuItem("Go Full Screen");
		fs.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, goFullScreen);
		fullScreenCM.customItems.push(fs);

		var xfs:ContextMenuItem = new ContextMenuItem("Exit Full Screen");
		xfs.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, exitFullScreen);
		fullScreenCM.customItems.push(xfs);

		// finally, attach the context menu to the parent
		this.parent.contextMenu = fullScreenCM;
	}

	/**
	 *
	 * @param	event
	 */
	public function toggleFullScreen(event:Event=null):Void
	{
		if (stage.displayState == StageDisplayState.FULL_SCREEN)
		{
			exitFullScreen();
		}
		else {
			goFullScreen();
		}
	}

	/**
	* Function to enter and leave full screen mode
	*
	* @param event
	*/
	public function goFullScreen(event:Event=null):Void
	{
		try {
			stage.displayState = StageDisplayState.FULL_SCREEN;
		}
		catch (err:Error)
		{
			trace("Dang fullScreen is not allowed here");
		}
	}
	/**
	*
	* @param event
	*/
	public function exitFullScreen(event:Event=null):Void
	{
		try {
			stage.displayState = StageDisplayState.NORMAL;
		}
		catch (err:Error)
		{
			trace("Problem setting displayState to normal, sorry");
		}
	}

	/**
	* Function to enable and disable the context menu items,
	* based on what mode we are in.
	*
	* @param event
	*/
	public function onFullScreenEvent(event:Event):Void
	{
		if (stage.displayState == StageDisplayState.FULL_SCREEN)
		{
			if (contains(outIcon))
			{
				removeChild(outIcon);
			}
			if (!contains(inIcon))
			{
				addChild(inIcon);
			}
			this.parent.contextMenu.customItems[0].enabled = false;
			this.parent.contextMenu.customItems[1].enabled = true;
		}
		else
		{
			if (!contains(outIcon))
			{
				addChild(outIcon);
			}
			if (contains(inIcon))
			{
				removeChild(inIcon);
			}
			this.parent.contextMenu.customItems[0].enabled = true;
			this.parent.contextMenu.customItems[1].enabled = false;
		}
	}
}