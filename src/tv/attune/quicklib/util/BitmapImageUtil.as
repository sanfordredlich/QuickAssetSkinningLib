package tv.attune.quicklib.util
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.IBitmapDrawable;
    import flash.display.Shape;
    import flash.geom.ColorTransform;
    import flash.geom.Rectangle;

    import mx.core.UIComponent;
    import mx.graphics.BitmapFillMode;
    import mx.styles.IAdvancedStyleClient;

    import spark.components.Image;
    import spark.primitives.BitmapImage;
    import spark.primitives.Graphic;


    public class BitmapImageUtil
    {
        /*public static function getBitmapData(object:DisplayObject):BitmapData {

            var bounds:Rectangle = object.getBounds(Flex`);
            var bmp:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0x00000000);

            var matrix:Matrix = object.transform.concatenatedMatrix;
            var origin:Point = object.localToGlobal(new Point());
            matrix.tx = origin.x - bounds.x;
            matrix.ty = origin.y - bounds.y;

            bmp.draw(object, matrix, object.transform.concatenatedColorTransform);

            return bmp;
        }*/

        /**
         * Problem: it gets the pixels of the object before any transformations
         * but I wanted it to make a drop shadow of text. One trick is to add the
         * displayObject as a child of another, then copy the bitmap of the second.
         * The second one has the transformed version of the first as its own non-
         * transformed version.  Great, but if the displayObject is already the child
         * of another then it will be removed from its own parent.  Argh, why is this
         * so difficult?
         *
         * @param displayObject
         * @param color
         * @param alpha
         *
         * @return
         */
        public static function getBitmapOfDisplayObject(displayObject:DisplayObject,
                                                        color:uint = -1, alpha:Number =
                                                        .5):Bitmap
        {
            // Note: I hoped this matrix , used in Bitmap.draw(), would make the render have the scaling of the displayObject
            // and so make the edges appear smooth.  Unfortunately, the issue is the font anti-aliasing, not scaling
            //var matrix:Matrix = new Matrix(displayObject.scaleX * 2, 0, 0, displayObject.scaleY * 2);
            //trace(matrix.toString());

            // copy the shape
            var bitmapData:BitmapData = new BitmapData(displayObject.width, displayObject.
                                                       height, true, 0);
            // YOYO: it's faster to use on BitmapData and reuse by running bmd.fillRect(bmd.rect, 0x00ffffff); about 4x faster
            bitmapData.draw(displayObject as IBitmapDrawable, null, null, null, null,
                            true);

            // change the color
            if (color != -1)
            {
                var rectangle:Rectangle = new Rectangle(0, 0, displayObject.width,
                                                        displayObject.height);
                var colorTransform:ColorTransform;

                var red:uint = color >> 16;
                var green:uint = color >> 8 & 0xFF;
                var blue:uint = color & 0xFF;

                colorTransform = new ColorTransform(0, 0, 0, 1, red, green, blue,
                                                    alpha);

                bitmapData.colorTransform(rectangle, colorTransform);
            }

            var bitmap:Bitmap = new Bitmap(bitmapData);

            return bitmap;
        }

        public static function getCorneredMask(width:int, height:int, cornerRadius:int):Shape
        {
            // Draw a rounded rectangle to be used as a mask
            var mask:Shape = new Shape();
            mask.graphics.lineStyle(1, 0x000000);
            mask.graphics.beginFill(0x000000);
            mask.graphics.drawRoundRect(0, 0, width, height, cornerRadius, cornerRadius);
            mask.graphics.endFill();

            return mask;
        }

        public static function getBitmapImage(component:IAdvancedStyleClient, sourceStyleName:String,
                                              fillModeStyleName:String = 'backgroundAssetFillMode'):BitmapImage
        {
            var bitmapImage:BitmapImage;
            var sourceData:Object = component.getStyle(sourceStyleName);

            if (sourceData)
            {
                bitmapImage = new BitmapImage();
                bitmapImage.fillMode = component.getStyle(fillModeStyleName)
                    || BitmapFillMode.SCALE;

                bitmapImage.source = sourceData;
            }

            return bitmapImage;
        }

        public static function getBitmapGraphic(component:UIComponent, sourceStyleName:String,
                                                fillModeStyleName:String =
                                                'backgroundAssetFillMode'):Graphic
        {
            var bitmapImage:BitmapImage = getBitmapImage(component, sourceStyleName,
                                                         fillModeStyleName);
            bitmapImage.percentHeight = 100;
            bitmapImage.percentWidth = 100;

            var graphic:Graphic = new Graphic();
            graphic.addElement(bitmapImage);

            return graphic;
        }

        public static function getScalableImage(component:UIComponent, sourceStyleName:String):Image
        {
            var image:Image;

            var sourceData:Object = component.getStyle(sourceStyleName);

            if (sourceData)
            {
                image = new Image();
                image.percentHeight = 100;
                image.percentWidth = 100;
                image.source = sourceData;
            }

            return image;
        }
    }
}
