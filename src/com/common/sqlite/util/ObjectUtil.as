package com.common.sqlite.util
{
	import mx.utils.ObjectUtil;

	public class ObjectUtil
	{
		public function ObjectUtil()
		{
		}

		public static function isEmpty( array:Array ):Boolean
		{
			if ( array == null || array.length == 0 || ( array.length == 1 && array[ 0 ] == null ) )
			{
				return true;
			}
			return false;
		}

		public static function getClassInfo( obj:Object , excludes:Array = null , options:Object = null ):Object
		{
			return mx.utils.ObjectUtil.getClassInfo( obj , excludes , options );
		}

	}
}