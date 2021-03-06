package com.facebook.desktop.control.system
{
	import com.facebook.desktop.FacebookDesktopConst;
	import com.facebook.desktop.control.Controller;
	import com.facebook.desktop.model.Model;
	
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.display.Loader;
	import flash.display.NativeMenu;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.resources.ResourceManager;
	
	public class DockManager implements ITrayDockManager
	{
		private var model:Model = Model.instance;
		private var controller:Controller = Controller.instance;
		private var log:ILogger = Log.getLogger("com.facebook.desktop.control.system.DockManager");
		private var icon:DockIcon;
		private var iconLoader:Loader;
		
		public function DockManager()
		{
			// initialize icon properties
			icon = NativeApplication.nativeApplication.icon as DockIcon;
			iconLoader = new Loader();
			
			// attach appropriate event listeners
			iconLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, iconLoadComplete);
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, iconClick);
		}  // DockManager
		
		public function changeState(state:String):void
		{
			switch(state)
			{
				case SystemState.ONLINE:
					changeToOnlineState();
					break;
				case SystemState.OFFLINE:
					changeToOfflineState();
					break;
				case SystemState.DISCONNECTED:
					changeToDisconnectedState();
					break;
				case SystemState.PAUSED:
					changeToPausedState();
					break;
			}  // switch statement
		}  // changeState
		
		public function changeStateManually(menu:NativeMenu, iconPath:String, toolTip:String = null):void
		{
			changeMenu(menu);
			changeIcon(iconPath);
			changeToolTip(toolTip);
		}  // changeStateManually
		
		public function changeMenu(menu:NativeMenu):void
		{
			icon.menu = menu;
		}  // changeMenu
		
		public function changeIcon(iconPath:String):void
		{
			iconLoader.load(new URLRequest(iconPath));
		}  // changeIcon
		
		public function changeToolTip(toolTip:String):void
		{
			// do nothing - dock icon does not support the tool-tip
		}  // changeToolTip
		
		private function changeToOnlineState():void
		{
			log.info("Changing application to ONLINE state");
			model.paused = false;
			changeStateManually(SystemInteractionManager.instance.onlineMenu, FacebookDesktopConst.DOCK_ICON_ONLINE, ResourceManager.getInstance().getString("resources", "application.name"));
		}  // changeToOnlineState
		
		private function changeToOfflineState():void
		{
			log.info("Changing application to OFFLINE state");
			changeStateManually(SystemInteractionManager.instance.offlineMenu, FacebookDesktopConst.DOCK_ICON_OFFLINE, ResourceManager.getInstance().getString("resources", "application.toolTip.offline"));
		}  // changeToDisconnectedState
		
		private function changeToDisconnectedState():void
		{
			log.info("Changing application to DISCONNECTED state");
			changeStateManually(SystemInteractionManager.instance.disconnectedMenu, FacebookDesktopConst.DOCK_ICON_DISCONNECTED, ResourceManager.getInstance().getString("resources", "application.toolTip.disconnected"));
		}  // changeToDisconnectedState
		
		private function changeToPausedState():void
		{
			log.info("Changing application to PAUSED state");
			model.paused = true;
			changeStateManually(SystemInteractionManager.instance.onlineMenu, FacebookDesktopConst.DOCK_ICON_PAUSED, ResourceManager.getInstance().getString("resources", "application.name"));
		}  // changeToPausedState
		
		private function iconLoadComplete(event:Event):void
		{
			NativeApplication.nativeApplication.icon.bitmaps = [event.target.content.bitmapData];
		}  // iconLoadComplete
		
		private function iconClick(event:InvokeEvent):void
		{
			// Invoke event gets triggered on application start-up, but at this point
			// model.preferences haven't yet been loaded.  Detecting here so that we
			// don't perform the default invoke action every time the app starts.
			if (model.preferences != null)
			{
				if (model.preferences.iconClickAction == 0)
				{
					// only show update-window if we're connected
					if (model.connected && model.currentUser != null)
					{
						log.info("Attempting to show/hide status-update window");
						controller.openStatusUpdateWindow();
					}  // if statement
					else
					{
						log.info("System-tray/dock icon clicked but user not logged in. Suppressing display of status-update window.");
					}  // else statement
				}  // if statement
				else
				{
					flash.net.navigateToURL(new URLRequest(FacebookDesktopConst.FACEBOOK_HOMEPAGE));
				}  // else statement
			}  // if statement
		}  // iconClick
	}  // class declaration
}  // package