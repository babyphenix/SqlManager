package dfv.common.sqlite.exception
{
	public class AnnotationException extends Error
	{
		public function AnnotationException(message:String="アノテーション定義エラー。", id:int=0)
		{
			super(message, id);
		}

	}
}