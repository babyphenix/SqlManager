package com.common.sqlite.bean
{
	import mx.collections.ArrayCollection;

	public class Table
	{
		public function Table()
		{
		}
		/**
		 * テーブル名を格納する
		 */
		public var name:String;
		/**
		 * IDマッピングを格納する
		 */
		public var id:ArrayCollection;
		/**
		 * ID以外のコラムマッピングを格納する
		 */
		public var column:ArrayCollection;

	}
}