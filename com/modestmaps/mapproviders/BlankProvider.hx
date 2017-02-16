package com.modestmaps.mapproviders;
import com.modestmaps.core.Coordinate;

class BlankProvider extends AbstractMapProvider implements IMapProvider
{
    public function getTileUrls(coord : Coordinate) : Array<String>
    {
        return [];
    }
    
    public function toString() : String
    {
        return "BLANK_PROVIDER";
    }
    
    override private function get_tileWidth() : Float
    {
        return 32;
    }
    
    override private function get_tileHeight() : Float
    {
        return 32;
    }

    public function new()
    {
        super();
    }
}
