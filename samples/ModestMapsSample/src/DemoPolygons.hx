package;
import com.modestmaps.TweenMap;
import com.modestmaps.geo.Location;
import com.modestmaps.core.MapExtent;
import com.modestmaps.overlays.PolygonClip;
import com.modestmaps.overlays.PolygonMarker;

/**
 * ...
 * @author mmp
 */
class DemoPolygons
{

	public function new(map : TweenMap) 
	{
		var polygonClip : PolygonClip = new PolygonClip(map);
        
        var locations : Array<Location> = [new Location(37.83435, 21.36860), 
        new Location(37.83435, 21.58489), 
        new Location(37.78105, 21.58489), 
        new Location(37.78105, 21.36860)];
        
        var polygon : PolygonMarker = new PolygonMarker(map, locations, true);
        
        polygonClip.attachMarker(polygon, polygon.location);
        
        map.addChild(polygonClip);
        
        map.setExtent(MapExtent.fromLocations(locations));
        
	}
	
}