import ImageClass;
import MarkerImage;

import com.adobe.viewsource.ViewSource;
import com.modestmaps.TweenMap;
import com.modestmaps.extras.MapCopyright;
import com.modestmaps.geo.Location;
import com.modestmaps.mapproviders.BlueMarbleMapProvider;
import com.pixelbreaker.ui.osx.MacMouseWheel;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
@:meta(SWF(backgroundColor="#ffffff"))



import com.modestmaps.Map;


import com.modestmaps.core.MapExtent;
import flash.geom.Rectangle;
import mx.controls.Image;
import com.modestmaps.events.MapEvent;


class HelloIcons extends Sprite
{
    public var map : TweenMap;
    
    @:meta(Embed(source="images/001_09.png"))

    private var MarkerImage : Class<Dynamic>;
    
    public function new()
    {
        super();
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        
        MacMouseWheel.setup(stage);
        
        ViewSource.addMenuItem(this, "srcview/index.html", true);
        
        map = new TweenMap(stage.stageWidth, stage.stageHeight, true, new BlueMarbleMapProvider());
        map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
        map.addEventListener(MouseEvent.MOUSE_WHEEL, map.onMouseWheel);
        addChild(map);
        
        map.addChild(new IconControls(map));
        map.addChild(new MapCopyright(map))  // my cities, from http://www.getlatlon.com/  ;
        
        
        
        var locations : Array<Dynamic> = [new Location(51.5001524, -0.1262362), new Location(37.775196, -122.419204)];
        for (location in locations){
            var marker : Sprite = new Sprite();
            var markerImage : Bitmap = try cast(Type.createInstance(MarkerImage, []), Bitmap) catch(e:Dynamic) null;
            markerImage.x = -markerImage.width / 2;
            markerImage.y = -markerImage.height / 2;
            marker.addChild(markerImage);
            map.putMarker(location, marker);
        }  // make sure the map fills the screen:  
        
        
        
        stage.addEventListener(Event.RESIZE, onStageResize);
    }
    
    public function onStageResize(event : Event) : Void
    {
        map.setSize(stage.stageWidth, stage.stageHeight);
    }
}



class IconControls extends Sprite
{
    // icons "free to use in any kind of project unlimited times" from http://www.icojoy.com/articles/26/
    @:meta(Embed(source="images/001_21.png"))

    private var RightImage : Class<Dynamic>;
    
    @:meta(Embed(source="images/001_22.png"))

    private var DownImage : Class<Dynamic>;
    
    @:meta(Embed(source="images/001_23.png"))

    private var LeftImage : Class<Dynamic>;
    
    @:meta(Embed(source="images/001_24.png"))

    private var UpImage : Class<Dynamic>;
    
    @:meta(Embed(source="images/001_04.png"))

    private var OutImage : Class<Dynamic>;
    
    @:meta(Embed(source="images/001_03.png"))

    private var InImage : Class<Dynamic>;
    
    @:meta(Embed(source="images/001_20.png"))

    private var HomeImage : Class<Dynamic>;
    
    private var map : TweenMap;
    
    public function new(map : TweenMap)
    {
        super();
        this.map = map;
        
        this.mouseEnabled = false;
        this.mouseChildren = true;
        
        var right : Sprite = new Sprite();
        var down : Sprite = new Sprite();
        var left : Sprite = new Sprite();
        var up : Sprite = new Sprite();
        var zout : Sprite = new Sprite();
        var zin : Sprite = new Sprite();
        var home : Sprite = new Sprite();
        
        var buttons : Array<Dynamic> = [right, down, left, up, zout, zin, home];
        var imageClasses : Array<Dynamic> = [RightImage, DownImage, LeftImage, UpImage, OutImage, InImage, HomeImage];
        var actions : Array<Dynamic> = [map.panRight, map.panDown, map.panLeft, map.panUp, map.zoomOut, map.zoomIn, onHomeClick];
        for (sprite in buttons){
            var ImageClass : Class<Dynamic> = Type.getClass(imageClasses.shift());
            sprite.addChild(try cast(Type.createInstance(ImageClass, []), Bitmap) catch(e:Dynamic) null);
            sprite.useHandCursor = sprite.buttonMode = true;
            sprite.addEventListener(MouseEvent.CLICK, actions.shift(), false, 0, true);
            addChild(sprite);
        }
        
        left.x = 5;
        up.x = down.x = left.x + left.width + 5;
        right.x = down.x + down.width + 5;
        
        up.y = 5;
        left.y = down.y = right.y = up.y + up.height + 5;
        
        zout.x = zin.x = right.x + right.width + 10;
        zin.y = up.y;
        zout.y = zin.y + zin.height + 5;
        
        home.x = zout.x + zout.width + 10;
        home.y = zout.y;
        
        var rect : Rectangle = getRect(this);
        rect.inflate(rect.x, rect.y);
        
        graphics.beginFill(0xff0000, 0);
        graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
        graphics.endFill();
        
        map.addEventListener(MapEvent.RESIZED, onMapResize);
        onMapResize(null);
    }
    
    private function onMapResize(event : MapEvent) : Void
    {
        this.x = 10;
        this.y = map.getHeight() - this.height - 10;
    }
    
    private function onHomeClick(event : MouseEvent) : Void
    {
        map.tweenExtent(new MapExtent(85, -85, 180, -180));
    }
}
