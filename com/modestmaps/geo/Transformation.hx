/*
 * $Id$
 */

package com.modestmaps.geo;

import openfl.geom.Point;

class Transformation
{
	private var ax : Float;
	private var bx : Float;
	private var cx : Float;
	private var ay : Float;
	private var by : Float;
	private var cy : Float;

	/**
		 * equivalent to "new flash.geom.Matrix(ax,bx,ay,by,cy,cx)"
		 */
	public function new(ax : Float, bx : Float, cx : Float, ay : Float, by : Float, cy : Float)
	{
		this.ax = ax;
		this.bx = bx;
		this.cx = cx;
		this.ay = ay;
		this.by = by;
		this.cy = cy;
	}

	/**
	    * String signature of the current transformation.
	    */
	public function toString() : String
	{
		return "T([" + ax + "," + bx + "," + cx + "][" + ay + "," + by + "," + cy + "])";
	}

	/**
	    * Transform a point.
	    */
	public function transform(point : Point) : Point
	{
		return new Point(ax * point.x + bx * point.y + cx,
		ay * point.x + by * point.y + cy);
	}

	/**
	    * Inverse of transform; p = untransform(transform(p))
	    */
	public function untransform(point : Point) : Point
	{
		return new Point((point.x * by - point.y * bx - cx * by + cy * bx) / (ax * by - ay * bx),
		(point.x * ay - point.y * ax - cx * ay + cy * ax) / (bx * ay - by * ax));
	}
}
