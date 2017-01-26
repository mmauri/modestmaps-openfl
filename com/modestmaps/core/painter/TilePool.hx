package com.modestmaps.core.painter;

//import com.modestmaps.core.painter.TileClass;

import com.modestmaps.core.Tile;
import com.modestmaps.core.TweenTile;

/**
	 *  This post http://lab.polygonal.de/2008/06/18/using-object-pools/
	 *  suggests that using Object pools, especially for complex classes like Sprite
	 *  is a lot faster than calling new Object().  The suggested implementation
	 *  uses a linked list, but to get started with it here I'm using an Array.
	 *
	 *  If anyone wants to try it with a linked list and compare the times,
	 *  it seems like it could be worth it :)
	 */
class TilePool
{
	private static inline var MIN_POOL_SIZE : Int = 256;
	private static inline var MAX_NEW_TILES : Int = 256;

	private var pool : Array<Tile> = [];
	private var isTweenTile : Bool;

	public function new()
	{
		//let's make the TweenTile bu default.
		this.isTweenTile = true;
	}

	public function setTileClass(isTweenTile: Bool) : Void
	{
		this.isTweenTile = isTweenTile;
		pool = [];
	}

	public function getTile(column : Int, row : Int, zoom : Int) : Tile
	{
		if (pool.length < MIN_POOL_SIZE)
		{
			if (isTweenTile)
			{
				while (pool.length < MAX_NEW_TILES)
				{
					pool.push(new TweenTile(0,0,0));
				}
			}
			else
			{
				while (pool.length < MAX_NEW_TILES)
				{
					pool.push(new Tile(0,0,0));
				}
			}
		}
		var tile : Tile = pool.pop();
		tile.init(column, row, zoom);
		return tile;
	}

	public function returnTile(tile : Tile) : Void
	{
		tile.destroy();
		pool.push(tile);
	}
}
