package tv.attune.quicklib.core
{
    import flash.display.DisplayObject;
    import flash.events.Event;

    import mx.core.IChildList;
    import mx.core.IInvalidating;
    import mx.core.IRawChildrenContainer;
    import mx.managers.ILayoutManagerClient;


    /**
     * Sanford note, where I left this:
     * - Try TestLayoutStyleClient
     * - The boxes should be inside each other and resize large when the middle one is clicked
     * - It doesn't work.  The interactions of the height and width get really complex. It needs good unit tests to work reliably. I think it can be done but not now.
     * - The better way for now is to use StyleClient for leaf elements and to use UIComponents for the containers. That's much more reliable, if slower.
     *
     * For objects that need to do nested measurement and layout,
     * a simplified version of the functions of the LayoutManager.
     *
     * This class adds those functions to StyleClient.
     *
     * Usage: if this class is the top of a chain of ILayoutStyleClient classes, set isTopLayoutStyleClient to true.
     * 			After that, it will update like UIComponent if the invalidate* flags are set
     *
     * 	- Mark the top StyleClient class with isTop == true.
     * 	- That class then sets a listener for EnterFrame and calls validateProperties() down, validateSize() up, and validateDisplayList() down again
     * 		- You only want to run that, though, when the data changes or an invalidating action happens
     * 			- Any class could send a bubbling "invalidateProperties" event or "invalidateProperties" event, to trigger the cycle
     * 		- At that point, have I basically just rewritten UIComponent, since it does the most time-expensive parts?
     * 		- A speed test would be interesting, that's for sure...
     *
     * DEBATING HOW (OR WHETHER) TO MAKE THIS CLASS
     *
     * Modifications by Sanford Redlich:
     *
     * Made measure() work recursively from the bottom of the Display List up, to make
     * parent classes be able to correctly set their sizes based on the preferred bounds
     * of the child classes.
     * 	- 	added override to invalidateSize(), which recursively calls measure()
     * 		on children from the bottom up, then calls measure on this class
     * 	- 	added the same sort of recursive calling to measure() to regenerateStyleCache()
     * 	-	removed the call to measure() that was previously in stylesInitialized(), since
     * 		it will be called directly now by regenerateStyleCache()
     *
     * Problem:
     * 	- If a child changes size it needs to tell its parent to
     * 		- measure()
     * 		- updateDisplayList()
     *	- updateDisplayList() would then call setLayoutBoundsSize(), which would call updateDisplaylist() on the child
     *
     * Problem2:
     * 	- If there are three levels, abc, then if c changes size, it will have b measure() and
     * 		call invalidateDisplayList but also call measure on a, leading to unnecessary updates and measurements down
     *
     * Solution A
     * 	- addChild() adds a listener for a "changedSize" event
     * 	- if child changes size, child sends "changedSize" event
     * 	- when parent gets that event, it
     * 		- calls measure() on itself.
     * 		- if its size was changed, it sends	"changedSize" event to parent
     * 		- if not, it calls updateDisplayList() on itself and, via setLayoutBoundsSize(), on its children
     * 	- That would have the change measure up and redraw down, only on the ones that have changed
     * 	- This is more in line with Nahuel's design and the intent of SpriteVisualElement
     * 		than trying to make it into a "UIComponent lite".
     *
     * Issues
     * 	- If muliple children simultaneously change because data changed then unnecessary rounds of updating will happen (unlikely case for simple renderer use?)
     * 	- E.g., what if some higher level's data changed and propagated down?  If that called invalidateSize, you could have this chain going at every level
     * 		- the commits need to propagate all the way down before any invalidateSize is processed
     *
     * Solution B
     * 	- invalidateSize() calls setValues, which sets children in a chain going down.
     *
     * Issue
     *  - Any of the children could have a new size but you only want the bottom one propagating a change up.
     * 		- for that reason, you need a LayoutManager, to call these functions on every class in the display list
     *
     * Solution C
     * 	- Mark the top StyleClient class with isTop == true.
     * 	- That class then sets a listener for EnterFrame and calls validateProperties() down, validateSize() up, and validateDisplayList() down again
     * 		- You only want to run that, though, when the data changes or an invalidating action happens
     * 			- Any class could send a bubbling "invalidateProperties" event or "invalidateProperties" event, to trigger the cycle
     * 		- At that point, have I basically just rewritten UIComponent, since it does the most time-expensive parts?
     * 		- A speed test would be interesting, that's for sure...
     *
     * Argh! Maybe I should just live without having the children measure themselves...
     *
     * The basic problem is that the child changes but the parent doesn't call updateDisplayList()
     * Maybe I should just have the child send an "invalidateSize" event to the parent and the parent changes? Then you get the cascade above if several levels change.
     * But, really, when am I going to have enough levels for that to matter?  This is intended for fairly simple renderers, not to cover all cases.
     *
     * Or do it Nahuel's way and just not have the child set its own size and then ask the parent to change...
     *
     * Or use the StyleClients that I have but only use them as leaf elements in a tree of UIComponents, so they handle sizing as usual.  Argh.
     *
     * Solution D
     * 	- Expose measureRecursivelyFromBottom()
     * 	- have an isTopLevel boolean
     * 	- on set data(), if (isTopLevel) then
     *
     * 		- update local data
     * 		- setValues to update its children
     * 		- recursively measure from the bottom
     * 		- invalidateDisplayList to update all the way down
     *
     * Issues
     * 	- This makes the process more manual and therefore more error-prone but it's simple
     * 	- Is it really simpler? It's hard to keep in mind how it works...
     *
     * DECISION:
     * 	- Solution C is most fun, I'll try that. If it doesn't work, I'll just live with Nahuel's orginal version without any recursive measuring.
     *
     * Note:
     * 	- this can't implement IInvalidating because SpriteVisualElement has a protected method for invalidateSize, so there's no way to do it.
     *	- so this class has a public method "invalidateComponentSize()" instead.  Otherwise, IInvalidating is implemented
     *
     * @author Sanford
     */
    [Event(name = "invalidateTopDisplayList", type = "flash.events.Event")]
    [Event(name = "invalidateTopProperties", type = "flash.events.Event")]
    [Event(name = "invalidateTopComponentSize", type = "flash.events.Event")]
    public class LayoutStyleClient extends StyleClient implements ILayoutStyleClient
    {

        private static const INVALIDATE_TOP_COMPONENT_SIZE:String = "invalidateTopComponentSize";
        private static const INVALIDATE_TOP_DISPLAY_LIST:String = "invalidateTopDisplayList";
        private static const INVALIDATE_TOP_PROPERTIES:String = "invalidateTopProperties";

        /**
         *  Whether this component or any child component needs to have its
         *  updateDisplayList() method called.
         */
        protected var invalidateDisplayListFlag:Boolean = true;

        /**
         *  Whether this component needs to have its
         *  commitProperties() method called.
         */
        protected var invalidatePropertiesFlag:Boolean = true;

        /**
         *  Whether this component needs to have its
         *  measure() method called.
         */
        protected var invalidateSizeFlag:Boolean = true;

        private var _isTopLayoutStyleClient:Boolean = false;
        private var hasSizeChanged:Boolean = false;
        private var lastMeasuredHeight:int;
        private var lastMeasuredWidth:int;

        public function invalidateComponentSize():void
        {
            super.invalidateSize()
            invalidateSizeFlag = true;
            sendTopEvent(INVALIDATE_TOP_COMPONENT_SIZE);
        }

        override public function invalidateDisplayList():void
        {
            invalidateDisplayListFlag = true;
            sendTopEvent(INVALIDATE_TOP_DISPLAY_LIST);
        }

        public function invalidateProperties():void
        {
            invalidatePropertiesFlag = true;
            sendTopEvent(INVALIDATE_TOP_PROPERTIES);
        }

        public function get isTopLayoutStyleClient():Boolean
        {
            return _isTopLayoutStyleClient;
        }

        public function set isTopLayoutStyleClient(value:Boolean):void
        {
            if (_isTopLayoutStyleClient != value)
            {
                _isTopLayoutStyleClient = value;
                setUpFrameListener();
                setUpInvalidateListeners();
            }
        }

        override public function set measuredHeight(value:Number):void
        {
            if (super.measuredHeight != value)
            {
                super.measuredHeight = value;
                hasSizeChanged = true;
            }
        }

        override public function set measuredWidth(value:Number):void
        {
            if (super.measuredWidth != value)
            {
                super.measuredWidth = value;
                hasSizeChanged = true;
            }
        }

        /**
         * StyleClient calls updateDisplayList after this function,
         * this override doesn't.  If the layoutWidth or layoutHeight
         * has changed, invalidateDisplayList() is called, which will
         * eventually call updateDisplayList();
         */
        override public function setLayoutBoundsSize(width:Number, height:Number,
                                                     postLayoutTransform:Boolean =
                                                     true):void
        {
            if (isNaN(width))
                width = getPreferredBoundsWidth(postLayoutTransform);

            if (isNaN(height))
                height = getPreferredBoundsHeight(postLayoutTransform);

            if (layoutWidth != width)
            {
                layoutWidth = width;
                invalidateDisplayList();
            }

            if (layoutHeight != height)
            {
                layoutHeight = height;
                invalidateDisplayList();
            }
        }

        override public function stylesInitialized():void
        {
            if (!creationComplete)
            {
                createChildren();
                creationComplete = true;
            }
        }

        /**
         * YOYO, goes down because each setLayoutBoundsSize will call updateDisplayList();
         * maybe that shouldn't happen and we should do it here like commitProperties is done?
         */
        public function validateDisplayList():void
        {
            if (invalidateDisplayListFlag)
            {
                // don't bother yet if the parent's height and width are zero
                if (isTopLayoutStyleClient &&
                    (parent.width == 0 && parent.height == 0))
                    return;

                updateDisplayListDown();
                invalidateDisplayListFlag = false;
            }
        }

        public function validateNow():void
        {
            validateProperties();
            validateSize(false);
            validateDisplayList();
        }

        public function validateProperties():void
        {
            if (invalidatePropertiesFlag)
            {
                commitProperties();
                invalidatePropertiesFlag = false;
            }
        }

        /**
         * If recursive then call this on each child before doing anything else,
         * so it runs bottom->top.
         *
         * Then if invalidateSizeFlag, measure and if the size changed, invalidateDisplayList and
         * have the parent measure and redraw.
         */
        public function validateSize(recursive:Boolean = false):void
        {
            if (recursive)
            {
                for (var i:int = 0; i < numChildren; i++)
                {
                    var child:DisplayObject = getChildAt(i);

                    if (child is ILayoutStyleClient)
                        (child as ILayoutStyleClient).validateSize(true);
                }
            }

            if (invalidateSizeFlag)
            {
                measure();

                if (hasSizeChanged)
                {
                    invalidateDisplayList();
                    invalidateParentSizeAndDisplayList();
                    hasSizeChanged = false;
                }

                invalidateSizeFlag = false;
            }
        }

        protected function commitProperties():void
        {
            // To be implemented in sub classes
        }

        override protected function invalidateParentSizeAndDisplayList():void
        {
            // if this is an ILayoutStyleClient then invalidate as that
            if (parent is ILayoutStyleClient)
            {
                (parent as ILayoutStyleClient).invalidateComponentSize();
                (parent as ILayoutStyleClient).invalidateDisplayList();
            }
            // otherwise, invalidate as IInvalidating
            else
            {
                super.invalidateParentSizeAndDisplayList();
            }

            invalidateComponentSize();
            invalidateDisplayList()
        }

        override protected function measure():void
        {
            super.measure();

            var hasSizeChanged:Boolean = false;

            if (measuredHeight != lastMeasuredHeight)
            {
                lastMeasuredHeight = measuredHeight;
                hasSizeChanged = true;
            }

            if (measuredWidth != lastMeasuredWidth)
            {
                lastMeasuredWidth = measuredWidth;
                hasSizeChanged = true;
            }
        }

        /**
         * Layout all the children
         */
        override protected function updateDisplayList(width:Number, height:Number):void
        {
            // To be implemented in sub classes
        }

        /**
         * Commit properties down
         */
        private function commitPropertiesDown():void
        {
            var childList:IChildList = this is IRawChildrenContainer ? (this as IRawChildrenContainer).
                rawChildren : (this as IChildList);

            // Recursively call this method on each child.
            var n:int = childList.numChildren;

            for (var i:int = 0; i < n; i++)
            {
                var child:Object = childList.getChildAt(i);

                if (child is ILayoutStyleClient)
                    (child as ILayoutStyleClient).validateProperties()
            }
        }

        private var isRunningOnEnterFrame:Boolean = false;

        private function onEnterFrame(event:Event):void
        {
            // don't run this twice at the same time
            if (isRunningOnEnterFrame)
                return;

            // if no flags are set, return
            if (!(invalidatePropertiesFlag || invalidateSizeFlag || invalidateDisplayListFlag))
            {
                //trace("LayoutStyleClient.onEnterFrame(event), no flags set, returning");
                return;
            }

            isRunningOnEnterFrame = true;

            // commit properties down
            validateProperties();

            // measure up
            validateSize(true);

            // redraw down
            validateDisplayList();

            isRunningOnEnterFrame = false;
        }

        private function onInvalidateTopComponentSizeRequest(event:Event):void
        {
            event.stopImmediatePropagation();
            invalidateComponentSize();
        }

        private function onInvalidateTopDisplayListRequest(event:Event):void
        {
            event.stopImmediatePropagation();
            invalidateDisplayList();
        }

        private function onInvalidateTopPropertiesRequest(event:Event):void
        {
            event.stopImmediatePropagation();
            invalidateProperties();
        }

        private function sendTopEvent(type:String):void
        {
            if (!isTopLayoutStyleClient)
                dispatchEvent(new Event(type, true));
        }

        private function setUpFrameListener():void
        {
            // set a listener for ENTER_FRAME
            addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
        }

        private function setUpInvalidateListeners():void
        {
            addEventListener(INVALIDATE_TOP_PROPERTIES, onInvalidateTopPropertiesRequest,
                             false, 0, true);
            addEventListener(INVALIDATE_TOP_COMPONENT_SIZE, onInvalidateTopComponentSizeRequest,
                             false, 0, true);
            addEventListener(INVALIDATE_TOP_DISPLAY_LIST, onInvalidateTopDisplayListRequest,
                             false, 0, true);
        }

        /**
         * Redraw down
         */
        private function updateDisplayListDown():void
        {
            // set to the parent's bounds if this is the top
            if (isTopLayoutStyleClient)
                setLayoutBoundsSize(parent.width, parent.height);

            // update the display list for this class
            updateDisplayList(parent.width, parent.height); // YOYO, was just width, height

            // update the children
            var childList:IChildList = this is IRawChildrenContainer ? (this as IRawChildrenContainer).
                rawChildren : (this as IChildList);

            // Recursively call this method on each child.
            var n:int = childList.numChildren;

            for (var i:int = 0; i < n; i++)
            {
                var child:Object = childList.getChildAt(i);

                if (child is ILayoutStyleClient)
                    (child as ILayoutStyleClient).validateDisplayList();
            }
        }

        /**
         *  Sizes the object.
         */
        public function setActualSize(w:Number, h:Number):void
        {
            var hasChanged:Boolean = false;

            if (super.width != w)
            {
                super.width = w;
                hasChanged = true;
            }

            if (super.height != h)
            {
                super.height = h;
                hasChanged = true;
            }

            if (hasChanged)
                invalidateDisplayList();
        }
    }
}
