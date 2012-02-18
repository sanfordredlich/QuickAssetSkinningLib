package tv.attune.quicklib.core
{
    import flash.events.MouseEvent;
    import mx.core.IInvalidating;


    /**
     * Adding some common functionality that can't easily be added
     * via composition: standard style settings, creating styled assets.
     *
     * 	- 	updateDisplayList: adds check for whether the sizes or styles have changed,
     * 		to allow callers to avoid unnecessary processing
     * 	-	create*Child: creates a child of this class from an asset, with a one-line call
     * 	-	createAssetGraphicFromMetaStyle: creates a child of this class from an asset graphic, based on a style referenced by another style
     * 		so the css can be "backgroundStyle: 'fill16';", where 'fill16' is itself a style that specifies the asset graphic to use
     * 	-	readStyles: called by createChildren to standardize picking up the padding* styles, since they're almost always used
     *
     * @author Sanford
     */
    public class StandardStyleClient extends StyleClient
    {

        protected var areStylesInvalid:Boolean = true;

        /**
         * True if, in updateDisplayList, the height or width
         * has changed from the last call;
         */
        protected var hasSizeChanged:Boolean = false;

        protected var horizontalGap:int;

        protected var lastUnscaledHeight:Number;

        protected var lastUnscaledWidth:Number;

        protected var paddingBottom:int;

        protected var paddingLeft:int;

        protected var paddingRight:int;

        protected var paddingTop:int;

        protected var verticalGap:int;

        protected function createAssetButtonChild(styleName:String, onClickFunction:Function):AssetButton
        {
            var assetButton:AssetButton = new AssetButton();

            assetButton.styleName = styleName;
            assetButton.addEventListener(MouseEvent.CLICK, onClickFunction, false,
                                         0, true);
            addChild(assetButton);

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
        protected function createAssetButtonChildFromMetaStyle(metaStyleName:String,
                                                               onClickFunction:Function):AssetButton
        {
            var styleName:String = getStyle(metaStyleName);
            return createAssetButtonChild(styleName, onClickFunction);
        }

        /**
         * Create an AssetGraphic and add it as a child.
         * @param styleName: the styleName to assign to the AssetGraphic
         * @param imageAssetStyleName: the name of the style to use to get the image itself; defaults to 'imageAsset'
         * @return
         */
        protected function createAssetGraphicChild(styleName:String,
                                                   imageAssetStyleName:String = null):AssetGraphic
        {
            var assetGraphic:AssetGraphic = new AssetGraphic();

            if (imageAssetStyleName)
                assetGraphic.imageAssetStyleName = imageAssetStyleName;

            assetGraphic.styleName = styleName;

            addChild(assetGraphic);

            return assetGraphic;
        }

        /**
         * Create an AssetGraphic and add it as a child.
         * @param styleName: the styleName to assign to the AssetGraphic
         * @param imageAssetStyleName: the name of the style to use to get the image itself; defaults to 'imageAsset'
         * @return
         */
        protected function createAssetGraphicChildFromClass(clazz:Class):AssetGraphic
        {
            if (!clazz)
                throw new ArgumentError("Object is null, probably because the asset is not defined in the style sheet; styleName: " +
                                        styleName);

            var assetGraphic:AssetGraphic = new AssetGraphic();
            assetGraphic.updateImageAsset(new clazz());
            addChild(assetGraphic);

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
        protected function createAssetGraphicChildFromMetaStyle(metaStyleName:String,
                                                                imageAssetStyleName:String =
                                                                null):AssetGraphic
        {
            var styleName:String = getStyle(metaStyleName);
            return createAssetGraphicChild(styleName, imageAssetStyleName);
        }

        /**
         * Create an asset graphic from a style that points to a styleName.
         *
         * That way, you can have a style with the name "backgroundStyle" which is "fillWhite".
         * This will then get the name "fillWhite" and pass it to createAssetButtonChild as the styleName.
         * @param metaStyleName The name of the style which specifies the string of the desired ultimate styleName
         * @param imageAssetStyleName The name of the style to use to get the button itself
         */
        protected function createAssetGraphicFromMetaStyle(metaStyleName:String,
                                                           imageAssetStyleName:String =
                                                           null):AssetGraphic
        {
            var styleName:String = getStyle(metaStyleName);
            return createAssetGraphicChild(styleName, imageAssetStyleName);
        }

        override protected function createChildren():void
        {
            readStyles();
            super.createChildren();
        }

        /**
         * Create an SimpleStyleableTextField and add it as a child.
         * @param styleName: the styleName to assign to the SimpleStyleableTextField
         * @return
         */
        protected function createTextFieldChild(styleName:String):SimpleStyleableTextField
        {
            var textField:SimpleStyleableTextField = new SimpleStyleableTextField();
            textField.styleName = styleName;
            addChild(textField);

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
        protected function createTextFieldChildFromMetaStyle(metaStyleName:String):SimpleStyleableTextField
        {
            var styleName:String = getStyle(metaStyleName);
            return createTextFieldChild(styleName);
        }

        protected function readStyles():void
        {
            paddingTop = getStyle("paddingTop");
            paddingLeft = getStyle("paddingLeft");
            paddingRight = getStyle("paddingRight");
            paddingBottom = getStyle("paddingBottom");
            horizontalGap = getStyle("horizontalGap");
            verticalGap = getStyle("verticalGap");

            areStylesInvalid = true;
        }

        override protected function setStateDeclaration():void
        {
            areStylesInvalid = true;
            super.setStateDeclaration();
        }

        override protected function updateDisplayList(width:Number, height:Number):void
        {
            // note whether the size has changed, to help descendent classes 
            // only do size work if necessary.  When they do the work, they should
            // set hasSizeChanged to false
            if ((width > 0 || height > 0)
                && (width != lastUnscaledWidth || height != lastUnscaledHeight))
            {
                hasSizeChanged = true;
                lastUnscaledWidth = width;
                lastUnscaledHeight = height;
            }
        }

        protected function updateDisplayListResetFlags():void
        {
            areStylesInvalid = false;
            hasSizeChanged = false;
        }
    }
}
