package com.common.sqlite.exception
{
	public class AbstractServiceException extends Error
	{
		public function AbstractServiceException( message:String = "AbstractServiceExceptionでentityクラスの定義が見つかりませんでした。" , id:int = 0 )
		{
			super(message, id);
		}

	}
}