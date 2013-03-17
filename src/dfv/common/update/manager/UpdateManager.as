package dfv.common.update.manager
{
    import air.update.ApplicationUpdater;
    import air.update.ApplicationUpdaterUI;
    import air.update.events.StatusUpdateEvent;
    import air.update.events.UpdateEvent;
    
    import flash.filesystem.File;
    
    import mx.core.UIComponent;
    
    public class UpdateManager extends UIComponent
    {
    	private var appUpdater:ApplicationUpdater;
        private var appUpdaterUI:ApplicationUpdaterUI;
        
        [Bindable]
        public var available:Boolean = false;
        
        [Bindable]
        public var currentVersion:String;
        [Bindable]
        public var serverVersion:String;
        
		/** instance */
		private static var instance:UpdateManager;
		
		/**
		 * private constructor
		 */
		public function UpdateManager()
		{
			if (instance == null)
			{
				super();
			}
			else
			{
				throw new Error( "Private constructor. Use getInstance() instead." );
			}
		}
		
		/**
		 * getInstance
		 */
		public static function getInstance():UpdateManager
		{
			if (instance == null)
			{
				instance = new UpdateManager();
			}
			return instance;
		}
        
        /**
         * アプリケーションのアップデートを実行する.
         */
        public function update():void
		{
        	appUpdaterUI = new ApplicationUpdaterUI();
            appUpdaterUI.configurationFile = new File("app:/update.xml");
            appUpdaterUI.addEventListener(UpdateEvent.INITIALIZED,
            		function (event:UpdateEvent):void
            		{
            			appUpdaterUI.checkNow();
            		}
            );
			appUpdaterUI.initialize();
		}
        
        /**
         * アップデート可能かどうかチェックする.
         */
        public function check():void
        {
        	appUpdater = new ApplicationUpdater();
            appUpdater.configurationFile = new File("app:/update.xml");
            appUpdater.addEventListener(UpdateEvent.INITIALIZED,
            		function (event:UpdateEvent):void
            		{
            			appUpdater.checkNow();
            		}
			);
        	appUpdater.addEventListener(StatusUpdateEvent.UPDATE_STATUS, updateStatusHandler);
        	appUpdater.initialize();
        }
        
        public function updateStatusHandler(event:StatusUpdateEvent):void
        {
        	// client と server で version が異なれば true, 同一なら false 
       		available = event.available;
        	
        	// バージョン（必要なければ削除）
        	currentVersion = appUpdater.currentVersion;
        	serverVersion = (event.version == "") ? currentVersion : event.version;
        	
        	// 以降の処理をキャンセル
        	appUpdater.cancelUpdate();
        }
    }
}