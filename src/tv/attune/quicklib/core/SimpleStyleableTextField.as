package tv.attune.quicklib.core
{
    import flash.filters.DropShadowFilter;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import tv.attune.quicklib.util.TextUtil;


    [Style(name = "textDropShadowAlpha", inherit = "no", type = "Number")]
    [Style(name = "textDropShadowAngle", inherit = "no", type = "Number")]
    [Style(name = "textDropShadowColor", inherit = "no", type = "uint")]
    /**
     * By Nahuel Faronda with CSS extensions by Sanford Redlich, based on an idea by Brian Lai
     * see: http://www.asfusion.com/blog/entry/mobile-itemrenderer-in-actionscript-part-5
     *
     * Usage:
     * <SimpleStyleableTextField styleName="p1 bold grey2 darkShadow1" text="My Text!"/>
     *
     * Where we have in CSS:
     * core|AssetButton.SimpleStyleableTextField.p1 {
     *     font-size: 14px;
     * }
     * textField|TextField.bold, core|SimpleStyleableTextField.bold {
     * 	font-weight: bold;
     * }
     * textField|TextField.grey2, core|SimpleStyleableTextField.grey2 {
     * 	color: #666666;
     * }
     * core|SimpleStyleableTextField.darkShadow1 {
     * 	textDropShadowColor: #000000;
     * 	textDropShadowAlpha: 0.25;
     * }
     */
    public class SimpleStyleableTextField extends StyleClient
    {

        protected var dropShadowFilter:DropShadowFilter;

        protected var textField:TextField;

        protected var textFormat:TextFormat;

        private var _autoSize:String = TextFieldAutoSize.LEFT;

        private var _htmlText:String;

        private var _includeAllStyles:Boolean;

        private var _multiline:Boolean;

        private var _selectable:Boolean;

        private var _text:String;

        private var _wordWrap:Boolean;

        public function get autoSize():String
        {
            return _autoSize;
        }

        public function set autoSize(value:String):void
        {
            if (_autoSize != value)
            {
                _autoSize = value;

                if (textField)
                    textField.autoSize = _autoSize;
            }
        }

        public function get htmlText():String
        {
            return _htmlText;
        }

        public function set htmlText(value:String):void
        {
            if (_htmlText != value)
            {
                _htmlText = value;
                textField.htmlText = _htmlText;
                invalidateSize();
            }
        }

        public function get includeAllStyles():Boolean
        {
            return _includeAllStyles;
        }

        public function set includeAllStyles(value:Boolean):void
        {
            if (_includeAllStyles != value)
            {
                _includeAllStyles = value;
                updateStyles();
            }
        }

        public function get multiline():Boolean
        {
            return _multiline;
        }

        public function set multiline(value:Boolean):void
        {
            if (_multiline != value)
            {
                _multiline = value;

                if (textField)
                    textField.multiline = _multiline;
            }
        }

        public function get selectable():Boolean
        {
            return _selectable;
        }

        public function set selectable(value:Boolean):void
        {
            if (_selectable != value)
            {
                _selectable = value;
                textField.selectable = _selectable;
            }
        }

        override public function set styleName(value:Object):void
        {
            super.styleName = value;
        }

        public function get text():String
        {
            return _text;
        }

        public function set text(value:String):void
        {
            // the textField gives an NPE if it's set to null, so convert to empty string
            value = (value) ? value : '';

            if (_text != value)
            {
                _text = value;

                if (creationComplete)
                {
                    textField.text = _text;
                    invalidateSize();
                }
            }
        }

        public function get textHeight():Number
        {
            var result:Number = textField.textHeight;
            return result;
        }

        public function get textWidth():int
        {
            return textField.textWidth;
        }

        override public function set width(value:Number):void
        {
            super.width = value;

            if (textField)
                textField.width = value;
        }

        public function get wordWrap():Boolean
        {
            return _wordWrap;
        }

        public function set wordWrap(value:Boolean):void
        {
            if (_wordWrap != value)
            {
                _wordWrap = value;

                if (textField)
                    textField.wordWrap = _wordWrap;
            }
        }

        override protected function createChildren():void
        {
            textField = TextUtil.createSimpleTextField(this, selectable, autoSize,
                                                       includeAllStyles);
            textField.multiline = _multiline;
            textField.wordWrap = _wordWrap;

            if (text)
                textField.text = text;

            updateDropShadowStyles();

            addChild(textField);
        }

        override protected function invalidateSize():void
        {
            // SpriteVisualElement calls its own *private* measure, so we have to call ours here
            measure();
        }

        override protected function measure():void
        {
            if (!_multiline)
            {
                height = measuredHeight = textField.textHeight;
                width = measuredWidth = textField.textWidth;
            }
        }

        override protected function updateDisplayList(width:Number, height:Number):void
        {
            textField.autoSize = _autoSize;
            textField.multiline = _multiline;
            textField.wordWrap = _wordWrap;
        }

        protected function updateDropShadowStyles():void
        {
            if (!isNaN(getStyle("textDropShadowColor")))
            {
                // get the styles
                var alpha:Number = getStyle("textDropShadowAlpha");
                var angle:Number = getStyle("textDropShadowAngle");
                var color:Number = getStyle("textDropShadowColor");

                // create the filter if it doesn't exist, with defaults
                if (!dropShadowFilter)
                    dropShadowFilter = new DropShadowFilter(1, 45, 0, 1, 0, 0);

                // update the filter styles as necessary
                if (!isNaN(alpha) && dropShadowFilter.alpha != alpha)
                    dropShadowFilter.alpha = alpha;

                if (!isNaN(angle) && dropShadowFilter.angle != angle)
                    dropShadowFilter.angle = angle;

                if (dropShadowFilter.color != color)
                    dropShadowFilter.color = color;

                // if the filter hasn't been added yet, add it
                if (filters.indexOf(dropShadowFilter) == -1)
                    filters = [ dropShadowFilter ];
            }
        }

        protected function updateStyles():void
        {
            var styleClient:Object = TextUtil.getStyleClient(this);
            textFormat = TextUtil.readTextFormat(styleClient, _includeAllStyles);

            if (textField)
                textField.defaultTextFormat = TextUtil.readTextFormat(this);
        }
    }
}
