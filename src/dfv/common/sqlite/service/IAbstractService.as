package dfv.common.sqlite.service
{
	import dfv.common.sqlite.exception.AbstractServiceException;
	import dfv.common.sqlite.helper.MappingHelper;
	import dfv.common.sqlite.manager.SqlManager;
	import flash.errors.SQLError;

	public class IAbstractService
	{
		private var _sqlManager:SqlManager;
		private var _clazz:Class;

		public function IAbstractService(  sqlManager:SqlManager,clazz:Class=null )
		{
			_clazz = clazz;
			_sqlManager = sqlManager;
		}

		public function get sqlManager():SqlManager
		{
			return _sqlManager;
		}

		public function set sqlManager( sqlManager:SqlManager ):void
		{
			this._sqlManager = sqlManager;
		}

		/**
		 *　識別子により、エンティティを削除する<br>
		 * 複合主キーによりの削除が可能
		 * @param entity
		 * @return
		 */
		public function deleteById( entity:Object ):void
		{
			if ( _clazz == null )
			{
				throw new AbstractServiceException();
			}
			try
			{
				_sqlManager.deleteById( entity ).execute();
			}
			catch ( err:SQLError )
			{
				throw err;
			}
		}

		public function findAll():Array
		{
			if ( _clazz == null )
			{
				throw new AbstractServiceException();
			}
			return _sqlManager.selectBySql( _clazz , MappingHelper.generateSelectEntitySql( _clazz ) ).getResultList();
		}

		public function getCount():Number
		{
			if ( _clazz == null )
			{
				throw new AbstractServiceException();
			}
			return _sqlManager.getCountBySql( MappingHelper.generateSelectEntitySql( _clazz ) );
		}

		/**
		 *自動挿入を作成します。
		 * @param entity 挿入するエンティティの型です。
		 * @return
		 *
		 */
		public function insert( entity:Object ):void
		{
			if ( _clazz == null )
			{
				throw new AbstractServiceException();
			}
			try
			{
				_sqlManager.insert( entity ).execute();
			}
			catch ( err:SQLError )
			{
				throw err;
			}
		}

		/**
		 * Idをdbで自動的に作成して、自動挿入を作成します。
		 * @param entity
		 * @return
		 *
		 */
		public function insertByAutoId( entity:Object ):void
		{
			if ( _clazz == null )
			{
				throw new AbstractServiceException();
			}
			try
			{
				_sqlManager.insertByAutoId( entity ).execute();
			}
			catch ( err:SQLError )
			{
				throw err;
			}
		}

		/**
		 *　識別子により、エンティティを更新する<br>
		 * 複合主キーによりの更新が可能
		 * @param entity
		 * @return
		 *
		 */
		public function update( entity:Object ):void
		{
			if ( _clazz == null )
			{
				throw new AbstractServiceException();
			}
			try
			{
				_sqlManager.updateById( entity ).execute();
			}
			catch ( err:SQLError )
			{
				throw err;
			}
		}
	}
}