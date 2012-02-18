package tv.attune.quicklib.core
{
    import flash.events.Event;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;

    import mx.core.IChildList;
    import mx.core.IRawChildrenContainer;
    import mx.core.IUITextField;
    import mx.core.mx_internal;
    import mx.styles.*;
    import mx.utils.NameUtil;

    import spark.core.SpriteVisualElement;

    use namespace mx_internal;


    /**
     * By Nahuel Faronda
     * see: http://www.asfusion.com/blog/entry/mobile-itemrenderer-in-actionscript-part-5
     *
     * regenerateStyleCache()
     * 	- stylesInitialized()
     * 		- createChildren()
     *
     * invalidateDisplayList(), setLayoutBoundsSize()
     * 	- updateDisplayList()
     *
     * isMeasureRecursivelyFrom
     * 	- if true, the regenerateStyleCache calls measure() bottom up on this element and its children.
     * 		This makes getPreferredBounds() work correctly with nested components.
     *
     * @author Sanford
     */
    public class StyleClient extends SpriteVisualElement implements IStyleClient,
        IChildList, IAdvancedStyleClient
    {
        public var isMeasureRecursivelyFromBottom:Boolean = false;

        protected var _styleParent:IAdvancedStyleClient

        protected var declarations:Dictionary = new Dictionary();

        protected var explicitHeight:Number;

        protected var explicitWidth:Number;

        protected var layoutHeight:Number;

        protected var layoutWidth:Number;

        protected var stateDeclaration:CSSStyleDeclaration;

        private var _creationComplete:Boolean;

        /**
         *  The state to be used when matching CSS pseudo-selectors. By default
         *  this is the currentState.
         */
        private var _currentCSSState:String;

        /**
         *  Storage for the inheritingStyles property.
         */
        private var _inheritingStyles:Object = StyleProtoChain.STYLE_UNINITIALIZED;

        private var _measuredHeight:Number;

        private var _measuredWidth:Number;

        /**
         *  Storage for the nonInheritingStyles property.
         */
        private var _nonInheritingStyles:Object = StyleProtoChain.STYLE_UNINITIALIZED;

        private var _styleDeclaration:CSSStyleDeclaration;

        private var _styleName:Object

        public function get className():String
        {
            return NameUtil.getUnqualifiedClassName(this);
        }

        public function clearStyle(styleProp:String):void
        {
            setStyle(styleProp, undefined);
        }

        /**
         * Done as a getter/setter so it can be overridden
         * @return
         */
        public function get creationComplete():Boolean
        {
            return _creationComplete;
        }

        public function set creationComplete(value:Boolean):void
        {
            _creationComplete = value;
        }

        public function get currentCSSState():String
        {
            return _currentCSSState;
        }

        public function set currentCSSState(value:String):void
        {
            if (_currentCSSState != value)
            {
                _currentCSSState = value;
                setStateDeclaration();
            }
        }

        public function getClassStyleDeclarations():Array
        {
            return StyleProtoChain.getClassStyleDeclarations(this);
        }

        override public function getLayoutBoundsHeight(postLayoutTransform:Boolean =
                                                       true):Number
        {
            return (layoutHeight) ? layoutHeight : super.getLayoutBoundsHeight(postLayoutTransform);
        }

        override public function getLayoutBoundsWidth(postLayoutTransform:Boolean =
                                                      true):Number
        {
            return (layoutWidth) ? layoutWidth : super.getLayoutBoundsWidth(postLayoutTransform);
        }

        override public function getPreferredBoundsHeight(postLayoutTransform:Boolean =
                                                          true):Number
        {
            return (measuredHeight) ? measuredHeight : super.getPreferredBoundsHeight(postLayoutTransform);
        }

        override public function getPreferredBoundsWidth(postLayoutTransform:Boolean =
                                                         true):Number
        {
            return (measuredWidth) ? measuredWidth : super.getPreferredBoundsWidth(postLayoutTransform);
        }

        public function getStyle(styleProp:String):*
        {
            return styleManager.inheritingStyles[styleProp] ? _inheritingStyles[styleProp] :
                _nonInheritingStyles[styleProp];
        }

        public function hasCSSState():Boolean
        {
            return (_currentCSSState != null);
        }

        [Inspectable(environment = "none")]

        /**
         *  The beginning of this component's chain of inheriting styles.
         *  The <code>getStyle()</code> method simply accesses
         *  <code>inheritingStyles[styleName]</code> to search the entire
         *  prototype-linked chain.
         *  This object is set up by <code>initProtoChain()</code>.
         *  Developers typically never need to access this property directly.
         */
        public function get inheritingStyles():Object
        {
            return _inheritingStyles;
        }

        public function set inheritingStyles(value:Object):void
        {
            _inheritingStyles = value;
        }

        public function invalidateDisplayList():void
        {
            if (layoutWidth || layoutHeight)
                updateDisplayList(layoutWidth, layoutHeight);
        }

        public function matchesCSSState(cssState:String):Boolean
        {
            return currentCSSState == cssState;
        }

        public function matchesCSSType(cssType:String):Boolean
        {
            return StyleProtoChain.matchesCSSType(this, cssType);
        }

        public function get measuredHeight():Number
        {
            return _measuredHeight;
        }

        public function set measuredHeight(value:Number):void
        {
            _measuredHeight = value;
        }

        public function get measuredWidth():Number
        {
            return _measuredWidth;
        }

        public function set measuredWidth(value:Number):void
        {
            _measuredWidth = value;
        }

        [Inspectable(environment = "none")]

        /**
         *  The beginning of this component's chain of non-inheriting styles.
         *  The <code>getStyle()</code> method simply accesses
         *  <code>nonInheritingStyles[styleName]</code> to search the entire
         *  prototype-linked chain.
         *  This object is set up by <code>initProtoChain()</code>.
         *  Developers typically never need to access this property directly.
         */
        public function get nonInheritingStyles():Object
        {
            return _nonInheritingStyles;
        }

        public function set nonInheritingStyles(value:Object):void
        {
            _nonInheritingStyles = value;
        }

        public function notifyStyleChangeInChildren(styleProp:String, recursive:Boolean):void
        {
            var n:int = numChildren;

            for (var i:int = 0; i < n; i++)
            {
                var child:ISimpleStyleClient = getChildAt(i) as ISimpleStyleClient;

                if (child)
                {
                    child.styleChanged(styleProp);

                    // Always recursively call this function because of my
                    // descendants might have a styleName property that points
                    // to this object.  The recursive flag is respected in
                    // Container.notifyStyleChangeInChildren.
                    if (child is IStyleClient)
                        IStyleClient(child).notifyStyleChangeInChildren(styleProp,
                                                                        recursive);
                }
            }
        }

        /**
         * Get the styles of the children and thus cause them to
         * measure.  This way, children are created top-down
         * and measure is called bottom up. Before, measure was called
         * by stylesInitialized() and so went top-down as children were
         * created.
         */
        public function regenerateStyleCache(recursive:Boolean):void
        {
            /*YOYO if (this.hasOwnProperty("itemIndex"))
                trace("regenerateStyleCache for #" + this["itemIndex"]);*/

            StyleProtoChain.initProtoChain(this);

            // create children if they haven't yet been created
            stylesInitialized();

            var childList:IChildList = this is IRawChildrenContainer ? (this as IRawChildrenContainer).
                rawChildren : (this as IChildList);

            // Recursively call this method on each child.
            var n:int = childList.numChildren;

            for (var i:int = 0; i < n; i++)
            {
                var child:Object = childList.getChildAt(i);

                if (child is IStyleClient)
                {
                    // Does this object already have a proto chain?
                    // If not, there's no need to regenerate a new one.
                    (child as IStyleClient).regenerateStyleCache(recursive);
                }
                else if (child is IUITextField)
                {
                    // Does this object already have a proto chain?
                    // If not, there's no need to regenerate a new one.
                    if ((child as IUITextField).inheritingStyles)
                        StyleProtoChain.initTextField(IUITextField(child));
                }
            }

            // call measure bottom-up, added by Sanford (YOYO remove for LayoutStyleClient)
            if (isMeasureRecursivelyFromBottom)
                measure();
        }

        public function registerEffects(effects:Array):void
        {
            // not implemented
        }

        override public function setLayoutBoundsSize(width:Number, height:Number,
                                                     postLayoutTransform:Boolean =
                                                     true):void
        {
            if (isNaN(width))
                width = getPreferredBoundsWidth(postLayoutTransform);

            if (isNaN(height))
                height = getPreferredBoundsHeight(postLayoutTransform);

            layoutWidth = width;
            layoutHeight = height;
            updateDisplayList(width, height);
        }

        public function setStyle(styleProp:String, newValue:*):void
        {
            StyleProtoChain.setStyle(this, styleProp, newValue);
        }

        public function styleChanged(styleProp:String):void
        {
            //StyleProtoChain.styleChanged(this, styleProp);

            if (styleProp && (styleProp != "styleName"))
            {
                if (hasEventListener(styleProp + "Changed"))
                    dispatchEvent(new Event(styleProp + "Changed"));
            }
            else
            {
                if (hasEventListener("allStylesChanged"))
                    dispatchEvent(new Event("allStylesChanged"));
            }
        }

        public function get styleDeclaration():CSSStyleDeclaration
        {
            return _styleDeclaration;
        }

        public function set styleDeclaration(value:CSSStyleDeclaration):void
        {
            _styleDeclaration = value
        }

        /**
         *  Returns the StyleManager instance used by this component.
         */
        public function get styleManager():IStyleManager2
        {
            return StyleManager.getStyleManager(moduleFactory);
        }

        public function get styleName():Object
        {
            return _styleName;
        }

        public function set styleName(value:Object):void
        {
            if (_styleName != value)
            {
                _styleName = value;

                if (creationComplete)
                    StyleProtoChain.initProtoChain(this);
            }
        }

        /**
         *  The parent of this <code>IAdvancedStyleClient</code>..
         *
         *  Typically, you do not assign this property directly.
         *  It is set by the <code>addChild, addChildAt, removeChild, and
         *  removeChildAt</code> methods of the
         *  <code>flash.display.DisplayObjectContainer</code> and  the
         *  <code>mx.core.UIComponent.addStyleClient()</code>  and
         *  the <code>mx.core.UIComponent.removeStyleClient()</code> methods.
         *
         *  If it is assigned a value directly, without calling one of the
         *  above mentioned methods the instance of the class that implements this
         *  interface will not inherit styles from the UIComponent or DisplayObject.
         *  Also if assigned a value directly without, first removing the
         *  object from the current parent with the remove methods listed above,
         *  a memory leak could occur.
         **/
        public function get styleParent():IAdvancedStyleClient
        {
            return parent as IAdvancedStyleClient;
        }

        public function set styleParent(value:IAdvancedStyleClient):void
        {
            _styleParent = value;
        }

        public function stylesInitialized():void
        {
            if (!creationComplete)
            {
                createChildren();
                creationComplete = true;

                if (!isMeasureRecursivelyFromBottom)
                    measure();
            }
        }

        protected function createChildren():void
        {
            // To be implemented in sub classes
        }

        protected function measure():void
        {
            // To be implemented in sub classes
        }

        protected function setStateDeclaration():void
        {
            StyleProtoChain.initProtoChain(this);
        }

        protected function setsHeightItself(height:int):void
        {
            explicitHeight = measuredHeight = this.height = layoutHeight = height;
        }

        /**
         * When this object solely determines its size itself,
         * this is a convenience function to remember to set
         * all the height and width parameters.
         *
         * Added by Sanford
         */
        protected function setsSizeItself(width:int, height:int):void
        {
            setsWidthItself(width);
            setsHeightItself(height);
        }

        protected function setsWidthItself(width:int):void
        {
            explicitWidth = measuredWidth = this.width = layoutWidth = width;
        }

        // updateDisplayList -------------------------------------------------------------------------
        /**
         * Layout all the children
         */
        protected function updateDisplayList(width:Number, height:Number):void
        {
            // To be implemented in sub classes
        }
    }
}
