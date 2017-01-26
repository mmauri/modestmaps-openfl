/**
 * @author darren
 * $Id$
 */
package com.modestmaps.util;


class BinaryUtil
{
	private static var PADDING:String = "00000000000000000000000000000000";

	/**
	 * NB:- don't use int.toString(2) here because it
	 * doesn't do what we want with negative numbers - which is
	 * wrap around and pad with 1's. Hence convert to uint first.
	 *
	 * @param numberToConvert
	 * @return 32 digit binary representation (eg : 1011)
	 */
	public static function convertToBinary(numberToConvert:Int):String
	{
		var result:String = decimalToBinary(numberToConvert);
		if (result.length < 32)
		{
			result = PADDING.substr(result.length) + result;
		}
		return result;
	}

	/**
	 *
	 * @param	binaryRepresentation : binary string representation (eg : 1011)
	 * @return
	 */
	public static function convertToDecimal(binaryRepresentation:String):Int
	{
		var result:Int = binaryToDecimal(binaryRepresentation);
		return result;
	}

	/**
	 *
	 * @param	decimalValue
	 * @return
	 */
	private static function decimalToBinary(decimalValue:Int):String
	{
		var stringBinary:Dynamic = decimalValue;
		var result:String = stringBinary.toString();
		return result;
	}

	/**
	 *
	 * @param	binaryRepresentation
	 * @return
	 */
	private static function binaryToDecimal(binaryRepresentation:String):Int
	{
		var result : Float = 0;
		for (i in 0 ... binaryRepresentation.length)
		{
			if (binaryRepresentation.charAt(i) == '1')
			{
				result = result + Math.pow(2, binaryRepresentation.length - 1 - i);
			}
		}
		return Std.int(result);
	}

	/**
	 *
	 * @param	binaryRepresentation
	 * @return
	 */
	private static function binaryToHexadecimal(binaryRepresentation:String):String
	{
		var binaryToIntRepresentation : Int = binaryToDecimal(binaryRepresentation);
		return '0x' + StringTools.hex(binaryToIntRepresentation);
	}

}