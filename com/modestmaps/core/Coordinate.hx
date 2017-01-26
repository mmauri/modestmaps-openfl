/*
 * $Id$
 */

package com.modestmaps.core;

class Coordinate
{
	public var row : Float;
	public var column : Float;
	public var zoom : Float;

	public function new(row : Float, column : Float, zoom : Float)
	{
		this.row = row;
		this.column = column;
		this.zoom = zoom;
	}

	public function toString() : String
	{
		return "(" + row + "," + column + " @" + zoom + ")";
	}

	public function copy() : Coordinate
	{
		return new Coordinate(row, column, zoom);
	}

	/**
	    * Return a new coordinate that corresponds to that of the tile containing this one
	    */
	public function container() : Coordinate
	{
		return new Coordinate(Math.floor(row), Math.floor(column), zoom);
	}

	public function zoomTo(destination : Float) : Coordinate
	{
		return new Coordinate(row * Math.pow(2, destination - zoom),
		column * Math.pow(2, destination - zoom),
		destination);
	}

	public function zoomBy(distance : Float) : Coordinate
	{
		return new Coordinate(row * Math.pow(2, distance),
		column * Math.pow(2, distance),
		zoom + distance);
	}

	public function isRowEdge() : Bool
	{
		return Math.round(row) == row;
	}

	public function isColumnEdge() : Bool
	{
		return Math.round(column) == column;
	}

	public function isEdge() : Bool
	{
		return isRowEdge() && isColumnEdge();
	}

	public function up(distance : Float = 1) : Coordinate
	{
		return new Coordinate(row - distance, column, zoom);
	}

	public function right(distance : Float = 1) : Coordinate
	{
		return new Coordinate(row, column + distance, zoom);
	}

	public function down(distance : Float = 1) : Coordinate
	{
		return new Coordinate(row + distance, column, zoom);
	}

	public function left(distance : Float = 1) : Coordinate
	{
		return new Coordinate(row, column - distance, zoom);
	}

	/**
	     * Returns true if the the two coordinates refer to the same Tile location.
	     */
	public function equalTo(coord : Coordinate) : Bool
	{
		return (coord !=null && coord.row == this.row && coord.column == this.column && coord.zoom == this.zoom);
	}
}
