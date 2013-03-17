package dfv.common.sqlite.exception
{
	public class NonUniqueResultException extends Error
	{
		public function NonUniqueResultException(message:String="ユニークな結果を返しませんでした。", id:int=0)
		{
			super(message, id);
		}

	}
}