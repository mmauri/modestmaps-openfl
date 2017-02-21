package;
import com.modestmaps.Map;
import com.modestmaps.core.MapExtent;
import com.modestmaps.events.MarkerEvent;
import com.modestmaps.geo.Location;
import openfl.geom.Point;
import openfl.text.TextField;

/**
 * ...
 * @author Marc Mauri
 */
class DemoMarkers
{

		// a tooltip/flag that appears on marker rollover
	private var _tooltip : Tooltip;
	private var _parent : Main;

	
	
	public function new(parent : Main) 
	{
		_parent = parent;
		_tooltip = new Tooltip();
		parent.map.addChild(_tooltip);
		parent.map.addEventListener(MarkerEvent.MARKER_CLICK, onMarkerClick);
		parent.map.addEventListener(MarkerEvent.MARKER_ROLL_OVER, onMarkerRollOver);
		parent.map.addEventListener(MarkerEvent.MARKER_ROLL_OUT, onMarkerRollOut);
	}
	
	public function placeMarkers():Void
	{
		// Some sample data
		// In most cases, we would have loaded this from XML, or a web service.
		var markerpoints = [
		{ title:'Rochdale', loc:"37.865571, -122.259679"},
		{ title:'Parker Ave.', loc:"37.780492, -122.453731"},
		{ title:'Pepper Dr.', loc:"37.623443, -122.426577"},
		{ title:'3rd St.', loc:"37.779297, -122.392877"},
		{ title:'Divisadero St.', loc:"37.771919, -122.437413"},
		{ title:'Market St.', loc:"37.812734, -122.280064"},
		{ title:'17th St. is a long street with a short name, but we want to test the tooltip with a long title.', loc:"37.804274, -122.262940"}
		];

		var o:Dynamic;

		// Now, we just loop through our data set, and place the markers
		for (o in markerpoints)
		{

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
			_parent.map.putMarker( loc, marker);
		}
		_parent.map.tweenExtent(new MapExtent(37.829853, 37.700121, -122.212601, -122.514725),3);
	}
	
	/**
	 * Marker Click
	 */
	private function onMarkerClick(event:MarkerEvent):Void
	{
		var marker:SampleMarker = cast(event.marker,SampleMarker);
		_parent.status.text = "Marker Clicked:  " + marker.title + " " + event.location;
	}

	/**
	 * Marker Roll Over
	 */
	private function onMarkerRollOver(event:MarkerEvent):Void
	{
		trace('Roll Over ' + event.marker + event.location);
		var marker:SampleMarker = cast(event.marker,SampleMarker);

		// show tooltip
		var pt:Point = _parent.map.locationPoint( event.location, _parent.map);
		_tooltip.x = pt.x;
		_tooltip.y = pt.y;
		_tooltip.label = marker.title;
		_tooltip.visible = true;
	}

	/**
	 * Marker Roll Out
	 */
	private function onMarkerRollOut(event:MarkerEvent):Void
	{
		// hide the tooltip
		_tooltip.visible = false;
	}
	
	public function dispose(): Void 
	{
		_parent.map.removeEventListener(MarkerEvent.MARKER_CLICK, onMarkerClick);
		_parent.map.removeEventListener(MarkerEvent.MARKER_ROLL_OVER, onMarkerRollOver);
		_parent.map.removeEventListener(MarkerEvent.MARKER_ROLL_OUT, onMarkerRollOut);
		_parent.map.removeChild(_tooltip);
	}
}