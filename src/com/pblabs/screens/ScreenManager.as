package com.pblabs.screens
{
    import com.pblabs.engine.core.*;
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.events.*;
    import flash.utils.*;

    /**
     * A simple system for managing a game's UI.
     * 
     * <p>The ScreenManager lets you have a set of named screens. The
     * goto(), push(), and pop() methods let you move from screen
     * to screen in an easy to follow way. A screen is just a DisplayObject
     * which implements IScreen; the included classes are all AS, but if you
     * entirely use Flex, you can use .mxml, too.</p>
     * 
     * <p>To use, first register screen instances by calling registerScreen.
     * Each screen has a unique name. That is what you pass to goto() and 
     * push().</p>
     * 
     * <p>The ScreenManager maintains a stack of screens. Only the topmost 
     * screen is added to the display list, for efficiency. If you want a
     * dialog or another element which only partially covers the screen,
     * you will probably want to use a different system.</p>
     */
    public class ScreenManager implements IAnimatedObject, ITickedObject
    {
        static private var _instance:ScreenManager;
        static public function get instance():ScreenManager
        {
            if(!_instance)
                _instance = new ScreenManager();
            return _instance;
        }
        
        public function ScreenManager()
        {
            ProcessManager.instance.addTickedObject(this);
            ProcessManager.instance.addAnimatedObject(this);
            
            screenParent = Global.mainClass;
        }
        
        /**
         * Associate a named screen with the ScreenManager.
         */
        public function registerScreen(name:String, instance:IScreen):void
        {
            screenDictionary[name] = instance;
        }
        
        /**
         * Get a screen by name. 
         * @param name Name of the string to get.
         * @return Requested screen.
         */
        public function get(name:String):IScreen
        {
            return screenDictionary[name];
        }
        
        private function set currentScreen(value:String):void
        {
            if(_currentScreen)
            {
                _currentScreen.onHide();
                screenParent.removeChild(_currentScreen as DisplayObject);
                _currentScreen = null;
            }
            
            if(value)
            {
                _currentScreen = screenDictionary[value];
                if(!_currentScreen)
                    throw new Error("No such screen '" + value + "'");
                
                screenParent.addChild(_currentScreen as DisplayObject);
                _currentScreen.onShow();
            }
        }
        
        /**
         * @returns The screen currently being displayed, if any.
         */
        public function getCurrentScreen():IScreen
        {
            return _currentScreen;
        }
        
        /**
         * Switch to the specified screen, altering the top of the stack.
         * @param screenName Name of the screen to switch to.
         */
        public function goto(screenName:String):void
        {
            screenStack[screenStack.length - 1] = screenName;
            currentScreen = screenName;
        }
        
        /**
         * Switch to the specified screen, saving the current screen in the 
         * stack so you can pop() and return to it later.  
         * @param screenName Name of the screen to switch to.
         */
        public function push(screenName:String):void
        {
            screenStack.push(screenName);
            currentScreen = screenName;
        }
        
        /**
         * Pop the top of the stack and change to the new top element. Useful
         * for returning to the previous screen when it push()ed to the
         * current one.
         */ 
        public function pop():void
        {
            screenStack.pop();
            currentScreen = screenStack[screenStack.length - 1];
        }
        
        /**
         * @private
         */  
        public function onFrame(elapsed:Number):void
        {
            if(_currentScreen)
                _currentScreen.onFrame(elapsed);
        }
        
        /**
         * @private
         */  
        public function onTick(tickRate:Number):void
        {
            if(_currentScreen)
                _currentScreen.onTick(tickRate);
        }
        
        /**
         * @private
         */  
        public function onInterpolateTick(i:Number):void
        {            
        }
        
        /**
         * This is where the screens are added and removed. Normally it is
         * set to Global.mainClass, but you may want to override it for
         * special cases.
         */ 
        public var screenParent:DisplayObjectContainer = null;

        private var _currentScreen:IScreen = null;
        private var screenStack:Array = [null];
        private var screenDictionary:Dictionary = new Dictionary();
    }
}