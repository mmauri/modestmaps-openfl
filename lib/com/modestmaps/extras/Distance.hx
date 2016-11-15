package com.modestmaps.extras;


import com.modestmaps.geo.Location;

class Distance
{
    public static inline var R_MILES : Float = 3963.1;
    public static inline var R_NAUTICAL_MILES : Float = 3443.9;
    public static inline var R_KM : Float = 6378;
    public static inline var R_METERS : Float = 6378000;
    
    /** 
     * <p>you can specify different units by optionally providing the 
     * earth's radius in the units you desire</p>
     * 
     * <p>Default is 6,378,000 metres, suggested values are:</p>
     * <ul>
     *   <li>3963.1 statute miles</li>
     *   <li>3443.9 nautical miles</li>
     *   <li>6378 km</li>
     * </ul>
     * 
     * @return distance between given start and end locations in metres
     * 
     * @see http://jan.ucc.nau.edu/~cvm/latlon_formula.html 
     * */
    public static function approxDistance(start : Location, end : Location, r : Float = R_METERS) : Float
    {
        
        var a1 : Float = radians(start.lat);
        var b1 : Float = radians(start.lon);
        var a2 : Float = radians(end.lat);
        var b2 : Float = radians(end.lon);
        
        var d : Float;
        with(Math);{
            d = acos(cos(a1) * cos(b1) * cos(a2) * cos(b2) + cos(a1) * sin(b1) * cos(a2) * sin(b2) + sin(a1) * sin(a2)) * r;
        }
        return d;
    }
    
    private static function radians(degrees : Float) : Float
    {
        return degrees * Math.PI / 180.0;
    }

    public function new()
    {
    }
}
