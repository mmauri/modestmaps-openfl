package com.modestmaps.mapproviders.microsoft;


/**
	 * @author darren
	 * $Id$
	 */
class MicrosoftRoadMapProvider extends MicrosoftProvider
{
    public function new(hillShading : Bool = true, minZoom : Int = AbstractMapProvider.MIN_ZOOM, maxZoom : Int = AbstractMapProvider.MAX_ZOOM)
    {
        super(MicrosoftProvider.ROAD, hillShading, minZoom, maxZoom);
    }
}

