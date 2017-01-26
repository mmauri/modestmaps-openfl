package com.modestmaps.core.painter;

import com.modestmaps.core.Tile;
import com.modestmaps.core.painter.TilePool;
import haxe.ds.StringMap;


/** the alreadySeen Dictionary here will contain up to grid.maxTilesToKeep Tiles */
class TileCache
{
	public var size(get, never) : Int;

	// Tiles we've already seen and fully loaded, by key (.name)
	private var alreadySeen:StringMap<Tile>;
	private var tilePool : TilePool;  // for handing tiles back!

	public function new(tilePool : TilePool)
	{
		this.tilePool = tilePool;
		alreadySeen = new StringMap<Tile>();
	}

	private function get_size() : Int
	{
		var alreadySeenCount : Int = 0;

		for (key in alreadySeen)
		{
			alreadySeenCount++;
		}
		return alreadySeenCount;
	}

	public function putTile(tile : Tile) : Void
	{
		alreadySeen.set(tile.name,tile);
	}

	public function getTile(key : String) : Tile
	{
		return alreadySeen.get(key);
	}

	public function containsKey(key : String) : Bool
	{
		return alreadySeen.exists(key);
	}

	public function retainKeys(keys : Array<String>) : Void
	{
		// loop over our internal tile cache
		// and throw out tiles not in recentlySeen
		for (key in alreadySeen.keys())
		{
			if (keys.indexOf(key) < 0)
			{
				tilePool.returnTile(alreadySeen.get(key));
				alreadySeen.remove(key);
			}
		}
	}

	public function clear() : Void
	{
		for (key in alreadySeen.keys())
		{
			tilePool.returnTile(alreadySeen.get(key));
			alreadySeen.set(key, null);
			alreadySeen.remove(key);
		}
		alreadySeen = new StringMap<Tile>();
	}
}
