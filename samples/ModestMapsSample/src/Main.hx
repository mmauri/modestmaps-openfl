package;
import com.modestmaps.TweenMap;
import com.modestmaps.events.MapEvent;
import com.modestmaps.extras.MapControls;
import com.modestmaps.extras.MapScale;
import com.modestmaps.extras.NavigatorWindow;
import com.modestmaps.extras.ZoomBox;
import com.modestmaps.extras.ZoomSlider;
import com.modestmaps.mapproviders.CartoDBProvider;
import com.modestmaps.mapproviders.CartoDBProvider.CARTODB_MAPTYPE;
import com.modestmaps.mapproviders.OpenStreetMapProvider;
import openfl.display.Sprite;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;

//todo copyright using external interfaces
//import com.modestmaps.extras.MapCopyright;


/**
 * Pure Actionscript 3 Flex Builder project,
 * based on ModestMapsSample.fla by David Knape.
 *
 * This demonstration app shows the basics of:
 *  - creating a map
 *  - setting/changing map providers
 *  - adding markers
 *  - listening for map and marker events
 *
 *  @author David Knape
 */
//[SWF(backgroundColor="#ffffff", frameRate="30")]
class Main extends Sprite
{
	// Our modest map
	public var map:TweenMap;

	// status text field at bottom of screen
	public var status:TextField;

	// our map provier button holder
	private var _mapButtons:Sprite;

	// padding around map in pixels
	private static inline var PADDING:Int = 20;
	
	

	/**
	 * This constructor is called automatically when the SWF starts
	 */
	public function new()
	{
		super();

		// setup stage
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;


		//MacMouseWheel.setup(stage);
		// create child components
		createChildren();

		// place the markers
		var demoMarkers = new DemoMarkers(this);
		demoMarkers.placeMarkers();
		
		//Heatmap
		//var demoHeatmap = new DemoHeatmap(map);
	
		//var demoMandel = new DemoMandel(map);
		
		//var demoPolygons = new DemoPolygons(map);
		
		addChild(_mapButtons);
		// adjust sizes for things if the window changes
		stage.addEventListener(Event.RESIZE, onResize);

		// init size by forcing call to stage resize handler
		onResize();
	}

	/**
	 * Creates child componets
	 * - map
	 * - status text field
	 * - buttons
	 */
	private function createChildren():Void
	{
		// create map
		map = new TweenMap(stage.stageWidth - 2 * PADDING, stage.stageHeight - 2 * PADDING, true,
			new CartoDBProvider(CARTODB_MAPTYPE.POSITRON, false)); // ,
			//[{new MapExtent(37.829853, 37.700121, -122.212601, -122.514725); }] );

		map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
		map.addEventListener(MouseEvent.MOUSE_WHEEL, map.onMouseWheel);
		map.x = map.y = PADDING;

		// listen for map events
		map.addEventListener(MapEvent.ZOOMED_BY, onZoomed);
		map.addEventListener(MapEvent.STOP_ZOOMING, onStopZoom);
		map.addEventListener(MapEvent.PANNED, onPanned);
		map.addEventListener(MapEvent.STOP_PANNING, onStopPan);
		map.addEventListener(MapEvent.RESIZED, onResized);

		// listen for marker events
		

		//gestures
		//if (Multitouch.supportsGestureEvents) {
		//Multitouch.inputMode = MultitouchInputMode.GESTURE;
		//map.addEventListener(flash.events.TransformGestureEvent.GESTURE_ZOOM , map.onGestureZoom);
		//}

		// add some controls using the MapControls extra
		// we're adding them as children of map so they move with the map
		map.addChild(new MapControls(map));
		map.addChild(new ZoomSlider(map));
		map.addChild(new ZoomBox(map));
		map.addChild(new NavigatorWindow(map));
		map.addChild(new MapScale(map, 140));

		// add a default copyright handler to the map
		//map.addChild(new MapCopyright(map, 140));

		// create text field to hold status text
		status = new TextField();
		status.defaultTextFormat = new TextFormat('Verdana', 10, 0x404040);
		status.selectable = false;
		status.text = 'Welcome to Modest Maps...';
		status.width = 600;
		status.height = 20;

		// create some provider buttons
		addProviderButtons();


		//show debug window
		map.addChild(map.grid.debugField);

		// add children to the display list
		addChild(map);
		addChild(status);
		
	}

	private function addProviderButtons() : Void 
	{
		_mapButtons = new Sprite();
		_mapButtons.addChild(new MapProviderButton('Carto Positron', map.getMapProvider(), true));
		_mapButtons.addChild(new MapProviderButton('Carto Positron SSL', new CartoDBProvider(CARTODB_MAPTYPE.POSITRON,true)));
		_mapButtons.addChild(new MapProviderButton('Open Street Map', new OpenStreetMapProvider()));
		/*mapButtons.addChild(new MapProviderButton('MS Road', new MicrosoftRoadMapProvider()));
		mapButtons.addChild(new MapProviderButton('MS Aerial', new MicrosoftAerialMapProvider()));
		mapButtons.addChild(new MapProviderButton('MS Hybrid', new MicrosoftHybridMapProvider()));
		mapButtons.addChild(new MapProviderButton('Yahoo Road', new YahooRoadMapProvider()));
		mapButtons.addChild(new MapProviderButton('Yahoo Aerial', new YahooAerialMapProvider()));
		mapButtons.addChild(new MapProviderButton('Yahoo Hybrid', new YahooHybridMapProvider()));

		mapButtons.addChild(new MapProviderButton('AC Transit', new ACTransitMapProvider()));*/

		// arrange buttons 22px apart
		for (n in 0..._mapButtons.numChildren)
		{

			var button:Sprite = cast(_mapButtons.getChildAt(n),Sprite);
			button.y = n * 22;
			button.x = _mapButtons.width - button.width;
		}
		// listen for map provider button clicks
		_mapButtons.addEventListener(MouseEvent.CLICK, onProviderButtonClick);
	}
	/**
	 * Places sample markers on our map
	 */
	
	/**
	 * Stage Resize handler
	 */
	private function onResize(event:Event = null):Void
	{
		var w:Int = stage.stageWidth - 2 * PADDING;
		var h:Int = stage.stageHeight - 2 * PADDING;

		// position and size the map
		map.x = map.y = PADDING;
		map.setSize(w, h);

		// align the buttons to the right
		_mapButtons.x = map.x + w - _mapButtons.width - 10;
		_mapButtons.y = map.y + 10;

		// place status just below the map on the left
		status.width = w;
		status.x = map.x + 2;
		status.y = map.y + h;
	}

	/**
	 * Change map provider when provider buttons are clicked
	 */
	private function onProviderButtonClick(event:Event):Void
	{
		var button:MapProviderButton = cast(event.target,MapProviderButton);
		map.setMapProvider(button.mapProvider);
		button.selected = true;

		for (i in 0..._mapButtons.numChildren-1)
		{
			var other:MapProviderButton = cast(_mapButtons.getChildAt(i),MapProviderButton);
			if (other != button)
			{
				other.selected = false;
			}
		}
	}

	
	//---------------------
	// Map Event Handlers
	//---------------------
	private function onPanned(event:MapEvent):Void
	{
		status.text = 'Panned by ' + event.panDelta.toString() + ', top left: ' + map.getExtent().northWest.toString() + ', bottom right: ' + map.getExtent().southEast.toString();
	}

	private function onStopPan(event:MapEvent):Void
	{
		status.text = 'Stopped panning, top left: ' + map.getExtent().northWest.toString() + ', center: ' + map.getCenterZoom()[0].toString() + ', bottom right: ' + map.getExtent().southEast.toString() + ', zoom: ' + map.getCenterZoom()[1];
	}

	private function onZoomed(event:MapEvent):Void
	{
		status.text = 'Zoomed by ' + event.zoomDelta + ', top left: ' + map.getExtent().northWest.toString() + ', bottom right: ' + map.getExtent().southEast.toString();
	}

	private function onStopZoom(event:MapEvent):Void
	{
		status.text = 'Stopped zooming, top left: ' + map.getExtent().northWest.toString() + ', center: ' + map.getCenterZoom()[0].toString() + ', bottom right: ' + map.getExtent().southEast.toString() + ', zoom: ' + map.getCenterZoom()[1];
	}

	private function onResized(event:MapEvent):Void
	{
		status.text = 'Resized to: ' + event.newSize.x + ' x ' + event.newSize.y;
	}
}
