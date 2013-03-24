package com.common.sqlite.helper
{
	import com.common.sqlite.bean.Table;
	import com.common.sqlite.defin.Annotation;
	import com.common.sqlite.defin.ErrorMessage;
	import com.common.sqlite.defin.SqlOperation;
	import com.common.sqlite.exception.AnnotationException;
	import com.common.sqlite.util.ObjectUtil;

	import flash.utils.describeType;

	import mx.collections.ArrayCollection;

	public class MappingHelper
	{
		public static function generateSql( entities:Array , autoId:Boolean , operation:String ):Array
		{
			switch ( operation )
			{
				case SqlOperation.INSERT:
					return generateInsertSql( entities , autoId );
				case SqlOperation.DELETE:
					return generateDeleteByIdSql( entities );
				case SqlOperation.UPDATE:
					return generateUpdateByIdSql( entities );
			}
			return new Array();
		}

		public static function generateSelectEntitySql( clazz:Class ):String
		{
			var table:Table = getMapping( new clazz() );

			if ( table.id == null || table.id.length == 0 )
			{
				throw new AnnotationException( ErrorMessage.NO_ID_DEFINATION_FOUND_ERROR );
			}


			var sql:String = "select ";
			var column:String;

			var mapping:Array = table.id.toArray().concat( table.column.toArray() );


			for ( var j:int = 0 ; j < mapping.length ; j++ )
			{
				var item:Object = mapping[ j ];
				sql += item.column ;
				if ( j < ( mapping.length - 1 ) )
				{
					sql += " , ";
				}
			}
			return sql + " from " + table.name;
		}

		/**
		 *更新用sqlの作成
		 * @param entities
		 * @return
		 *
		 */
		private static function generateUpdateByIdSql( entities:Array ):Array
		{
			if ( ObjectUtil.isEmpty( entities ) )
			{
				return [];
			}

			var sqlList:Array = new Array();
			var table:Table = getMapping( entities[ 0 ] );

			if ( table.id == null || table.id.length == 0 )
			{
				throw new AnnotationException( ErrorMessage.NO_ID_DEFINATION_FOUND_ERROR );
			}

			for each ( var entity:Object in entities )
			{

				var sql:String = "update  " + table.name + " set ";

				var column:String;
				var value:Object;

				//更新内容
				for ( var i:int = 0 ; i < table.column.length ; i++ )
				{
					var item:Object = table.column.getItemAt( i );

					column = item.column;
					value = getDecorateValue( item.type , entity[ item.field ] );
					if ( i != 0 )
					{
						sql += " , ";
					}

					sql += column + " = " + value + " ";
				}

				//更新条件
				sql += " where "
				for ( var j:int = 0 ; j < table.id.length ; j++ )
				{
					var id:Object = table.id.getItemAt( j );

					column = id.column;
					value = getDecorateValue( item.type , entity[ id.field ] );
					if ( j != 0 )
					{
						sql += " and ";
					}

					sql += column + " = " + value + " ";
				}

				sqlList.push( sql );
			}
			return sqlList;
		}

		/**
		 *削除用sqlの作成
		 * @param entities
		 * @return
		 *
		 */
		private static function generateDeleteByIdSql( entities:Array ):Array
		{
			if ( ObjectUtil.isEmpty( entities ) )
			{
				return [];
			}

			var sqlList:Array = new Array();
			var table:Table = getMapping( entities[ 0 ] );

			if ( table.id == null || table.id.length == 0 )
			{
				throw new AnnotationException( ErrorMessage.NO_ID_DEFINATION_FOUND_ERROR );
			}

			for each ( var entity:Object in entities )
			{

				var sql:String = "delete from " + table.name + " where ";
				var column:String;
				var value:Object;

				for ( var j:int = 0 ; j < table.id.length ; j++ )
				{
					var item:Object = table.id.getItemAt( j );

					column = item.column;
					value = getDecorateValue( item.type , entity[ item.field ] );
					if ( j != 0 )
					{
						sql += " and ";
					}

					sql += column + " = " + value + " ";
				}

				sqlList.push( sql );
			}
			return sqlList;
		}

		/**
		 *insert用sqlの作成
		 * @param entities
		 * @param autoId
		 * @return
		 *
		 */
		private static function generateInsertSql( entities:Array , autoId:Boolean ):Array
		{
			if ( ObjectUtil.isEmpty( entities ) )
			{
				return [];
			}

			var sqlList:Array = new Array();
			var table:Table = getMapping( entities[ 0 ] );

			var mapping:Array = table.column.toArray();
			if ( !autoId )
			{
				mapping = table.column.toArray().concat( table.id.toArray() );
			}

			for each ( var entity:Object in entities )
			{

				var sql:String = "insert into ";
				var columns:String = "";
				var values:String = "";

				for ( var j:int = 0 ; j < mapping.length ; j++ )
				{
					var item:Object = mapping[ j ];

					columns += item.column;
					values += getDecorateValue( item.type , entity[ item.field ] );

					if ( j < ( mapping.length - 1 ) )
					{
						columns += ",";
						values += ",";
					}
				}
				sql += table.name + " ( " + columns + " ) values ( " + values + " )"
				sqlList.push( sql );
			}
			return sqlList;
		}

		/**
		 *エンティティとテーブルのマッピング関係を取得する
		 * @param entity
		 * @return
		 *
		 */
		private static function getMapping( entity:Object , isValidate:Boolean = true ):Table
		{
			var table:Table = new Table();
			var idMapping:ArrayCollection = new ArrayCollection();
			var columnMapping:ArrayCollection = new ArrayCollection();

			var xml:XML = describeType( entity );
			table.name = xml.metadata.( @name == Annotation.TABLE ).arg.( @key == Annotation.NAME ).@value;
			if ( isValidate )
			{
				if ( table.name == null || table.name == "" )
				{
					throw new AnnotationException( ErrorMessage.NO_TABLE_DEFINATION_FOUND_ERROR );
				}
			}

			var variables:XMLList = xml.variable;

			var field:String;
			var column:String;
			var type:String;

			for ( var i:int = 0 ; i < variables.length() ; i++ )
			{
				if ( variables[ i ].metadata.( @name == Annotation.TRANSIENT ).length() > 0 )
				{
					continue;
				}

				field = variables[ i ].@name.toString();
				type = variables[ i ].@type.toString();

				if ( variables[ i ].metadata.( @name == Annotation.ID ).length() > 0 )
				{
					if ( variables[ i ].metadata.( @name == Annotation.COLUMN ).length() > 0 )
					{
						column = variables[ i ].metadata.( @name == Annotation.COLUMN ).arg.( @key == Annotation.NAME ).@value.toString();
					}
					else
					{
						column = field;
					}
					//db上のコラム名は全部小文字する
					idMapping.addItem( { field: field , column: column.toLowerCase() , type: type } );
				}
				else
				{

					if ( variables[ i ].metadata.( @name == Annotation.COLUMN ).length() > 0 )
					{
						column = variables[ i ].metadata.( @name == Annotation.COLUMN ).arg.( @key == Annotation.NAME ).@value.toString();
					}
					else
					{
						column = field;
					}
					//db上のコラム名は全部小文字する
					columnMapping.addItem( { field: field , column: column.toLowerCase() , type: type } );
				}

			}
			table.column = columnMapping;
			table.id = idMapping;
			return table;
		}

		public static function typeArray( a:Array , clazz:Class ):Array
		{
			if ( ObjectUtil.isEmpty( a ) )
			{
				return [];
			}
			var result:Array = new Array();

			var table:Table = getMapping( new clazz() , false );
			var mapping:Array = table.id.toArray().concat( table.column.toArray() );

			for ( var i:int = 0 ; i < a.length ; i++ )
			{
				result.push( typeObject( a[ i ] , clazz , mapping ) );
			}
			return result;
		}

		private static function typeObject( o:Object , clazz:Class , mapping:Array ):Object
		{
			var instance:Object = new clazz();

			var classInfoProperties:Array = ObjectUtil.getClassInfo( o ).properties as Array;
			var _o:Object = new Object();
			for each ( var p:QName in classInfoProperties )
			{
				_o[ p.toString().toLowerCase() ] = o[ p.localName ];
			}
			for ( var i:int ; i < mapping.length ; i++ )
			{
				var item:Object = mapping[ i ];
				instance[ item.field ] = _o[ item.column ];
			}
			return instance;
		}

		/**
		 * コラムのタイプにより、sql用のvalueを作成する
		 * 例:タイプはString の場合、[xxx]⇒['xxx']のように変更する
		 * @param type
		 * @param value
		 * @return
		 *
		 */
		private static function getDecorateValue( type:String , value:Object ):Object
		{
			if ( "String" == type )
			{
				return "'" + value + "'";
			}
			return value;
		}
	}
}