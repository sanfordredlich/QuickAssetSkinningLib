package tv.attune.quicklib.util
{
    import flash.events.MouseEvent;

    import mx.core.IChildList;
    import mx.styles.IStyleClient;

    import tv.attune.quicklib.component.IconLabelHorizontal;
    import tv.attune.quicklib.component.IconLabelVertical;
    import tv.attune.quicklib.core.AssetButton;
    import tv.attune.quicklib.core.AssetGraphic;
    import tv.attune.quicklib.core.SimpleStyleableTextField;


    public class ChildUtil
    {

        public static function createAssetButtonChild(parent:IChildList,
                                                      styleName:String,
                                                      onClickFunction:Function):AssetButton
        {
            var assetButton:AssetButton = new AssetButton();

            assetButton.styleName = styleName;
            assetButton.addEventListener(MouseEvent.CLICK, onClickFunction,
                                         false, 0, true);
            parent.addChild(assetButton);

            return assetButton;
        }

        /**
         * Create an asset button from a style that points to a styleName.
         *
         * That way, you can have a style with the name "previous-button-style" which is "buttonPrev".
         * This will then get the name "buttonPrev" and pass it to createAssetGraphicChild as the styleName.
         * @param metaStyleName The name of the style which specifies the string of the desired ultimate styleName
         * @param onClickFunction The function to cal when a click event is received
         * @return
         */
        public static function createAssetButtonChildFromMetaStyle(parent:IChildList,
                                                                   metaStyleName:String,
                                                                   onClickFunction:Function):AssetButton
        {
            var styleName:String = (parent as IStyleClient).getStyle(metaStyleName);

            if (!styleName)
                onMetaStyleNotFoundError(metaStyleName);

            return createAssetButtonChild(parent, styleName, onClickFunction);
        }

        /**
         * Create an AssetGraphic and add it as a child.
         * @param styleName: the styleName to assign to the AssetGraphic
         * @param imageAssetStyleName: the name of the style to use to get the image itself; defaults to 'imageAsset'
         * @return
         */
        public static function createAssetGraphicChild(parent:IChildList,
                                                       styleName:String,
                                                       imageAssetStyleName:String =
                                                       null):AssetGraphic
        {
            var assetGraphic:AssetGraphic = new AssetGraphic();

            if (imageAssetStyleName)
                assetGraphic.imageAssetStyleName = imageAssetStyleName;

            assetGraphic.styleName = styleName;

            parent.addChild(assetGraphic);

            return assetGraphic;
        }

        /**
         * Create an AssetGraphic and add it as a child.
         * @param styleName: the styleName to assign to the AssetGraphic
         * @param imageAssetStyleName: the name of the style to use to get the image itself; defaults to 'imageAsset'
         * @return
         */
        public static function createAssetGraphicChildFromClass(parent:IChildList,
                                                                clazz:Class):AssetGraphic
        {
            if (!clazz)
                throw new ArgumentError("Object is null, probably because the asset is not defined in the style sheet; styleName: " +
                                        (parent as IStyleClient).styleName);

            var assetGraphic:AssetGraphic = new AssetGraphic();
            assetGraphic.updateImageAsset(new clazz());
            parent.addChild(assetGraphic);

            return assetGraphic;
        }

        /**
         * Create an asset graphic from a style that points to a styleName.
         *
         * That way, you can have a style with the name "backgroundStyle" which is "fillWhite".
         * This will then get the name "fillWhite" and pass it to createAssetGraphicChild as the styleName.
         * @param metaStyleName The name of the style which specifies the string of the desired ultimate styleName
         * @param imageAssetStyleName The name of the style to use to get the image itself; defaults to 'imageAsset'
         *
         */
        public static function createAssetGraphicChildFromMetaStyle(parent:IChildList,
                                                                    metaStyleName:String,
                                                                    imageAssetStyleName:String =
                                                                    null):AssetGraphic
        {
            var styleName:String = (parent as IStyleClient).getStyle(metaStyleName);

            if (!styleName)
                onMetaStyleNotFoundError(metaStyleName);

            return createAssetGraphicChild(parent, styleName, imageAssetStyleName);
        }

        private static function onMetaStyleNotFoundError(metaStyleName:String):void
        {
            throw new ArgumentError("Sorry, style " + metaStyleName + " not found.");
        }

        /**
         * Create an asset graphic from a style that points to a styleName.
         *
         * That way, you can have a style with the name "backgroundStyle" which is "fillWhite".
         * This will then get the name "fillWhite" and pass it to createAssetButtonChild as the styleName.
         * @param metaStyleName The name of the style which specifies the string of the desired ultimate styleName
         * @param imageAssetStyleName The name of the style to use to get the button itself
         */
        public static function createAssetGraphicFromMetaStyle(parent:IChildList,
                                                               metaStyleName:String,
                                                               imageAssetStyleName:String =
                                                               null):AssetGraphic
        {
            var styleName:String = (parent as IStyleClient).getStyle(metaStyleName);

            if (!styleName)
                onMetaStyleNotFoundError(metaStyleName);

            return createAssetGraphicChild(parent, styleName, imageAssetStyleName);
        }

        /**
         * Create an SimpleStyleableTextField and add it as a child.
         * @param styleName: the styleName to assign to the SimpleStyleableTextField
         * @return
         */
        public static function createTextFieldChild(parent:IChildList, styleName:String):SimpleStyleableTextField
        {
            var textField:SimpleStyleableTextField = new SimpleStyleableTextField();
            textField.styleName = styleName;
            parent.addChild(textField);

            return textField;
        }

        /**
         * Create a SimpleStyleableTextField from a style that points to a styleName.
         *
         * That way, you can have a style with the name "title-style" which is "h1 white darkShadowDown".
         * @param metaStyleName The name of the style which specifies the string of the desired ultimate styleName
         * @param onClickFunction The function to cal when a click event is received
         * @return
         */
        public static function createTextFieldChildFromMetaStyle(parent:IChildList,
                                                                 metaStyleName:String):SimpleStyleableTextField
        {
            var styleName:String = (parent as IStyleClient).getStyle(metaStyleName);

            if (!styleName)
                onMetaStyleNotFoundError(metaStyleName);

            return createTextFieldChild(parent, styleName);
        }

        /**
         * Add a horizontal IconLabel child
         * @param text
         * @param iconStyle
         * @param labelStyle
         * @param gap
         * @return
         *
         */
        public static function addChildIconLabelHorizontal(parent:IChildList,
                                                           text:String,
                                                           iconStyle:String,
                                                           labelStyle:String,
                                                           gap:uint,
                                                           iconWidth:uint,
                                                           iconHeight:uint):IconLabelHorizontal
        {
            var result:IconLabelHorizontal = new IconLabelHorizontal();

            result.iconStyle = iconStyle;
            result.labelText = text;
            result.labelStyle = labelStyle;
            result.gap = gap;
            result.iconWidth = iconWidth;
            result.iconHeight = iconHeight;

            parent.addChild(result);

            return result;
        }

        /**
         * Add a vertical IconLabel child
         * @param text
         * @param iconStyle
         * @param labelStyle
         * @param gap
         * @return
         *
         */
        public static function addChildIconLabelVertical(parent:IChildList,
                                                         text:String,
                                                         iconStyle:String,
                                                         labelStyle:String,
                                                         gap:uint,
                                                         iconWidth:uint,
                                                         iconHeight:uint):IconLabelVertical
        {
            var result:IconLabelVertical = new IconLabelVertical();

            result.iconStyle = iconStyle;
            result.labelText = text;
            result.labelStyle = labelStyle;
            result.gap = gap;
            result.iconWidth = iconWidth;
            result.iconHeight = iconHeight;

            parent.addChild(result);

            return result;
        }
    }
}
