package dfv.common.sqlite.manager
/**
*トランザクション用のsqlシーケンス
*/
{
	import mx.collections.ArrayCollection;

	public class SqlSequecer
	{
		protected var transactionStmt:ArrayCollection = new ArrayCollection();

		protected var isTransaction:Boolean = false;

		public function add(update:SqlUpdate):void{}

		public function commit():void{}
	}
}