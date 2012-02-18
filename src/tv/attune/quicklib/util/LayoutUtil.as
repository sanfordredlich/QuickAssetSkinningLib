package tv.attune.quicklib.util
{
    import flash.display.DisplayObject;
    import flash.geom.Rectangle;


    public class LayoutUtil
    {
        public static function setUp(displayObject:DisplayObject,
                                     x:Number,
                                     y:Number,
                                     width:Number = -1, height:Number = -1):void
        {
            displayObject.x = x;
            displayObject.y = y;

            if (width != -1)
                displayObject.width = width;

            if (height != -1)
                displayObject.height = height;
        }

        public static function setUpCentered(displayObject:DisplayObject,
                                             rectangle:Rectangle,
                                             width:Number = -1,
                                             height:Number = -1):void
        {
            var objectWidth:Number = (width != -1) ? width : displayObject.width;
            var objectHeight:Number = (height != -1) ? height : displayObject.height;

            var x:int = rectangle.x + getCenteredX(rectangle.width, displayObject);
            var y:int = rectangle.y + getCenteredY(rectangle.height, displayObject);

            setUp(displayObject, x, y, objectWidth, objectHeight);
        }

        public static function getCenteredX(width:int, displayObject:DisplayObject):int
        {
            var result:int = (width / 2) - (displayObject.width / 2);
            return result;
        }

        public static function getCenteredY(height:int, displayObject:DisplayObject):int
        {
            var result:int = (height / 2) - (displayObject.height / 2);
            return result;
        }
    }
}
