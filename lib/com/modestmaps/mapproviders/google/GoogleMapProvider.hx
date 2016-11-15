package com.modestmaps.mapproviders.google;


import com.modestmaps.core.Coordinate;
import com.modestmaps.core.painter.GoogleTilePainter;
import com.modestmaps.core.painter.ITilePainter;
import com.modestmaps.core.painter.ITilePainterOverride;
import com.modestmaps.mapproviders.AbstractMapProvider;
import com.modestmaps.mapproviders.IMapProvider;

class GoogleMapProvider extends AbstractMapProvider implements IMapProvider implements ITilePainterOverride
{
    private var tilePainter : GoogleTilePainter;
    
    public function new(tilePainter : GoogleTilePainter)
    {
        super();
        this.tilePainter = tilePainter;
    }
    
    public function getTilePainter() : ITilePainter
    {
        return tilePainter;
    }
    
    public function toString() : String
    {
        return Std.string(tilePainter);
    }
    
    public function getTileUrls(coord : Coordinate) : Array<Dynamic>
    {
        return [];
    }
}
