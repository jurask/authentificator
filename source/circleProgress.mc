import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;
import Rez.Styles;

class CircleProgress extends Drawable{
    private var _start as Number;
    private var _end as Number;
    private var _visible as Boolean;
    public var percents as Number;

    public function initialize(params as Dictionary){
        Drawable.initialize(params);
        _start = params.get(:start) as Number;
        _end = params.get(:end) as Number;
        _visible = true;
        percents = 0;
    }

    public function draw(dc as Dc){
        if (!_visible){
            return;
        }
        // calculate end angle
        var length = 0;
        if (_end > _start){
            length = _end - _start;
        } else {
            length = 360 + _end - _start;
        }
        length = length * percents / 100;
        var endangle = Math.round(_start + length).toLong() % 360;
        // draw
        dc.setColor(system_color_dark__text.color, system_color_dark__text.background);
        dc.setPenWidth(6);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2-6, Graphics.ARC_COUNTER_CLOCKWISE, _start, endangle);
    }

    public function setVisible(visible as Boolean){
        _visible = visible;
    }
}