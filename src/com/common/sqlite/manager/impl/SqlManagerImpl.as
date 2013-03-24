package com.common.sqlite.manager.impl
{
	import com.common.sqlite.defin.SqlOperation;
	import com.common.sqlite.exception.NonUniqueResultException;
	import com.common.sqlite.helper.MappingHelper;
	import com.common.sqlite.manager.SqlManager;
	import com.common.sqlite.manager.SqlSelect;
	import com.common.sqlite.manager.SqlSequecer;
	import com.common.sqlite.manager.SqlUpdate;
	import com.common.sqlite.util.ObjectUtil;
	import com.common.util.LogUtil;

	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.filesystem.File;

	import mx.collections.ArrayCollection;
	import mx.logging.ILogger;

	public class SqlManagerImpl extends SqlSequecer implements SqlManager , SqlSelect , SqlUpdate
	{
		private var conn:SQLConnection = new SQLConnection();
		private var dbFile:File = null;

		private var selectSqlStatement:SQLStatement;
		private var updateSqlStatements:ArrayCollection = new ArrayCollection();
		private var clazz:Class;
		private var logger:ILogger;

		public function SqlManagerImpl( dbFile:File )
		{
			this.dbFile = dbFile;
			logger = LogUtil.getLogger( this );
		}

		private function openConnection( sqlMode:String ):void
		{
			try
			{
				conn.open( dbFile , sqlMode );
				logger.debug( "接続を開いています。" );
			}
			catch ( error:SQLError )
			{
				throw error;
			}
		}

		private function closeConnection():void
		{
			try
			{
				conn.close();
				logger.debug( "接続が閉じられます。" );
			}
			catch ( error:SQLError )
			{
				throw error;
			}
		}

		public function selectBySql( clazz:Class , sql:String , param:Array = null ):SqlSelect
		{
			return startSelectStatement( clazz , sql , param );
		}

		private function startSelectStatement( clazz:Class , sql:String , param:Array = null ):SqlSelect
		{
			this.openConnection( SQLMode.READ );
			selectSqlStatement = new SQLStatement();
			selectSqlStatement.text = sql;
			selectSqlStatement.sqlConnection = conn;
			setParameters( param , this.selectSqlStatement );
			this.clazz = clazz;
			return this;
		}

		private function startUpdateStatement( sqlList:Array , param:Array = null ):SqlUpdate
		{
			if ( !super.isTransaction )
			{
				this.openConnection( SQLMode.UPDATE );
			}

			this.updateSqlStatements.removeAll();

			for each ( var sql:String in sqlList )
			{
				var _sqlStatement:SQLStatement = new SQLStatement();
				_sqlStatement.sqlConnection = conn;
				_sqlStatement.text = sql;
				if ( param != null )
				{
					setParameters( param , _sqlStatement );
				}
				this.updateSqlStatements.addItem( _sqlStatement );
			}
			return this;
		}



		private function setParameters( param:Array , sqlStmt:SQLStatement ):void
		{
			if ( param == null )
			{
				return;
			}
			for ( var i:int = 0 ; i < param.length ; i++ )
			{
				sqlStmt.parameters[ i ] = param[ i ];
			}
		}

		private function select():Array
		{
			try
			{
				logger.debug( selectSqlStatement.text );
				selectSqlStatement.execute();
				var result:SQLResult = selectSqlStatement.getResult();
				if ( result.data == null )
				{
					return [];
				}

				if ( this.clazz == null )
				{
					return result.data;
				}
				return MappingHelper.typeArray( result.data , this.clazz );
			}
			catch ( error:SQLError )
			{
				throw error;
			}
			finally
			{
				this.closeConnection();
			}
			return new Array();
		}

		public function getResultList():Array
		{
			return this.select();
		}

		public function getSingleResult():*
		{
			var result:Array = this.select();
			if ( ObjectUtil.isEmpty( result ) )
			{
				return null;
			}
			if ( result.length > 1 )
			{
				throw new NonUniqueResultException();
				return;
			}
			return result[ 0 ];
		}

		public function getCountBySql( sql:String , param:Array = null ):Number
		{
			startSelectStatement( null , sql , param );
			return select().length;
		}

		private function executeSql( stmts:ArrayCollection ):void
		{
			try
			{
				this.conn.begin();
				if ( super.isTransaction )
				{
					logger.debug( "トランザクションを開始しました。" );
				}
				for each ( var stat:SQLStatement in stmts )
				{
					logger.debug( stat.text );
					stat.execute();
				}
				this.conn.commit();

				if ( super.isTransaction )
				{
					logger.debug( "トランザクションを終了しました。" );
				}
				afterProcess();

			}
			catch ( error:SQLError )
			{
				this.conn.rollback();
				if ( super.isTransaction )
				{
					logger.debug( "トランザクションをロールバックしました。" );
					logger.debug( "トランザクションを終了しました。" );
				}
				afterProcess();
				throw error;
			}
		}

		private function afterProcess():void
		{
			super.isTransaction = false;
			super.transactionStmt.removeAll();
			this.closeConnection();
		}

		public function execute():void
		{
			this.executeSql( this.updateSqlStatements );
		}

		public function insert( entity:Object ):SqlUpdate
		{
			return startUpdateStatement( MappingHelper.generateSql( [ entity ] , false , SqlOperation.INSERT ) );
		}

		public function insertByAutoId( entity:Object ):SqlUpdate
		{
			return startUpdateStatement( MappingHelper.generateSql( [ entity ] , true , SqlOperation.INSERT ) );
		}


		public function insertBatch( entities:Array ):SqlUpdate
		{
			return startUpdateStatement( MappingHelper.generateSql( entities , false , SqlOperation.INSERT ) );
		}

		public function insertBatchByAutoId( entities:Array ):SqlUpdate
		{
			return startUpdateStatement( MappingHelper.generateSql( entities , true , SqlOperation.INSERT ) );
		}

		public function deleteById( entity:Object ):SqlUpdate
		{
			return startUpdateStatement( MappingHelper.generateSql( [ entity ] , false , SqlOperation.DELETE ) );
		}

		public function deleteBatchById( entities:Array ):SqlUpdate
		{
			return startUpdateStatement( MappingHelper.generateSql( entities , false , SqlOperation.DELETE ) );
		}

		public function updateBySql( sql:String , param:Array = null ):SqlUpdate
		{
			return startUpdateStatement( [ sql ] , param );
		}

		public function updateById( entity:Object ):SqlUpdate
		{
			return startUpdateStatement( MappingHelper.generateSql( [ entity ] , false , SqlOperation.UPDATE ) );
		}

		public function updateBatchById( entities:Array ):SqlUpdate
		{
			return startUpdateStatement( MappingHelper.generateSql( entities , false , SqlOperation.UPDATE ) );
		}

		public function getSqlSequncer():SqlSequecer
		{
			super.isTransaction = true;
			return this;
		}


		override public function add( update:SqlUpdate ):void
		{
			for each ( var stmt:SQLStatement in this.updateSqlStatements )
			{
				super.transactionStmt.addItem( stmt );
			}
		}

		override public function commit():void
		{
			this.openConnection( SQLMode.UPDATE );
			this.executeSql( super.transactionStmt );
		}
	}
}