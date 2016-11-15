package;
import com.modestmaps.Map;
import com.modestmaps.TweenMap;
import com.modestmaps.mapproviders.CartoDBProvider.CARTODB_MAPTYPE;

import openfl.utils.Object;
import com.modestmaps.core.MapExtent;
import com.modestmaps.events.MapEvent;
import com.modestmaps.events.MarkerEvent;
import com.modestmaps.extras.MapControls;
//todo copyright using external interfaces
//import com.modestmaps.extras.MapCopyright;
import com.modestmaps.extras.NavigatorWindow;
import com.modestmaps.extras.ZoomBox;
import com.modestmaps.extras.ZoomSlider;
import com.modestmaps.geo.Location;
import com.modestmaps.mapproviders.*;
import com.modestmaps.mapproviders.microsoft.*;
import com.modestmaps.mapproviders.yahoo.*;


import openfl.display.Sprite;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.text.TextFormat;    

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
class ModestMapsSample extends Sprite
{
	// Our modest map
	private var map:TweenMap;
	
	// a tooltip/flag that appears on marker rollover
	private var tooltip:Tooltip;
	
	// status text field at bottom of screen
	private var status:TextField;

	// our map provier button holder
	private var mapButtons:Sprite;
	
	// padding around map in pixels
	private static inline var PADDING:Int = 20;
	
	/**
	 * This constructor is called automatically when the SWF starts
	 */
	public function new() 
	{
		super();
		// setup stage
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;

		
		//MacMouseWheel.setup(stage);
		
		// create child components
		createChildren();
		
		// place the markers
		placeMarkers();

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

		/*map = new TweenMap(stage.stageWidth - 2 * PADDING, stage.stageHeight - 2 * PADDING, 
						   true,
						   new OpenStreetMapProvider(),
						   [{new MapExtent(37.829853, 37.700121, -122.212601, -122.514725); }] );*/
						   
		map = new TweenMap(stage.stageWidth - 2 * PADDING, stage.stageHeight - 2 * PADDING, 
						   true,
						   new CartoDBProvider(CARTODB_MAPTYPE.POSITRON,true),
						   [{new MapExtent(37.829853, 37.700121, -122.212601, -122.514725); }] );
						   
					   
		map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
		map.addEventListener(MouseEvent.MOUSE_WHEEL, map.onMouseWheel);
		map.x = map.y = PADDING;
		
		//map.addChild(map.grid.debugField);
		
		// listen for map events
		map.addEventListener(MapEvent.ZOOMED_BY, onZoomed);
		map.addEventListener(MapEvent.STOP_ZOOMING, onStopZoom);
		map.addEventListener(MapEvent.PANNED, onPanned);
		map.addEventListener(MapEvent.STOP_PANNING, onStopPan);
		map.addEventListener(MapEvent.RESIZED, onResized);
		
		// listen for marker events
		map.addEventListener(MarkerEvent.MARKER_CLICK, onMarkerClick);
		map.addEventListener(MarkerEvent.MARKER_ROLL_OVER, onMarkerRollOver);
		map.addEventListener(MarkerEvent.MARKER_ROLL_OUT, onMarkerRollOut);
		
		// add some controls using the MapControls extra
		// we're adding them as children of map so they move with the map
		map.addChild(new MapControls(map));	            
		map.addChild(new ZoomSlider(map));

		map.addChild(new ZoomBox(map));

		//map.addChild(new NavigatorWindow(map));

		// add a default copyright handler to the map
		//map.addChild(new MapCopyright(map, 140));
		
		// create tooltip
		tooltip = new Tooltip();
		
		// create text field to hold status text	                
		status = new TextField();
		status.defaultTextFormat = new TextFormat('Verdana', 10, 0x404040);
		status.selectable = false;
		status.text = 'Welcome to Modest Maps...';
		status.width = 600;
		status.height = 20;

		// create some provider buttons 

		mapButtons = new Sprite();
		mapButtons.addChild(new MapProviderButton('Open Street Map', map.getMapProvider(), true));
		//mapButtons.addChild(new MapProviderButton('Open Street Map', new OpenStreetMapProvider()));
		mapButtons.addChild(new MapProviderButton('MS Road', new MicrosoftRoadMapProvider()));
		mapButtons.addChild(new MapProviderButton('MS Aerial', new MicrosoftAerialMapProvider()));
		mapButtons.addChild(new MapProviderButton('MS Hybrid', new MicrosoftHybridMapProvider()));        	
		mapButtons.addChild(new MapProviderButton('Yahoo Road', new YahooRoadMapProvider()));
		mapButtons.addChild(new MapProviderButton('Yahoo Aerial', new YahooAerialMapProvider()));
		mapButtons.addChild(new MapProviderButton('Yahoo Hybrid', new YahooHybridMapProvider()));        	
		
		mapButtons.addChild(new MapProviderButton('AC Transit', new ACTransitMapProvider()));
					
		// arrange buttons 22px apart
		for (n in 0...mapButtons.numChildren) {
			
			var button:Sprite = cast(mapButtons.getChildAt(n),Sprite); 
			button.y = n * 22;
			button.x = mapButtons.width - button.width;
		}
		
		// listen for map provider button clicks	      
		mapButtons.addEventListener(MouseEvent.CLICK, onProviderButtonClick);
		
		//map.addChild(map.grid.debugField);
		
		// add children to the display list
		addChild(map);
		addChild(status);
		addChild(mapButtons);	  
		addChild(tooltip);   
		
		
	}
   
	/**
	 * Places sample markers on our map
	 */		
	private function placeMarkers():Void 
	{   	        	             	
		// Some sample data
		// In most cases, we would have loaded this from XML, or a web service.
		var markerpoints:Array<Dynamic>= [
			{ title:'Rochdale', loc:"37.865571, -122.259679"},
			{ title:'Parker Ave.', loc:"37.780492, -122.453731"},
			{ title:'Pepper Dr.', loc:"37.623443, -122.426577"},
			{ title:'3rd St.', loc:"37.779297, -122.392877"},
			{ title:'Divisadero St.', loc:"37.771919, -122.437413"},
			{ title:'Market St.', loc:"37.812734, -122.280064"},
			{ title:'17th St. is a long street with a short name, but we want to test the tooltip with a long title.', loc:"37.804274, -122.262940"}
		];
		
		var o:Object;
		
		// Now, we just loop through our data set, and place the markers
		for (o in markerpoints) {
							
			// step 1 - create a marker
			var marker:SampleMarker = new SampleMarker();
			
			// step 2 - give it any custom app-specific data it might need
			marker.title = o.title;	
			
			// step 3 - create a location object
			//
			// if you have lat and long...
			//     var loc:Location = new Location (lat, long);
			//
			// but, we have a comma-separated lat/long pair, so...
			var loc:Location = Location.fromString( o.loc );
			
			// step 4 - put the marker on the map
			map.putMarker( loc, marker);
		}	      
	}
	
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
		mapButtons.x = map.x + w - mapButtons.width - 10;
		mapButtons.y = map.y + 10;

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
		
		for (i in 0...mapButtons.numChildren-1) {
			var other:MapProviderButton = cast(mapButtons.getChildAt(i),MapProviderButton);
			if (other != button) {
				other.selected = false;
			}
		}
	}
	
	/**
	 * Marker Click
	 */
	private function onMarkerClick(event:MarkerEvent):Void 
	{
		var marker:SampleMarker = cast(event.marker,SampleMarker);
		status.text = "Marker Clicked:  " + marker.title + " " + event.location;
	}
	
	/**
	 * Marker Roll Over
	 */
	private function onMarkerRollOver(event:MarkerEvent):Void 
	{
		//trace('Roll Over ' + event.marker + event.location);
		var marker:SampleMarker = cast(event.marker,SampleMarker);
		
		// show tooltip
		var pt:Point = map.locationPoint( event.location, this );
		tooltip.x = pt.x;
		tooltip.y = pt.y;
		tooltip.label = marker.title;
		tooltip.visible = true;
	}
	
	/**
	 * Marker Roll Out
	 */
	private function onMarkerRollOut(event:MarkerEvent):Void 
	{
		// hide the tooltip
		tooltip.visible = false;
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
		status.text = 'Resized to: ' + event.newSize[0] + ' x ' + event.newSize[1];
	}
}
