package tv.attune.quicklib.component
{
    import tv.attune.quicklib.core.AssetGraphic;
    import tv.attune.quicklib.core.InvalidatingStyleClient;
    import tv.attune.quicklib.core.SimpleStyleableTextField;
    import tv.attune.quicklib.util.ChildUtil;
    import tv.attune.quicklib.util.LayoutUtil;


    /**
     * Displays an icon on the top and a label on the bottom,
     * with a gap in between.
     *
     * @author Sanford
     */
    public class IconLabelVertical extends InvalidatingStyleClient
    {
        public function IconLabelVertical()
        {
            isMeasureRecursivelyFromBottom = true;
        }

        public var gap:uint;
        public var iconHeight:int;
        public var iconStyle:String;
        public var iconWidth:int;
        public var labelStyle:String;
        private var _labelText:String;

        private var icon:AssetGraphic;
        private var label:SimpleStyleableTextField;

        public function get labelText():String
        {
            return _labelText;
        }

        public function set labelText(value:String):void
        {
            if (_labelText != value)
            {
                _labelText = value;

                if (label)
                {
                    label.text = _labelText;
                    measure();
                    invalidateDisplayList();
                }
            }
        }

        override protected function createChildren():void
        {
            icon = ChildUtil.createAssetGraphicChild(this, iconStyle);
            icon.height = iconHeight;
            icon.width = iconWidth;

            label = ChildUtil.createTextFieldChild(this, labelStyle);
            label.text = labelText;
        }

        override protected function measure():void
        {
            setsSizeItself(Math.max(icon.width, label.width),
                           icon.height + gap + label.height);

            // the parent doesn't call setLayoutBoundsSize because this sets it itself, so we have to call UDL
            updateDisplayList(width, height);
        }

        override protected function updateDisplayList(width:Number, height:Number):void
        {
            var maxWidth:int = Math.max(icon.width, label.getPreferredBoundsWidth());

            icon.setLayoutBoundsPosition(LayoutUtil.getCenteredX(maxWidth, icon),
                                         0);

            // YOYO, the -3 shoudln't be needed!
            label.setLayoutBoundsPosition(LayoutUtil.getCenteredX(maxWidth, label) -
                                          2,
                                          icon.height + gap);
        }
    }
}
