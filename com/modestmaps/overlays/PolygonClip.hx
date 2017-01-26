package com.modestmaps.overlays;

import com.modestmaps.Map;
import openfl.display.DisplayObject;
import openfl.geom.Rectangle;


/**
	 *  PolygonClip extends MarkerClip to take the bounds of the marker into account when showing/hiding,
	 *  and to trigger a redraw of content that needs scaling.
	 *
	 *  To trigger the redraw, markers must implement the Redrawable interface provided in this package.
	 *
	 *  See PolygonMarker for an example, but if you need multi-geometries, complex styling, holes etc.,
	 *  you'll need to write your own for the moment.
	 *
	 */
class PolygonClip extends MarkerClip
{
	public function new(map : Map)
	{
		super(map);
		this.scaleZoom = true;
		this.markerSortFunction = null;
	}

	override private function markerInBounds(marker : DisplayObject, w : Float, h : Float) : Bool
	{
		var rect : Rectangle = new Rectangle(-w, -h, w * 3, h * 3);
		return rect.intersects(marker.getBounds(map));
	}

	override public function updateClip(marker : DisplayObject) : Bool
	{
		// we need to redraw this marker before MarkerClip.updateClip so that markerInBounds will be correct
		if (Std.is(marker, Redrawable))
		{
			cast((marker), Redrawable).redraw();
		}
		return super.updateClip(marker);
	}
}
