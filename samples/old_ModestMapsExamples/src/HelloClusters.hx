
import com.adobe.viewsource.ViewSource;
import com.modestmaps.Map;
import com.modestmaps.TweenMap;
import com.modestmaps.core.MapExtent;
import com.modestmaps.events.MapEvent;
import com.modestmaps.extras.MapControls;
import com.modestmaps.extras.MapCopyright;
import com.modestmaps.geo.Location;
import com.modestmaps.mapproviders.microsoft.MicrosoftHybridMapProvider;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

@:meta(SWF(backgroundColor="#ffffff"))




import flash.utils.Dictionary;

class HelloClusters extends Sprite
{
    public var map : Map;
    
    public function new()
    {
        super();
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        
        ViewSource.addMenuItem(this, "srcview/index.html", true);
        
        // make a draggable TweenMap so that we have smooth zooming and panning animation
        // use Microsoft's Hybrid tiles.
        map = new TweenMap(stage.stageWidth, stage.stageHeight, true, new MicrosoftHybridMapProvider(), new Location(51.500152, -0.126236), 11);
        map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
        
        // add some basic controls
        // you're free to use these, but I'd make my own if I was a Flash coder :)
        map.addChild(new MapControls(map));
        //map.addChild(new ZoomBox(map));
        
        // add a copyright handler
        // (this is a bit of a hack, but works well enough for now)
        map.addChild(new MapCopyright(map));
        
        var extent : MapExtent = map.getExtent();
        
        for (i in 0...200){
            // create an instance of the Marker class defined below
            var marker : Marker = new Marker(new Location(extent.south + Math.random() * (extent.north - extent.south), extent.west + Math.random() * (extent.east - extent.west)));
            features.push(marker);
            trace(marker.category);
        }
        
        map.setZoom(5);
        
        map.addEventListener(MapEvent.STOP_ZOOMING, cluster);
        //map.addEventListener(MapEvent.EXTENT_CHANGED, cluster);
        map.addEventListener(MapEvent.STOP_PANNING, cluster);
        
        // add map to stage last, so as to avoid markers jumping around
        addChild(map);
        
        cluster(null);
        
        // make sure the map always fills the screen:
        stage.addEventListener(Event.RESIZE, onStageResize);
    }
    
    private var distance : Float = 20;
    
    private var features : Array<Dynamic> = [];
    
    private var clusters : Array<Dynamic>;
    
    private var clustering : Bool;
    
    private var resolution : Float;
    
    /**
	     * Method: cluster
	     * Cluster features based on some threshold distance.
	     */
    private function cluster(event : MapEvent) : Void
    {
        if (this.features && this.features.length > 1) {
            var resolution : Float = map.getZoom();
            var extent : MapExtent = map.getExtent();
            if (resolution != this.resolution || !this.clustersExist()) {
                this.resolution = resolution;
                var clusters : Array<Dynamic> = [];
                var feature : Marker;
                var clustered : Bool;
                var cluster : Dynamic;
                for (i in 0...this.features.length){
                    feature = this.features[i];
                    if (!extent.contains(feature.location))                         
					{
						++i;
						continue;
                    };
                    clustered = false;
                    for (j in 0...clusters.length){
                        cluster = clusters[j];
                        if (this.shouldCluster(cluster, feature)) {
                            this.addToCluster(cluster, feature);
                            clustered = true;
                            break;
                        }
                    }
                    if (!clustered) {
                        clusters.push(this.createCluster(this.features[i]));
                    }
                }
                map.markerClip.removeAllMarkers();
                if (clusters.length > 0) {
                    this.clustering = true;
                    // A legitimate feature addition could occur during this
                    // addFeatures call.  For clustering to behave well, features
                    // should be removed from a layer before requesting a new batch.
                    for (cluster in clusters){
                        var marker : ClusterMarker = new ClusterMarker(cluster.cluster);
                        map.putMarker(MapExtent.fromLocationProperties(cluster.cluster).center, marker);
                    }
                    this.clustering = false;
                }
                this.clusters = clusters;
            }
        }
    }
    
    /**
	     * Method: clustersExist
	     * Determine whether calculated clusters are already on the layer.
	     *
	     * Returns:
	     * {Boolean} The calculated clusters are already on the layer.
	     */
    private function clustersExist() : Bool
    {
        var exist : Bool = false;
        if (this.clusters && this.clusters.length > 0 &&
            this.clusters.length == map.markerClip.getMarkerCount()) {
            exist = true;
            for (i in 0...this.clusters.length){
                if (map.markerClip.getMarker(clusters[i].name) == null) {
                    exist = false;
                    break;
                }
            }
        }
        return exist;
    }
    
    /**
	     * Method: shouldCluster
	     * Determine whether to include a feature in a given cluster.
	     *
	     * Parameters:
	     * cluster - {<OpenLayers.Feature.Vector>} A cluster.
	     * feature - {<OpenLayers.Feature.Vector>} A feature.
	     *
	     * Returns:
	     * {Boolean} The feature should be included in the cluster.
	     */
    private function shouldCluster(cluster : Dynamic, feature : Marker) : Bool
    {
        var cc : Point = map.locationPoint(cluster.location);
        var fc : Point = map.locationPoint(feature.location);
        var distance : Float = Point.distance(cc, fc);
        return (distance <= this.distance);
    }
    
    /**
	     * Method: addToCluster
	     * Add a feature to a cluster.
	     *
	     * Parameters:
	     * cluster - {<OpenLayers.Feature.Vector>} A cluster.
	     * feature - {<OpenLayers.Feature.Vector>} A feature.
	     */
    private function addToCluster(cluster : Dynamic, feature : Marker) : Void
    {
        cluster.cluster.push(feature);
        cluster.count += 1;
    }
    
    /**
	     * Method: createCluster
	     * Given a feature, create a cluster.
	     *
	     * Parameters:
	     * feature - {<OpenLayers.Feature.Vector>}
	     *
	     * Returns:
	     * {<OpenLayers.Feature.Vector>} A cluster.
	     */
    private function createCluster(feature : Marker) : Dynamic
    {
        return {
            location : feature.location,
            count : 1,
            name : "cluster-" + Std.string(Math.random()),
            cluster : [feature],

        };
    }
    
    
    public function onStageResize(event : Event) : Void
    {
        map.setSize(stage.stageWidth, stage.stageHeight);
    }
}



class Marker
{
    public var location : Location;
    public var category : String;
    
    public static var CATEGORIES : Array<Dynamic> = ["Obama", "Biden", "McCain", "Palin", "Blair", "Bush", "Clinton"];
    public static var colors : Dynamic = {
            Obama : 0xff9900,
            Blair : 0x99ff00,
            Biden : 0x0099ff,
            McCain : 0xff0099,
            Bush : 0x00ff99,
            Palin : 0x9900ff,
            Clinton : 0xffff00,

        };
    
    public function new(location : Location)
    {
        this.location = location;
        this.category = CATEGORIES[as3hx.Compat.parseInt(Math.random() * CATEGORIES.length)];
    }
}

class ClusterMarker extends Sprite
{
    public function new(markers : Array<Dynamic>)
    {
        super();
        if (markers.length == 1) {
            graphics.beginFill(0x000000);
            graphics.drawCircle(0, 0, 12);
            graphics.beginFill(Int(Marker.colors[markers[0].category]));
            graphics.drawCircle(0, 0, 10);
        }
        else {
            
            var counts : Dictionary = new Dictionary();
            
            for (marker in markers){
                counts[marker.category] = (counts[marker.category]) ? counts[marker.category] + 1 : 1;
            }
            
            graphics.beginFill(0x000000);
            graphics.drawCircle(0, 0, 12);
            
            var startAngle : Float = 0;
            trace("");
            for (category/* AS3HX WARNING could not determine type for var: category exp: EField(EIdent(Marker),CATEGORIES) type: null */ in Marker.CATEGORIES){
                if (Reflect.field(counts, category)) {
                    trace(Std.string(Int(Marker.colors[category])));
                    graphics.beginFill(Int(Marker.colors[category]));
                    graphics.moveTo(0, 0);
                    var prop : Float = Std.parseFloat(Reflect.field(counts, category)) / markers.length;
                    var angle : Float = startAngle + (Math.PI * 2 * prop);
                    trace(angle);
                    var a : Float = startAngle;
                    while (a < angle){
                        var px : Float = 10 * Math.cos(a);
                        var py : Float = 10 * Math.sin(a);
                        graphics.lineTo(px, py);
                        a += Math.PI / 20.0;
                    }
                    px = 10 * Math.cos(angle);
                    py = 10 * Math.sin(angle);
                    graphics.lineTo(px, py);
                    graphics.lineTo(0, 0);
                    graphics.endFill();
                    startAngle = angle;
                }
            }
            trace("");
        }
    }
}
