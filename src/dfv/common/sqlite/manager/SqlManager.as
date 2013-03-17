package dfv.common.sqlite.manager
{
	import flash.filesystem.File;


	public interface SqlManager
	{
		/**
		 * SQL検索を作成します。
		 * @param clazz 戻り値のベースの型です
		 * @param sql SQL
		 * @param param パラメータの配列
		 * @return  SQL検索
		 *
		 */
		function selectBySql( clazz:Class , sql:String , param:Array = null ):SqlSelect;

		/**
		 *実行可能なSQLが返す結果セットの行数を返します。
		 * @param sql SQL
		 * @param param パラメータの配列
		 * @return SQLが返す結果セットの行数
		 *
		 */
		function getCountBySql( sql:String , param:Array = null ):Number;

		/**
		 *自動挿入を作成します。
		 * @param entity 挿入するエンティティの型です。
		 * @return
		 *
		 */
		function insert( entity:Object ):SqlUpdate;

		/**
		 * Idをdbで自動的に作成して、自動挿入を作成します。
		 * @param entity
		 * @return
		 *
		 */
		function insertByAutoId( entity:Object ):SqlUpdate;

		/**
		 *自動バッチ挿入を作成します。
		 * @param entities
		 * @return
		 *
		 */
		function insertBatch( entities:Array ):SqlUpdate;

		/**
		 *Idをdbで自動的に作成して、自動バッチ挿入を作成します。
		 * @param entities
		 * @return
		 *
		 */
		function insertBatchByAutoId( entities:Array ):SqlUpdate;

		/**
		 *　識別子により、エンティティを削除する<br>
		 * 複合主キーによりの削除が可能
		 * @param entity
		 * @return
		 *
		 */
		function deleteById( entity:Object ):SqlUpdate;

		/**
		 *　識別子により、複数のエンティティを削除する<br>
		 * 複合主キーによりの削除が可能
		 * @param entities
		 * @return
		 *
		 */
		function deleteBatchById( entities:Array ):SqlUpdate;

		/**
		 *sqlによりのDB更新処理
		 * @param sql
		 * @param param
		 * @return
		 *
		 */
		function updateBySql( sql:String , param:Array = null ):SqlUpdate;

		/**
		 *　識別子により、エンティティを更新する<br>
		 * 複合主キーによりの更新が可能
		 * @param entity
		 * @return
		 *
		 */
		function updateById( entity:Object ):SqlUpdate;

		/**
		 *　識別子により、複数のエンティティを更新する<br>
		 * 複合主キーによりの更新が可能
		 * @param entities
		 * @return
		 *
		 */
		function updateBatchById( entities:Array ):SqlUpdate;

		/**
		 *トランザクション用のsqlシーケンスを取得する
		 * @return SqlSequecer
		 *
		 */
		function getSqlSequncer():SqlSequecer;
	}
}