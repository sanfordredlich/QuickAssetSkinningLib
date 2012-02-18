package tv.attune.quicklib.core
{
    import flash.events.Event;
    import flash.events.MouseEvent;


    /**
     * A button for mobile, simply two images that are shown.
     * When the user presses the button it sends a mouse click.
     *
     * Usage:
     * assetButton = new AssetButton();
     * assetButton.styleName = "smallBlack";
     *
     * Where we have in CSS:
     * core|AssetButton.smallBlack {
     * 		up-skin: Embed("/tv/attune/talkbackz/asset/button_resource.swf#smallBlackUp");
     * 		down-skin: Embed("/tv/attune/talkbackz/asset/button_resource.swf#smallBlackDown");
     * 		disabled-skin: Embed("/tv/attune/talkbackz/asset/button_resource.swf#smallBlackDisable");
     * }
     *
     * @author Sanford
     *
     */
    [Event(name = "change", type = "flash.events.Event")]
    public class AssetButton extends StandardStyleClient
    {
        public function AssetButton()
        {
            mouseChildren = false;
            useHandCursor = true;

            // set up event listeners
            addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
            addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
        }

        public var isToggle:Boolean;

        private var _isDisabled:Boolean = false;
        private var _isDown:Boolean = false;
        private var disabledImage:AssetGraphic;
        private var downImage:AssetGraphic;
        private var isToggledDown:Boolean;
        private var upImage:AssetGraphic;

        /**
         * Don't dispatch mouse events when disabled
         * @param event
         * @return
         */
        override public function dispatchEvent(event:Event):Boolean
        {
            if (!isDisabled)
                return super.dispatchEvent(event);
            else
                return false;
        }

        public function get isDisabled():Boolean
        {
            return _isDisabled;
        }

        public function set isDisabled(value:Boolean):void
        {
            if (_isDisabled != value)
            {
                _isDisabled = value;
                updateImageVisibility();
            }
        }

        [Bindable(event = "change")]
        public function get isSelected():Boolean
        {
            return _isDown;
        }

        public function reset():void
        {
            isToggledDown = false;
            isDown = false;
        }

        override protected function createChildren():void
        {
            upImage = createAssetGraphicChildFromClass(getStyle("upSkin"));

            disabledImage = createAssetGraphicChildFromClass(getStyle("disabledSkin"));
            disabledImage.visible = false;

            downImage = createAssetGraphicChildFromClass(getStyle("downSkin"));
            downImage.visible = false;
        }

        protected function get isDown():Boolean
        {
            return _isDown;
        }

        protected function set isDown(value:Boolean):void
        {
            _isDown = value;
            updateImageVisibility();

            dispatchEvent(new Event("change"));
        }

        override protected function updateDisplayList(width:Number, height:Number):void
        {
            super.updateDisplayList(width, height);

            if (hasSizeChanged)
            {
                upImage.height = height;
                upImage.width = width;

                disabledImage.height = height;
                disabledImage.width = width;

                downImage.height = height;
                downImage.width = width;
            }
        }

        protected function updateImageVisibility():void
        {
            if (isDisabled)
            {
                disabledImage.visible = true;
                upImage.visible = false;
                downImage.visible = false;
            }
            else
            {
                disabledImage.visible = false;
                upImage.visible = !_isDown;
                downImage.visible = _isDown;
            }
        }

        private function onMouseDown(event:MouseEvent):void
        {
            isDown = true;
        }

        private function onMouseOut(event:MouseEvent):void
        {
            if (!isToggle)
                isDown = false;
        }

        private function onMouseUp(event:MouseEvent):void
        {
            if (isToggle)
            {
                if (isToggledDown)
                {
                    isDown = false;
                    isToggledDown = false;
                }
                else
                    isToggledDown = true;
            }
            else
                isDown = false;
        }
    }
}
