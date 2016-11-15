package com.modestmaps.overlays;


import openfl.events.Event;

/** used by PolygonClip to trigger a redraw when zoom levels have changed substantially */
interface Redrawable
{

    function redraw(event : Event = null) : Void;
}
