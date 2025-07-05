/*
    OTP Keychain for Garmin watches
    Copyright (C) 2023-2024 Jiri Babocky

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;
import Rez.Styles;

typedef DrawableParams as {:height as Numeric, :locX as Numeric, :locY as Numeric, :identifier as Object, :width as Numeric, :visible as Boolean};

class CircleProgress extends Drawable {
    private var _start as Number;
    private var _end as Number;
    private var _offset as Number;
    private var _color as ColorValue;
    private var _thickness as Number;
    private var _radius as Number;
    public var percents as Number;

    public function initialize(params as DrawableParams) {
        Drawable.initialize(params);
        _start = params.get(:start) as Number;
        _end = params.get(:end) as Number;
        _offset = params.get(:offset) as Number;
        _thickness = params.get(:thickness) as Number;
        _color = params.get(:color) as ColorValue;
        _radius = params.get(:radius) as Number;
        percents = 0;
    }

    (:circularscreen)
    public function draw(dc as Dc) as Void {
        // calculate end angle
        var length = 0;
        if (_end > _start) {
            length = _end - _start;
        } else {
            length = 360 + _end - _start;
        }
        length = length * percents / 100;
        var endangle = Math.round(_start + length).toLong() % 360;
        // draw
        var radius = dc.getWidth()/2;
        if(dc.getHeight()/2 < radius) {
            radius = dc.getHeight()/2;
        }
        dc.setColor(_color, system_color_dark__text.background);
        dc.setPenWidth(_thickness);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, radius-_offset, Graphics.ARC_COUNTER_CLOCKWISE, _start, endangle);
    }

    //TODO: refactor
    (:rectangularscreen)
    public function draw(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var horizontalLine = width - 2 * _radius - 2 * _offset;
        var verticalLine = height - 2 * _radius - 2 * _offset;
        var corner = 0.5 * Math.PI * _radius;
        var fullLength = 2 * horizontalLine + 2 * verticalLine + 4 * corner;
        var lengthToDraw = fullLength * percents / 100;
        dc.setColor(_color, system_color_dark__text.background);
        dc.setPenWidth(_thickness);
        var endValue = 0;
        // upper line
        endValue = _calcDrawValue(width / 2, _radius + _offset, horizontalLine / 2, lengthToDraw);
        dc.drawLine(width / 2, _offset, endValue, _offset);
        lengthToDraw -= horizontalLine / 2;
        // upper left corner
        if (lengthToDraw <= 1) {
            return;
        }
        endValue = _calcDrawValue(90, 180, corner, lengthToDraw);
        dc.drawArc(_offset + _radius, _offset + _radius, _radius, Graphics.ARC_COUNTER_CLOCKWISE, 90, endValue);
        lengthToDraw -= corner;
        // left line
        if (lengthToDraw <= 1) {
            return;
        }
        endValue = _calcDrawValue(_offset + _radius, height-_offset - _radius, verticalLine, lengthToDraw);
        dc.drawLine(_offset, _offset + _radius, _offset, endValue);
        lengthToDraw -= verticalLine;
        // lower left corner
        if (lengthToDraw <= 1) {
            return;
        }
        endValue = _calcDrawValue(180, 270, corner, lengthToDraw);
        dc.drawArc(_offset + _radius, height - _offset - _radius - 1, _radius, Graphics.ARC_COUNTER_CLOCKWISE, 180, endValue);
        lengthToDraw -= corner;
        // lower line
        if (lengthToDraw <= 1) {
            return;
        }
        endValue = _calcDrawValue(_offset + _radius, width - _radius - _offset, horizontalLine, lengthToDraw);
        dc.drawLine(_radius+_offset, height - _offset, endValue, height - _offset);
        lengthToDraw -= horizontalLine;
        // lower right corner
        if (lengthToDraw <= 1) {
            return;
        }
        endValue = _calcDrawValue(270, 360, corner, lengthToDraw);
        dc.drawArc(width - _offset - _radius - 1, height - _offset - _radius - 1, _radius, Graphics.ARC_COUNTER_CLOCKWISE, 270, endValue);
        lengthToDraw -= corner;
        // right line
        if (lengthToDraw <= 1) {
            return;
        }
        endValue = _calcDrawValue(height-_offset - _radius, _offset + _radius, verticalLine, lengthToDraw);
        dc.drawLine(width - _offset, height-_offset - _radius, width - _offset, endValue);
        lengthToDraw -= verticalLine;
        // upper right corner
        if (lengthToDraw <= 1) {
            return;
        }
        endValue = _calcDrawValue(0, 90, corner, lengthToDraw);
        dc.drawArc(width - _offset - _radius - 1, _offset + _radius, _radius, Graphics.ARC_COUNTER_CLOCKWISE, 0, endValue);
        lengthToDraw -= corner;
        // upper line
        if (lengthToDraw <= 1) {
            return;
        }
        endValue = _calcDrawValue(width - _radius - _offset, width / 2, horizontalLine/2, lengthToDraw);
        dc.drawLine( width - _radius - _offset, _offset, endValue, _offset);
        lengthToDraw -= horizontalLine / 2;
    }

    (:rectangularscreen)
    private function _calcDrawValue(startpos as Number, endpos as Number, elementLength as Float or Number, lengthToDraw as Float or Number) as Float or Number {
        if (elementLength < lengthToDraw) {
            return endpos;
        }
        var portion = lengthToDraw / elementLength;
        return startpos + (endpos - startpos) * portion;
    }
}