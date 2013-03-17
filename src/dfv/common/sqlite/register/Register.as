package dfv.common.sqlite.register
{
	import dfv.common.sqlite.manager.SqlManager;
	import dfv.common.sqlite.manager.impl.SqlManagerImpl;
	import dfv.common.util.LogUtil;

	import flash.filesystem.File;

	import mx.logging.ILogger;


	public class Register
	{
		/**
		 * 自分自身の唯一のインスタンス
		 */
		private static var _instance :Register = null;
		private var _dbFile:File;
		private var register:Array = new Array();
		private var logger:ILogger;

		/**
		 * コンストラクタです。
		 * Singletonにするため、内部のダミーのプライベートクラスのインスタンスを引数にとります。
		 */
		public function Register()
		{
			//ダミーのプライベートクラスのインスタンスがnullの場合
			//(外部のクラスからもnullを引数に指定すれば呼び出すことができるので、それを防止するためにチェック)
			if ( _instance != null )
			{
				//例外を投げる
				throw new Error("このクラスはSingletonです。newではなくgetInstance()でインスタンスを取得して下さい。");
			}
			logger = LogUtil.getLogger(this);
		}
		/**
		 * このクラスの唯一のインスタンスを取得します。
		 *
		 * @return このクラスの唯一のインスタンス
		 */
		public static function getInstance() :Register
		{
			//まだインスタンスが生成されていない場合
			if(_instance == null)
			{
				//自分自身のクラスのインスタンスを生成
				_instance = new Register()
			}

			//自分自身の唯一のインスタンスを返す
			return _instance;
		}
		public function init(dbFile:File) :void {
			this._dbFile = dbFile;
		}

		public function getSqlManagerByKey(key:String = "main"):SqlManager
		{
			var sqlManager:SqlManager = register[key] as SqlManager;
			return sqlManager;
		}

		public function getSqlManager(file:File=null, key:String = "main"):SqlManager
		{
			if (file == null) {
				file = _dbFile;
			}
			var sqlManager:SqlManager = register[key] as SqlManager;

			if (sqlManager == null && file != null)
			{
				sqlManager = new SqlManagerImpl(file);
				register[key] = sqlManager;
			}
			return sqlManager;
		}
	}
}
