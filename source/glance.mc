/*
    OTP Keychain for Garmin watches
    Copyright (C) 2023  Jiri Babocky

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
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.Timer;

(:glance)
class Glance extends WatchUi.GlanceView{
    private var _name as String;
    private var _account as String;
    private var _code as String;
    private var _timer as Timer.Timer;
    private var _otp as OtpCalc or Null;
    private var _lastTimeout as Number;

    function initialize(){
        GlanceView.initialize();
        _name = loadName();
        _account = "";
        _code = "";
        _timer = new Timer.Timer();
        _otp = null;
        _lastTimeout = -2;
    }

    (:upper)
    private function loadName() as String{
        return WatchUi.loadResource($.Rez.Strings.AppName).toUpper();
    }

    (:lower)
    private function loadName() as String{
        return WatchUi.loadResource($.Rez.Strings.AppName);
    }

    (:live)
    public function onLayout(dc as Dc) as Void {
        var glance = Application.Properties.getValue("glance");
        if (glance){
            if (Application.getApp().accounts().numAccounts() != 0){
                _otp = new OtpCalc(0);
                _account = _otp.account().name();
                updateCode();
            } else {
                _account = "No accounts defined";
                _code = "";
            }
            if (_otp != null){
                if (_otp.account() instanceof TOTPAccount){
                    _timer.start(method(:timerCallback), 1000, true);
                }
            }
        } else {
            _account = "";
            _code = "";
        }
    }

    (:nolive)
    public function onLayout(dc as Dc) as Void {
        var glance = Application.Properties.getValue("glance");
        if (glance){
            if (Application.getApp().accounts().numAccounts() != 0){
                _otp = new OtpCalc(0);
                _account = _otp.account().name();
                updateCode();
            } else {
                _account = "No accounts defined";
                _code = "";
            }
        } else {
            _account = "";
            _code = "";
        }
    }

    private function updateCode() as Void {
        _code = _otp.code();
    }

    (:live)
    public function timerCallback() as Void {
        WatchUi.requestUpdate();
    }

    (:live)
    public function onUpdate(dc as Dc) as Void {
        // calculate all data
        var width = dc.getWidth();
        var height = dc.getHeight();
        var line = Graphics.getFontHeight(Graphics.FONT_GLANCE);
        var nlines = 2;
        if (_otp != null){
            if (_otp.account instanceof TOTPAccount){
                nlines = 3;
                var time = Time.now().value();
                var totpTime = _otp.account().timeout() - Math.floor(time % _otp.timeout());
                if (totpTime > _lastTimeout){
                    updateCode();
                }
                _lastTimeout = totpTime;
                var timeLeft = totpTime.toFloat() / _otp.account().timeout();
                drawProgress(dc, timeLeft);
            }
        }
`        // draw glance
        var space = (height - nlines * line) / 2;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, space, Graphics.FONT_GLANCE, _name, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(0, space + (nlines - 1) * line, Graphics.FONT_GLANCE, _account, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(width, space + (nlines - 1) * line, Graphics.FONT_GLANCE, _code, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    (:simple)
    private function drawProgress(dc as Dc, timeLeft as Float) as Void{
        var width = dc.getWidth();
        var height = dc.getHeight();
        dc.setPenWidth(2);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawLine(width * timeLeft + 4, height / 2, width, height / 2);
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
        dc.setPenWidth(8);
        dc.drawLine(0, height / 2, width * timeLeft - 4, height / 2);
    }

    (:bitmap)
    private function drawProgress(dc as Dc, timeLeft as Float) as Void{
        var width = dc.getWidth();
        var height = dc.getHeight();
        dc.setPenWidth(3);
        dc.setColor(0xd1d9e1, Graphics.COLOR_BLACK);
        dc.drawLine(0, height / 2, width, height / 2);
        dc.drawScaledBitmap(0, height / 2-8, width * timeLeft, 16, WatchUi.loadResource($.Rez.Drawables.glanceGradient));
    }

    (:bitmapfr)
    private function drawProgress(dc as Dc, timeLeft as Float) as Void{
        var width = dc.getWidth();
        var height = dc.getHeight();
        dc.setPenWidth(3);
        dc.setColor(0xd1d9e1, Graphics.COLOR_BLACK);
        dc.drawLine(width * timeLeft + 6, height / 2, width, height / 2);
        dc.drawScaledBitmap(2, height / 2-8, width * timeLeft-2, 16, WatchUi.loadResource($.Rez.Drawables.glanceGradient));
        dc.setPenWidth(1);
        dc.setColor(0xa81f20, 0xa81f20);
        dc.drawLine(0, height / 2+3, 0, height / 2+7);
        dc.drawLine(1, height / 2-3, 1, height / 2+7);
        dc.setColor(0xeb1445, 0xeb1445);
        dc.drawLine(width * timeLeft, height / 2-8, width * timeLeft, height / 2+3);
        dc.drawLine(width * timeLeft+1, height / 2-8, width * timeLeft+1, height / 2-3);
    }

    (:nolive)
    public function onUpdate(dc as Dc) as Void{
        // calculate all data
        var width = dc.getWidth();
        var height = dc.getHeight();
        var line = Graphics.getFontHeight(Graphics.FONT_GLANCE);
        var nlines = 2;
        // draw glance
        var space = (height - nlines * line) / 2;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, space, Graphics.FONT_GLANCE, _name, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(0, space + (nlines - 1) * line, Graphics.FONT_GLANCE, _account, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(width, space + (nlines - 1) * line, Graphics.FONT_GLANCE, _code, Graphics.TEXT_JUSTIFY_RIGHT);
    }
 
    public function onHide() as Void{
        _timer.stop();
    }
}