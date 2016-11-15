package com.pixelbreaker.ui.osx;


import flash.system.Capabilities;
import flash.display.InteractiveObject;
import flash.display.Stage;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
/**
	 * @author Gabriel Bucknall
	 * 
	 * Class that supports using the mouseWheel on Mac OS, requires javascript class
	 * swfmacmousewheel.js
	 */
class MacMouseWheel
{
    private static var instance : MacMouseWheel;
    
    private var _stage : Stage;
    private var _currItem : InteractiveObject;
    private var _clonedEvent : MouseEvent;
    
    public static function getInstance() : MacMouseWheel
    {
        if (instance == null)             instance = new MacMouseWheel(new SingletonEnforcer());
        return instance;
    }
    
    public function new(enforcer : SingletonEnforcer)
    {
        
    }
    
    /*
		 * Initialize the MacMouseWheel class
		 * 
		 * @param stage Stage instance e.g DocumentClass.stage
		 * 
		 */
    public static function setup(stage : Stage) : Void
    {
        var isMac : Bool = Capabilities.os.toLowerCase().indexOf("mac") != -1;
        if (isMac)             getInstance()._setup(stage);
    }
    
    private function _setup(stage : Stage) : Void
    {
        _stage = stage;
        _stage.addEventListener(MouseEvent.MOUSE_MOVE, _getItemUnderCursor);
        
        if (ExternalInterface.available) 
        {
            ExternalInterface.addCallback("externalMouseEvent", _externalMouseEvent);
        }
    }
    
    private function _getItemUnderCursor(e : MouseEvent) : Void
    {
        _currItem = cast((e.target), InteractiveObject);
        _clonedEvent = cast((e), MouseEvent);
    }
    
    private function _externalMouseEvent(delta : Float) : Void
    {
        var wheelEvent : MouseEvent = new MouseEvent(
        MouseEvent.MOUSE_WHEEL, 
        true, 
        false, 
        _clonedEvent.localX, 
        _clonedEvent.localY, 
        _clonedEvent.relatedObject, 
        _clonedEvent.ctrlKey, 
        _clonedEvent.altKey, 
        _clonedEvent.shiftKey, 
        _clonedEvent.buttonDown, 
        as3hx.Compat.parseInt(delta), 
        );
        _currItem.dispatchEvent(wheelEvent);
    }
}


class SingletonEnforcer
{

    @:allow(com.pixelbreaker.ui.osx)
    private function new()
    {
    }
}
