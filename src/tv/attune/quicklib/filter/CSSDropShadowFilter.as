/**
 * By Nahuel Foronda
 * http://www.asfusion.com/blog/entry/mobile-itemrenderer-in-actionscript-part-5
 */
package tv.attune.quicklib.filter
{
    import flash.filters.DropShadowFilter;


    public class CSSDropShadowFilter
    {

        public function CSSDropShadowFilter(values:Array)
        {
            this.values = values;
        }

        public var alpha:Number = 1;
        public var angle:Number = 45;
        public var blurX:Number = 4;
        public var blurY:Number = 4;
        public var color:uint = 0;
        public var distance:Number = 4;
        public var filter:DropShadowFilter;
        public var hideObject:Boolean = false;
        public var inner:Boolean = false;
        public var knockout:Boolean = false;
        public var quality:int = 1;
        public var strength:Number = 1;

        protected var properties:Array = [ "distance", "angle", "color", "alpha",
                                           "blurX", "blurY", "strength", "quality",
                                           "inner", "knockout", "hideObject" ];

        private var _values:Array;

        public function get values():Array
        {
            return _values;
        }

        public function set values(value:Array):void
        {
            var equal:Boolean = false;

            if (_values && _values.length == value.length)
            {
                // compare all values
                equal = true;

                for (var i:int = 0; i < value.length; i++)
                {
                    if (_values[i] != value[i])
                    {
                        equal = false;
                        break;
                    }
                }
            }

            if (!equal)
            {
                for (var n:int = 0; n < value.length; n++)
                {
                    this[properties[n]] = value[n];
                }
                updateFilter();
            }
        }

        protected function updateFilter():void
        {
            filter = new DropShadowFilter(distance, angle, color, alpha, blurX, blurY,
                                          strength, quality, inner, knockout,
                                          hideObject);
        }
    }
}
