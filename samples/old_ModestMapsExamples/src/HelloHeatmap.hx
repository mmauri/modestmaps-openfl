
import com.adobe.viewsource.ViewSource;
import com.modestmaps.Map;
import com.modestmaps.TweenMap;
import com.modestmaps.extras.MapControls;
import com.modestmaps.geo.Location;
import com.modestmaps.mapproviders.microsoft.MicrosoftAerialMapProvider;

import flash.display.BlendMode;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

@:meta(SWF(backgroundColor="#000000"))


import com.modestmaps.overlays.MarkerClip;

import flash.display.DisplayObject;

import flash.display.BitmapData;
import flash.geom.Matrix;

import flash.display.GradientType;
import flash.geom.Rectangle;


import flash.filters.BlurFilter;
import flash.display.Bitmap;

import com.modestmaps.events.MapEvent;

import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.IMapProvider;

class HelloHeatmap extends Sprite
{
    public var map : Map;
    public var overlay : HeatMarkerClip;
    
    public function new()
    {
        super();
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        
        ViewSource.addMenuItem(this, "srcview/index.html", true);
        
        map = new TweenMap(stage.stageWidth, stage.stageHeight, true, new MicrosoftAerialMapProvider(), new Location(37.775196, -122.419204), 11);
        map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
        addChild(map);
        
        var locations : Array<Dynamic> = [];
        for (i in 0...2048){
            var w : Float = 3.0 * (Math.random() - 0.5);
            var h : Float = 3.0 * (Math.random() - 0.5);
            var p : Point = new Point(map.getWidth() / 2 + w * map.getWidth(), map.getHeight() / 2 + h * map.getHeight());
            locations.push(map.pointLocation(p));
        }
        
        overlay = new HeatMarkerClip(map, locations, HeatMarkerClip.THERMAL, 25, 10);
        addChild(overlay);
        
        // add these to the stage so they're on top of our overlay too
        addChild(new MapControls(map));
        
        // make sure the map fills the screen:
        stage.addEventListener(Event.RESIZE, onStageResize);
    }
    
    private function onStageResize(event : Event) : Void
    {
        map.setSize(stage.stageWidth, stage.stageHeight);
    }
}



//
// hat tip to Michael Vandanike - the gradient arrays and drawHeatMap function are basically untouched from
// http://michaelvandaniker.googlecode.com/svn/trunk/michaelvandaniker/src/com/michaelvandaniker/display/HeatMap.as
//
class HeatMarkerClip extends Sprite
{
    private var dirty(get, set) : Bool;

    private var heatBitmapData : BitmapData;
    
    private var nativeZoom : Int;
    private var nativeRadius : Int;
    private var gradientArray : Array<Dynamic>;
    
    // calculated from nativeZoom and nativeRadius
    private var itemRadius : Int;
    
    // TODO: calculate this from the number of points that overlap
    private var centerValue : Int = 128;
    
    /**
	 * A few BitmapData operations take a Point as an argument.
	 * Save a tiny bit of memory by making that Point a constant.
	 */
    private static var POINT : Point = new Point();
    
    public static var THERMAL : Array<Dynamic> = [0, 167772262, 336396403, 504430711, 672727155, 857605496, 1025311865, 1193542778, 1361445755, 1529480062, 1714226559, 1882326399, 2050229378, 2218264197, 2386232710, 2571044231, 2739013001, 2906982028, 3075081868, 3243050383, 3427796369, 3595765395, 3763734164, 3931768213, 4099736983, 4284614554, 4284745369, 4284876441, 4285007513, 4285138585, 4285334937, 4285466009, 4285597081, 4285728153, 4285924505, 4286055577, 4286186649, 4286317721, 4286514073, 4286645145, 4286776217, 4286907289, 4287103641, 4287234713, 4287365785, 4287496857, 4287693209, 4287824281, 4287955353, 4288086425, 4288283033, 4288348568, 4288414103, 4288545431, 4288610966, 4288742293, 4288807829, 4288938900, 4289004691, 4289135763, 4289201554, 4289332625, 4289398161, 4289529488, 4289595024, 4289726351, 4289791886, 4289922958, 4289988749, 4290119820, 4290185612, 4290316683, 4290382218, 4290513546, 4290579081, 4290710409, 4290776198, 4290841987, 4290907777, 4290973822, 4291039612, 4291105401, 4291171447, 4291237236, 4291303026, 4291369071, 4291434861, 4291500650, 4291566696, 4291632485, 4291698275, 4291764320, 4291830110, 4291895899, 4291961945, 4292027734, 4292093524, 4292159569, 4292225359, 4292291148, 4292422730, 4292422983, 4292489029, 4292489282, 4292555328, 4292621118, 4292621627, 4292687417, 4292753462, 4292753972, 4292819762, 4292885807, 4292886061, 4292952106, 4292952360, 4293018406, 4293084195, 4293084705, 4293150750, 4293216540, 4293217050, 4293282839, 4293348885, 4293349138, 4293415184, 4293481230, 4293481485, 4293481996, 4293547788, 4293548299, 4293614091, 4293614602, 4293614858, 4293680905, 4293681416, 4293747208, 4293747719, 4293747975, 4293814022, 4293814278, 4293880325, 4293880581, 4293881092, 4293947139, 4293947395, 4294013442, 4294013698, 4294014209, 4294080001, 4294080512, 4294146560, 4294146816, 4294147328, 4294213376, 4294213632, 4294214144, 4294280192, 4294280704, 4294280960, 4294347008, 4294347520, 4294347776, 4294413824, 4294414336, 4294480384, 4294480640, 4294481152, 4294547200, 4294547456, 4294547968, 4294614016, 4294614528, 4294614784, 4294680832, 4294681344, 4294747392, 4294747648, 4294747904, 4294748416, 4294748672, 4294749184, 4294749440, 4294749952, 4294750208, 4294750464, 4294750976, 4294751232, 4294751744, 4294752000, 4294752512, 4294752768, 4294753280, 4294753536, 4294753792, 4294754304, 4294754560, 4294755072, 4294755328, 4294755840, 4294756096, 4294756608, 4294756869, 4294757130, 4294757391, 4294757652, 4294757913, 4294758174, 4294758435, 4294758696, 4294758957, 4294759219, 4294759480, 4294759741, 4294760258, 4294760519, 4294760780, 4294761041, 4294826838, 4294827099, 4294827360, 4294827622, 4294827883, 4294828144, 4294828405, 4294828666, 4294829183, 4294829444, 4294829705, 4294829966, 4294830227, 4294830489, 4294830750, 4294831011, 4294831272, 4294897069, 4294897330, 4294897591, 4294897852, 4294898369, 4294898630, 4294898892, 4294899153, 4294899414, 4294899675, 4294899936, 4294900197, 4294900458, 4294900719, 4294900980, 4294901241, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295];
    public static var RAINBOW : Array<Dynamic> = [0, 167772415, 335544575, 503316726, 671088889, 855638261, 1023410423, 1191182584, 1358954741, 1526726902, 1711276277, 1879048438, 2046820599, 2214592757, 2382364918, 2566914293, 2734686453, 2902458614, 3070230773, 3238002934, 3422552309, 3590324469, 3758096630, 3925868788, 4093640949, 4278190326, 4278191862, 4278193398, 4278195190, 4278196726, 4278198518, 4278200054, 4278201590, 4278203382, 4278204918, 4278206710, 4278208246, 4278209782, 4278211574, 4278213110, 4278214902, 4278216438, 4278217974, 4278219766, 4278221302, 4278223094, 4278224630, 4278226166, 4278227958, 4278229494, 4278296822, 4278232053, 4278232821, 4278233588, 4278234356, 4278235124, 4278235891, 4278236659, 4278237426, 4278238194, 4278238962, 4278239729, 4278240497, 4278241264, 4278242032, 4278242800, 4278243567, 4278244335, 4278245102, 4278245870, 4278246638, 4278247405, 4278248173, 4278248940, 4278249708, 4278250732, 4278250722, 4278250969, 4278251215, 4278251462, 4278251452, 4278251699, 4278251945, 4278252192, 4278252183, 4278252429, 4278252676, 4278252922, 4278252913, 4278253159, 4278253406, 4278253652, 4278253643, 4278253890, 4278254136, 4278254383, 4278254373, 4278254620, 4278254866, 4278255113, 4278255360, 4278910720, 4279566080, 4280221440, 4280876800, 4281597696, 4282253056, 4282908416, 4283563776, 4284219136, 4284940032, 4285595392, 4286250752, 4286906112, 4287561472, 4288282368, 4288937728, 4289593088, 4290248448, 4290903808, 4291624704, 4292280064, 4292935424, 4293590784, 4294246144, 4294967040, 4294900736, 4294834432, 4294768384, 4294702080, 4294636032, 4294569728, 4294503680, 4294437376, 4294371328, 4294305024, 4294238976, 4294172672, 4294106624, 4294040320, 4293974272, 4293907968, 4293841920, 4293775616, 4293709568, 4293643264, 4293577216, 4293510912, 4293444864, 4293378560, 4293378048, 4293377536, 4293442560, 4293507584, 4293572608, 4293637632, 4293702656, 4293767680, 4293832704, 4293897728, 4293962752, 4294027776, 4294092800, 4294158080, 4294223104, 4294288128, 4294353152, 4294418176, 4294483200, 4294548224, 4294613248, 4294678272, 4294743296, 4294808320, 4294873344, 4294938624, 4294937088, 4294935552, 4294934016, 4294932480, 4294931200, 4294929664, 4294928128, 4294926592, 4294925312, 4294923776, 4294922240, 4294920704, 4294919424, 4294917888, 4294916352, 4294914816, 4294913536, 4294912000, 4294910464, 4294908928, 4294907648, 4294906112, 4294904576, 4294903040, 4294901760, 4294903045, 4294904330, 4294905615, 4294906900, 4294908185, 4294909470, 4294910755, 4294912040, 4294913325, 4294914867, 4294916152, 4294917437, 4294918722, 4294920007, 4294921292, 4294922577, 4294923862, 4294925147, 4294926432, 4294927974, 4294929259, 4294930544, 4294931829, 4294933114, 4294934399, 4294935684, 4294936969, 4294938254, 4294939539, 4294941081, 4294942366, 4294943651, 4294944936, 4294946221, 4294947506, 4294948791, 4294950076, 4294951361, 4294952646, 4294954188, 4294955473, 4294956758, 4294958043, 4294959328, 4294960613, 4294961898, 4294963183, 4294964468, 4294965753, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295];
    public static var RED_WHITE_BLUE : Array<Dynamic> = [0, 50331903, 100663551, 167772415, 218104063, 285212927, 335544575, 385876223, 452985077, 503316726, 570425591, 620757240, 671088889, 738197753, 788529401, 855638266, 905969914, 956301562, 1023410427, 1073742071, 1140850935, 1191182584, 1241514232, 1308623096, 1358954744, 1426063609, 1476395257, 1526726905, 1593835770, 1644167418, 1711276282, 1761607930, 1811939578, 1879048440, 1929380090, 1996488954, 2046820603, 2097152251, 2164261113, 2214592761, 2281701625, 2332033273, 2382364923, 2449473787, 2499805436, 2566914298, 2617245946, 2667577594, 2734686458, 2785018106, 2852126972, 2902458620, 2952790267, 3019899132, 3070230780, 3137339644, 3187671292, 3238002939, 3305111803, 3355443452, 3422552316, 3472883964, 3523215612, 3590324477, 3640656124, 3707764988, 3758096636, 3808428285, 3875537149, 3925868797, 3992977662, 4043309309, 4093640957, 4160749822, 4211081470, 4278190335, 4278386939, 4278583544, 4278845684, 4279042289, 4279304430, 4279501034, 4279697639, 4279959779, 4280156384, 4280418525, 4280615129, 4280811734, 4281073874, 4281270479, 4281532620, 4281729224, 4281925829, 4282187969, 4282384574, 4282646715, 4282843319, 4283039924, 4283302064, 4283498669, 4283760810, 4283957414, 4284154019, 4284416159, 4284612764, 4284874905, 4285071509, 4285268114, 4285530254, 4285726859, 4285989000, 4286185604, 4286382209, 4286644349, 4286840954, 4287103095, 4287299699, 4287496304, 4287758444, 4287955049, 4288217190, 4288413794, 4288610399, 4288872539, 4289069144, 4289331285, 4289527889, 4289724494, 4289986634, 4290183239, 4290445380, 4290641984, 4290838589, 4291100729, 4291297334, 4291559475, 4291756079, 4291952684, 4292214824, 4292411429, 4292673570, 4292870174, 4293066779, 4293328919, 4293525524, 4293787665, 4293984269, 4294180874, 4294443014, 4294639619, 4294901760, 4294902531, 4294903302, 4294904330, 4294905101, 4294906129, 4294906900, 4294907671, 4294908699, 4294909470, 4294910498, 4294911269, 4294912040, 4294913068, 4294913839, 4294914867, 4294915638, 4294916409, 4294917437, 4294918208, 4294919236, 4294920007, 4294920778, 4294921806, 4294922577, 4294923605, 4294924376, 4294925147, 4294926175, 4294926946, 4294927974, 4294928745, 4294929516, 4294930544, 4294931315, 4294932343, 4294933114, 4294933885, 4294934913, 4294935684, 4294936712, 4294937483, 4294938254, 4294939282, 4294940053, 4294941081, 4294941852, 4294942623, 4294943651, 4294944422, 4294945450, 4294946221, 4294946992, 4294948020, 4294948791, 4294949819, 4294950590, 4294951361, 4294952389, 4294953160, 4294954188, 4294954959, 4294955730, 4294956758, 4294957529, 4294958557, 4294959328, 4294960099, 4294961127, 4294961898, 4294962926, 4294963697, 4294964468, 4294965496, 4294966267, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295];
    
    private var bitmap : Bitmap;
    
    // the projection of the current map's provider
    // if this changes we need to recache coordinates
    private var previousGeometry : String;
    
    // setting this.dirty = true will redraw an MapEvent.RENDERED
    private var _dirty : Bool;
    
    private var map : Map;
    
    private var locations : Array<Dynamic>;
    private var coordinates : Array<Dynamic>;
    
    public var zoomTolerance : Float = 4;
    
    private var drawCoord : Coordinate;
    
    public function new(map : Map, locations : Array<Dynamic>, gradientArray : Array<Dynamic>, nativeRadius : Int = 25, nativeZoom : Int = 11)
    {
        super();
        buttonMode = false;
        mouseEnabled = false;
        mouseChildren = true;
        
        this.locations = locations;
        
        this.map = map;
        this.x = map.getWidth() / 2;
        this.y = map.getHeight() / 2;
        
        previousGeometry = map.getMapProvider().geometry();
        
        this.nativeZoom = nativeZoom;
        this.nativeRadius = nativeRadius;
        this.gradientArray = gradientArray;
        
        bitmap = new Bitmap();
        addChild(bitmap);
        
        calculateCoordinates();
        
        map.addEventListener(MapEvent.START_ZOOMING, onMapStartZooming);
        map.addEventListener(MapEvent.STOP_ZOOMING, onMapStopZooming);
        map.addEventListener(MapEvent.ZOOMED_BY, onMapZoomedBy);
        map.addEventListener(MapEvent.START_PANNING, onMapStartPanning);
        map.addEventListener(MapEvent.STOP_PANNING, onMapStopPanning);
        map.addEventListener(MapEvent.PANNED, onMapPanned);
        map.addEventListener(MapEvent.RESIZED, onMapResized);
        map.addEventListener(MapEvent.EXTENT_CHANGED, onMapExtentChanged);
        map.addEventListener(MapEvent.RENDERED, drawHeatMap);
        map.addEventListener(MapEvent.MAP_PROVIDER_CHANGED, onMapProviderChanged);
        
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }
    
    private function onAddedToStage(event : Event) : Void
    {
        //addEventListener(Event.RENDER, updateClips);
        
        dirty = true;
        drawHeatMap();
        
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
    }
    
    private function onRemovedFromStage(event : Event) : Void
    {
        //removeEventListener(Event.RENDER, updateClips);
        
        removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }
    
    private function drawHeatMap(event : MapEvent = null) : Void
    {
        if (!dirty) {
            return;
        }
        
        drawCoord = map.grid.centerCoordinate.copy();
        
        this.x = map.getWidth() / 2;
        this.y = map.getHeight() / 2;
        
        scaleX = scaleY = 1.0;
        
        // Just don't draw the heatMap if we have no data
        if (locations == null || locations.length == 0) 
        {
            if (heatBitmapData != null) 
                heatBitmapData.dispose();
            return;
        }
        
        itemRadius = Math.pow(2, map.getZoom() - nativeZoom) * nativeRadius;
        
        var cellSize : Int = itemRadius * 2;
        var m : Matrix = new Matrix();
        m.createGradientBox(cellSize, cellSize, 0, -itemRadius, -itemRadius);
        
        // Create the sphere of influence: A circle with a gradient that moves
        // from blue to black as you move from the inside of the circle out.
        var heatMapShape : Shape = new Shape();
        heatMapShape.graphics.clear();
        heatMapShape.graphics.beginGradientFill(GradientType.RADIAL, [centerValue, 0], [1, 1], [0, 255], m);
        heatMapShape.graphics.drawCircle(0, 0, itemRadius);
        heatMapShape.graphics.endFill();
        
        // Bitmap.draw is fastest when the first argument is a BitmapData,
        // so draw the shape to a BitmapData to save time later.
        var heatMapItem : BitmapData = new BitmapData(heatMapShape.width, heatMapShape.height, true, 0x00000000);
        var translationMatrix : Matrix = new Matrix();
        translationMatrix.tx = itemRadius;
        translationMatrix.ty = itemRadius;
        heatMapItem.draw(heatMapShape, translationMatrix);
        
        var w : Float = Math.min(2880, 2 * map.getWidth());
        var h : Float = Math.min(2880, 2 * map.getHeight());
        
        // If there is an existing heatBitmapData we have to clear it.
        // Using fillRect for this is faster than creating a new BitmapData, so only use new
        // when needed (width or height has changed or heatBitmapData does not exist)
        if (heatBitmapData == null || heatBitmapData.width != w || heatBitmapData.height != h) {
            if (heatBitmapData != null) {
                heatBitmapData.dispose();
            }
            heatBitmapData = new BitmapData(w, h, true, 0x00000000);
            bitmap.bitmapData = heatBitmapData;
            bitmap.x = -w / 2;
            bitmap.y = -h / 2;
        }
        else {
            heatBitmapData.fillRect(new Rectangle(0, 0, heatBitmapData.width, heatBitmapData.height), 0x00000000);
        }
        
        heatBitmapData.lock();
        
        // Draw a heatMapItem to the BitmapData for each point. Use the screen blend mode
        // to create the effect of overlapping heatMapItems influencing each other.
        for (coord in coordinates)
        {
            var p : Point = map.grid.coordinatePoint(coord, bitmap);
            if (p.x > 0 && p.x < w && p.y > 0 && p.y < h) {
                translationMatrix.tx = p.x - itemRadius;
                translationMatrix.ty = p.y - itemRadius;
                heatBitmapData.draw(heatMapItem, translationMatrix, null, BlendMode.SCREEN);
            }
        }
        heatMapItem.dispose();
        
        // paletteMap leaves some artifacts unless we get rid of the blackest colors
        heatBitmapData.threshold(heatBitmapData, heatBitmapData.rect, POINT, "<=", 0x00000003, 0x00000000, 0x000000FF, true);
        
        // Replace the black and blue with the gradient. Blacker pixels will get their new colors from
        // the beginning of the gradientArray and bluer pixels will get their new colors from the end.
        heatBitmapData.paletteMap(heatBitmapData, heatBitmapData.rect, POINT, null, null, gradientArray, null);
        
        // This blur filter makes the heat map looks quite smooth.
        heatBitmapData.applyFilter(heatBitmapData, heatBitmapData.rect, POINT, new BlurFilter(4, 4));
        
        heatBitmapData.unlock();
        
        dirty = false;
    }
    
    ///// Events....
    
    private function onMapExtentChanged(event : MapEvent) : Void
    {
        dirty = true;
    }
    
    private function onMapPanned(event : MapEvent) : Void
    {
        if (drawCoord != null) {
            var p : Point = map.grid.coordinatePoint(drawCoord);
            this.x = p.x;
            this.y = p.y;
        }
        else {
            dirty = true;
        }
    }
    
    private function onMapZoomedBy(event : MapEvent) : Void
    {
        cacheAsBitmap = false;
        if (drawCoord != null) {
            if (Math.abs(map.grid.zoomLevel - drawCoord.zoom) < zoomTolerance) {
                scaleX = scaleY = Math.pow(2, map.grid.zoomLevel - drawCoord.zoom);
            }
            else {
                dirty = true;
            }
        }
        else {
            dirty = true;
        }
    }
    
    private function onMapStartPanning(event : MapEvent) : Void
    {
        // optimistically, we set this to true in case we're just moving
        cacheAsBitmap = true;
    }
    
    private function onMapStartZooming(event : MapEvent) : Void
    {
        // overrule onMapStartPanning if there's scaling involved
        cacheAsBitmap = false;
    }
    
    private function onMapStopPanning(event : MapEvent) : Void
    {
        // tidy up
        cacheAsBitmap = false;
        dirty = true;
    }
    
    private function onMapStopZooming(event : MapEvent) : Void
    {
        dirty = true;
    }
    
    private function onMapResized(event : MapEvent) : Void
    {
        x = map.getWidth() / 2;
        y = map.getHeight() / 2;
        dirty = true;
        drawHeatMap();
    }
    
    
    private function onMapProviderChanged(event : MapEvent) : Void
    {
        var mapProvider : IMapProvider = map.getMapProvider();
        if (mapProvider.geometry() != previousGeometry) 
        {
            calculateCoordinates();
            previousGeometry = mapProvider.geometry();
        }
    }
    
    /** call this if you've made a change to the underlying map geometry such that
      * provider.locationCoordinate(location) will return a different coordinate */
    private function calculateCoordinates() : Void
    {
        var provider : IMapProvider = map.getMapProvider();
        // I wish Array.map didn't require three parameters!
        coordinates = [];
        for (location in locations){
            coordinates.push(provider.locationCoordinate(location));
        }
        dirty = true;
    }
    
    ///// Invalidations...
    
    private function set_Dirty(d : Bool) : Bool
    {
        _dirty = d;
        if (d) {
            if (stage)                 stage.invalidate();
        }
        return d;
    }
    
    private function get_Dirty() : Bool
    {
        return _dirty;
    }
}

