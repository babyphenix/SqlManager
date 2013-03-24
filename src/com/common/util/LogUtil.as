package com.common.util
{
	import flash.utils.getQualifiedClassName;

	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.targets.TraceTarget;
	import mx.logging.LogEventLevel;

	public class LogUtil
	{
		public static function getLogger( obj:Object ):ILogger
		{
			var nameParts : Array = getQualifiedClassName( obj ).split("::");
			var className : String = nameParts[ nameParts.length - 1 ];
			return Log.getLogger( className ); 
		}
	}
}