
package com.modestmaps.mapproviders.microsoft;

import com.modestmaps.mapproviders.microsoft.MicrosoftProvider;

/**
	 * @author darren
	 * $Id$
	 */
class MicrosoftAerialMapProvider extends MicrosoftProvider
{
    public function new(minZoom : Int = AbstractMapProvider.MIN_ZOOM, maxZoom : Int = AbstractMapProvider.MAX_ZOOM)
    {
        super(MicrosoftProvider.AERIAL, true, minZoom, maxZoom);
    }
}
