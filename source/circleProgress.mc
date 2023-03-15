import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;
import Rez.Styles;

class CircleProgress extends Drawable{
    private var _start as Number;
    private var _end as Number;
    private var _offset as Number;
    private var _visible as Boolean;
    private var _color as Graphics.ColorValue;
    private var _thickness as Number;
    public var percents as Number;

    public function initialize(params as Dictionary){
        Drawable.initialize(params);
        _start = params.get(:start) as Number;
        _end = params.get(:end) as Number;
        _offset = params.get(:offset) as Number;
        _thickness = params.get(:thickness) as Number;
        _color = params.get(:color) as Graphics.ColorValue;
        _visible = true;
        percents = 0;
    }

    (:circularscreen)
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
        var radius = dc.getWidth()/2;
        if(dc.getHeight()/2 < radius){
            radius = dc.getHeight()/2;
        }
        dc.setColor(_color, system_color_dark__text.background);
        dc.setPenWidth(_thickness);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, radius-_offset, Graphics.ARC_COUNTER_CLOCKWISE, _start, endangle);
    }

    (:rectangularscreen)
    public function draw(dc as Dc){
        if (!_visible){
            return;
        }
        var width = dc.getWidth();
        var height = dc.getHeight();
        var radius = 20;
        var horizontalLine = width - 2 * radius - 2 * _offset;
        var verticalLine = height - 2 * radius - 2 * _offset;
        var corner = 0.5 * Math.PI * radius;
        var fullLength = 2 * horizontalLine + 2 * verticalLine + 4 * corner;
        var lengthToDraw = fullLength * percents / 100;
        dc.setColor(_color, system_color_dark__text.background);
        dc.setPenWidth(_thickness);
        var endValue = 0;
        // upper line
        endValue = calcDrawValue(width / 2, radius + _offset, horizontalLine / 2, lengthToDraw);
        dc.drawLine(width / 2, _offset, endValue, _offset);
        lengthToDraw -= horizontalLine / 2;
        // upper left corner
        if (lengthToDraw <= 1){
            return;
        }
        endValue = calcDrawValue(90, 180, corner, lengthToDraw);
        dc.drawArc(_offset + radius, _offset + radius, radius, Graphics.ARC_COUNTER_CLOCKWISE, 90, endValue);
        lengthToDraw -= corner;
        // left line
        if (lengthToDraw <= 1){
            return;
        }
        endValue = calcDrawValue(_offset+radius, height-_offset - radius, verticalLine, lengthToDraw);
        dc.drawLine(_offset, _offset+radius, _offset, endValue);
        lengthToDraw -= verticalLine;
        // lower left corner
        if (lengthToDraw <= 1){
            return;
        }
        endValue = calcDrawValue(180, 270, corner, lengthToDraw);
        dc.drawArc(_offset + radius, height - _offset - radius - 1, radius, Graphics.ARC_COUNTER_CLOCKWISE, 180, endValue);
        lengthToDraw -= corner;
        // lower line
        if (lengthToDraw <= 1){
            return;
        }
        endValue = calcDrawValue(_offset+radius, width - radius - _offset, horizontalLine, lengthToDraw);
        dc.drawLine(radius+_offset, height - _offset, endValue, height - _offset);
        lengthToDraw -= horizontalLine;
        // lower right corner
        if (lengthToDraw <= 1){
            return;
        }
        endValue = calcDrawValue(270, 360, corner, lengthToDraw);
        dc.drawArc(width - _offset - radius - 1, height - _offset - radius - 1, radius, Graphics.ARC_COUNTER_CLOCKWISE, 270, endValue);
        lengthToDraw -= corner;
        // right line
        if (lengthToDraw <= 1){
            return;
        }
        endValue = calcDrawValue(height-_offset - radius, _offset+radius, verticalLine, lengthToDraw);
        dc.drawLine(width - _offset, height-_offset - radius, width - _offset, endValue);
        lengthToDraw -= verticalLine;
        // upper right corner
        if (lengthToDraw <= 1){
            return;
        }
        endValue = calcDrawValue(0, 90, corner, lengthToDraw);
        dc.drawArc(width - _offset - radius - 1, _offset + radius, radius, Graphics.ARC_COUNTER_CLOCKWISE, 0, endValue);
        lengthToDraw -= corner;
        // upper line
        if (lengthToDraw <= 1){
            return;
        }
        endValue = calcDrawValue(width - radius - _offset, width / 2, horizontalLine/2, lengthToDraw);
        dc.drawLine( width - radius - _offset, _offset, endValue, _offset);
        lengthToDraw -= horizontalLine / 2;
    }

    (:rectangularscreen)
    private function calcDrawValue(startpos as Number, endpos as Number, elementLength as Float or Number, lengthToDraw as Float or Number) as Float or Number{
        if (elementLength < lengthToDraw){
            return endpos;
        }
        var portion = lengthToDraw / elementLength;
        return startpos + (endpos - startpos) * portion;
    }

    public function setVisible(visible as Boolean){
        _visible = visible;
    }
}