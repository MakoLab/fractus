//Komponent tworzący dynamicznie menu wraz z zakładkami na podstawie XMLa: 

package com.makolab.components.menu
{		
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.model.GlobalEvent;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.PermissionManager;
	import com.makolab.fractus.view.menu.MenuItemsGroup;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.getDefinitionByName;
	
	import mx.containers.ApplicationControlBar;
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.containers.ViewStack;
	import mx.controls.Label;
	import mx.controls.TabBar;
	import mx.events.ItemClickEvent;
	import mx.states.AddChild;
	import mx.states.State;

		
	public class MainMenu extends VBox	{
		
		private var menuPanel: Canvas = new Canvas();			
		private var menuTabBar: TabBar = new TabBar();
        private var arrDataMenu: Array;	        
        private var newState: State;
        private var newPanel: MenuElement;
        private var hBox:ApplicationControlBar;
        private var hBoxx:HBox;
        //private var searchPanel: StatusBar; 
        private var addChildDyn: AddChild;
        private var selected: Number;
        [Bindable]
        private var _menuData:XML;           
        private var _statesCount:Number;
        private const SPACE: Number = 0;   
        private var hidden:Array;
        
        protected var rootPackage:String = "";  
        public var titleLabel:Label;
        private var spacer:HBox;
        
        
		public function MainMenu()	{
			super();	
			menuPanel.id = "menuPanel";
			menuPanel.x = 0;
			menuPanel.y = 0;
			menuPanel.verticalScrollPolicy = "off";
			menuPanel.horizontalScrollPolicy = "off";
			
			
			//zakładki						
			menuTabBar.y = 2;	//12
			menuTabBar.setStyle("tabStyleName", "tabStyle");			
			//menuTabBar.setStyle("selectedTabTextStyleName", "tabStyleSelected");
			menuTabBar.addEventListener(ItemClickEvent.ITEM_CLICK,menuEventHandler);
			menuTabBar.addEventListener(KeyboardEvent.KEY_DOWN,tabbarKeyDown);
			menuTabBar.addEventListener(KeyboardEvent.KEY_UP,tabbarKeyUp);
			
			//searchPanel = new StatusBar();	
			
			//Napis po lewej stronie. TODO: zrobic konfiguracje ktora okresli polozenie napisu (+spacer)
			titleLabel = new Label();
			titleLabel.text = "";//"Aktualnosci";
			titleLabel.styleName = "titleLabelStyle";
			
			//TODO: Do dopracowania okrelanie szerokosci itp, chwilowo - jesli wyswietlany jest titleLabel to buttony ida na prawa strone
			spacer = new HBox();
			spacer.percentWidth = 100;
			
			hBoxx = new HBox();
			hBoxx.percentHeight = 100;
			
			hBox = new ApplicationControlBar();
			hBox.styleName = "lightGrayControlBar";
			
			hBox.addChild(titleLabel);
			hBox.addChild(spacer);
			hBox.addChild(hBoxx);
			
			//menuPanel.addChild(searchPanel);
			menuPanel.addChild(menuTabBar);
			menuPanel.addChild(hBox);
			
			var model:ModelLocator = ModelLocator.getInstance();
			model.eventManager.addEventListener(GlobalEvent.LANGUAGE_CHANGED, langChanged, false, 0 , true);
			
			this.addChild(menuPanel);
			//menuPanel.addEventListener(KeyboardEvent.KEY_DOWN,tabbarKeyDown);
		}
		private function setTabLang():void
		{
			for(var i:int=0;i<arrDataMenu.length;i++)
			{
				if(arrDataMenu[i])
				arrDataMenu[i].label=
					LanguageManager.getInstance().getLabel(_menuData.menuItem[i].attribute("labelKey").toString());
				//trace(
			}
			var s:String=states[menuTabBar.selectedIndex].name; 
		}
		private function langChanged(e:Event):void
		{		
			if(_menuData)	{
				var k:int=0;
				for each (var node:XML in _menuData.menuItem)	{
					if(arrDataMenu[k])
						arrDataMenu[k].label =LanguageManager.getInstance().getLabel(node.attribute("labelKey").toString());
					k++;					
				}
			}
		}
		private function tabbarKeyDown(event:KeyboardEvent):void
		{
			stage.dispatchEvent(event);
		}
		
		private function tabbarKeyUp(event:KeyboardEvent):void
		{
			stage.dispatchEvent(event);
		}

		public function set menuData(val:XML):void	{
			currentState = null;
        	_menuData=val;
        	rootPackage = _menuData.@rootPackage;
        	if (rootPackage && !rootPackage.match(/\.$/)) rootPackage += ".";
        	menuPanel.percentWidth = 100;
        	
        	//wysokość calego menu        	
        	var menuPanelHeight:String = _menuData.attribute("menuPanelHeight");
        	if(menuPanelHeight != "")
        	{
        		menuPanel.height = parseInt(menuPanelHeight);
        	}
        	else
        	{
        		menuPanel.height = 90; //Number(_menuData.attribute("statusBarHeight")) + Number(_menuData.attribute("submenuHeight")) + 2 * SPACE;
        	}
        	
        	
        	//wysokość paska z zakładkami
        	var menuTabBarHeight:String = _menuData.attribute("menuTabBarHeight");
        	if(menuTabBarHeight != "")
        	{
        		menuTabBar.height = parseInt(menuTabBarHeight);
        	}
        	else
        	{
        		menuTabBar.height = 20;
        	}
        	        	
        	//szerokość paska zakładek wzgledem szerokosci okna, width ma większy priorytet niż percentWidth
        	
        	if(_menuData.attribute("menuTabBarWidth").toString() != "")
        	{
        		menuTabBar.width = parseInt(_menuData.attribute("menuTabBarWidth").toString());
        	}
        	else if (_menuData.attribute("menuTabBarPercentWidth").toString() != "")
        	{
        		menuTabBar.percentWidth = parseInt(_menuData.attribute("menuTabBarPercentWidth").toString());
        	}
        	        	
        	
        	var paddingLeft:String = _menuData.attribute("paddingLeft");
        	if(paddingLeft != "")
        	{
        		menuTabBar.setStyle("paddingLeft", paddingLeft);
        	}        	
        	
        	var paddingRight:String = _menuData.attribute("paddingRight");
        	if(paddingRight != "")
        	{
        		menuTabBar.setStyle("paddingRight", paddingRight);
        	}
        	
        	var showTitleLabel:Boolean = Tools.parseBoolean(_menuData.attribute("showTitleLabel"));
        	this.titleLabel.visible = showTitleLabel;
        	this.titleLabel.includeInLayout = showTitleLabel;
        	this.spacer.visible = showTitleLabel;
        	this.spacer.includeInLayout = showTitleLabel;
        	
        	//searchPanel.height = Number(_menuData.attribute("statusBarHeight")); 
        	//searchPanel.x = Number(_menuData.attribute("logoOffset"));
        	
        	//searchPanel.blankLabel.width = Number(_menuData.attribute("serchOffset"));
        	//menuTabBar.y = 22;
        	
        	menuTabBar.x = 10;// Number(_menuData.attribute("offset"))+Number(_menuData.attribute("logoOffset")); 
        	
        	
        	
        	
        	//obniżenie paska z ikonami względem gory ekranu (odstep od paska z zakladkami)
        	var appControlBarY:String = _menuData.attribute("appControlBarY");
        	if(appControlBarY != "")
        	{
        		hBox.y = parseInt(menuTabBarHeight);
        	}
        	else
        	{
        		hBox.y = 20;//Number(_menuData.attribute("menuHeight"));//+10;  
        	}
        	
 	
        	hBox.percentWidth = 100;
        	hBox.percentHeight = 100;
        	
        	//pozycja napisu titleLabel
        	hBox.setStyle("verticalAlign", "top");
        	defineTabs();
       	}
       	
       	private function set statesCount(val:Number):void	{
			_statesCount = val;				               
            defineStates();               
		}
		
		private function defineTabs():void	{
			arrDataMenu = new Array();	        	
		   	var i:Number = 0;		 
		   	var vs:ViewStack = new ViewStack();
		   	var k:Number = 0;
		   	hidden = new Array();  		   	
		   	for each (var node:XML in _menuData.menuItem)	{
		   		k++;
		   		if (node.@permissionKey && ModelLocator.getInstance().permissionManager.isHidden(node.@permissionKey)) {
					arrDataMenu.push(null);
		   			hidden[k-1] = true;
		   			continue;
		   		}
				var tab:Canvas = new Canvas();
				tab.label = LanguageManager.getInstance().getLabel(node.attribute("labelKey").toString());
				if(ModelLocator.getInstance().permissionManager.isDisabled(node.@permissionKey)) tab.enabled = false;
				
				if (node.@debug != 1 || ModelLocator.getInstance().isDebug())
				{
					vs.addChild(tab);	
					arrDataMenu.push(tab);
				}
				
				if(node.attribute("selected").toString()=="1")	{
					selected = i;						
				}
				i+=1;						
		   	}
		   	menuTabBar.dataProvider = vs;
		   	menuTabBar.selectedIndex = selected;	
   			this.titleLabel.text = _menuData.menuItem[selected].attribute("label").toString();
		   	statesCount=i;		   	
		}
		
		private function defineStates():void {			
			states = new Array();
			var k:Number = 0; 
			var n:Number = 0;  		               
            for (var i:Number = 0; i < _statesCount; i++)	{                	
            	newState = new State();
            	n = 0;	   	
				if(hidden[k]) {
					if(!hidden[k-1]) n = 1;
					for(var m:Number = 1; m < hidden.length; m++)	{
						if(!hidden[k-1] && hidden[k+m]) n++;
						else break;
					}	 
					k = k + n;
				}
				newState.name = "menuState" + i.toString();
				newState.overrides = new Array();	            			
            	var j: Number = 0;
            	var prevWidth: Number = 0; 
            	
                for each (var nodePanel:XML in (XMLList)(_menuData.menuItem[k].panel))	{                	          	
                	var width: Number = Number(nodePanel.attribute("width").toString());
                	
                	var label: String = nodePanel.attribute("label").toString();
                	
                	newPanel = createNewPanel(label, i , j, width, prevWidth);
                	var objClass: Class = getDefinitionByName(rootPackage + "MenuItemsGroup") as Class;
                	
                	//z ui.menu wycięcie z noda panel strybutu class="MenuItemsGroup" i dodanie go powyżej
                	//var objClass: Class = getDefinitionByName(rootPackage + nodePanel.attribute("class").toString()) as Class;
					
					if( objClass != null ) {
						var newObject: DisplayObject = DisplayObject( new objClass() );	
						
						if(newObject is MenuItemsGroup){
							var panelItemsArray:Array = new Array();
							for each (var nodeItem:XML in (XMLList)(nodePanel.panelItem)){
								var id: String = nodeItem.attribute("id").toString();
								var pKey:String = nodeItem.@permissionKey;
								if (!pKey || ModelLocator.getInstance().permissionManager.getPermissionLevel(pKey) != PermissionManager.LEVEL_HIDDEN)
								{
									panelItemsArray.push({id : id, item : nodeItem});
								}
							}
							
							MenuItemsGroup(newObject).init(panelItemsArray);
							//MenuItemsGroup(newObject).panelItemsArray = panelItemsArray;					
						}
						
						newPanel.addChild(newObject);		
					}                	
                	addChildDyn = new AddChild();
                	addChildDyn.relativeTo = hBoxx;
                	addChildDyn.target = newPanel;
                	newState.overrides.push(addChildDyn);                	
                	prevWidth = prevWidth + width;                		                     	
                	j+=1;                	
                }
                k++;
                if(newState)	{
                	states.push(newState);
					addTransitions(newState);
                }
            }            
            currentState = states[menuTabBar.selectedIndex].name;            		     	        
		}
		
		private function addTransitions(state: State): void	{
			/*
			var effect:Move = new Move();				
			effect.yFrom = -60;
			effect.duration=400;								
			effect.target = hBoxx;
			effect.easingFunction = Back.easeOut;
			var transition:Transition = new Transition();			
			transition.fromState = "*";
			transition.toState = state.name;
			transition.effect = effect;
			transitions.push(transition);			
			*/
		}

		private function createNewPanel(title: String, i: Number, j: Number, width: Number, prevWidth: Number): MenuElement	{
			var newPanel:MenuElement = new MenuElement();      
            
            newPanel.id = "menuPanel" + i.toString() + j.toString();
            newPanel.title = title;      	    	
        	newPanel.verticalScrollPolicy = "off";
        	newPanel.horizontalScrollPolicy = "off";
			//TODO: wyrzuci do konfiguracji (po ogarnięciu po co to w ogole jest)
        	newPanel.height= 65;//Number(_menuData.attribute("submenuHeight"))-10;
        	//newPanel.styleName = "menuElementControlBar";       	
        	return newPanel;
		} 
       
        private function menuEventHandler(event:ItemClickEvent) :void {                          
            currentState = "menuState"+ event.index.toString();
            
            this.titleLabel.text =_menuData.menuItem[event.index].attribute("label").toString();
			ModelLocator.getInstance().eventManager.dispatchEvent(new GlobalEvent(GlobalEvent.LANGUAGE_CHANGED));
			//Application.application.setFocus();
        }                    	
	}
}