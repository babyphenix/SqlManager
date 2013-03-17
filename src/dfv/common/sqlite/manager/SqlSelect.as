package dfv.common.sqlite.manager
{
	public interface SqlSelect
	{

		function getResultList():Array;
		function getSingleResult():*;
	}
}