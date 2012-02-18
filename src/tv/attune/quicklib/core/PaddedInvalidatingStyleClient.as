package tv.attune.quicklib.core
{


    /**
     * Add the very commonly-used padding values derived from styles.
     * @author Sanford
     */
    public class PaddedInvalidatingStyleClient extends InvalidatingStyleClient
    {

        protected var horizontalGap:int;

        protected var paddingBottom:int;

        protected var paddingLeft:int;

        protected var paddingRight:int;

        protected var paddingTop:int;

        protected var verticalGap:int;

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
    }
}
