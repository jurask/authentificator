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
class Glance extends WatchUi.GlanceView {
    protected var _nlines;

    public function initialize() {
        GlanceView.initialize();
        _nlines = 2;
    }

    (:upper)
    protected function getName() as String {
        return WatchUi.loadResource($.Rez.Strings.AppName).toUpper();
    }

    (:lower)
    protected function getName() as String {
        return WatchUi.loadResource($.Rez.Strings.AppName);
    }

    protected function getCode() as String {
        return "";
    }

    protected function getAccount() as String {
        return "";
    }

    public function onUpdate(dc as Dc) as Void  {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var line = Graphics.getFontHeight(Graphics.FONT_GLANCE);
        var space = (height - _nlines * line) / 2;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, space, Graphics.FONT_GLANCE, getName(), Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(0, space + (_nlines - 1) * line, Graphics.FONT_GLANCE, getAccount(), Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(width, space + (_nlines - 1) * line, Graphics.FONT_GLANCE, getCode(), Graphics.TEXT_JUSTIFY_RIGHT);
    }
}

(:glance)
class NoAccountsGlance extends Glance {
    public function initialize() {
        Glance.initialize();
    }

    protected function getAccount() as String {
        return "No accounts defined";
    }
}

(:glance)
class OTPGlance extends Glance {
    protected var _account as Account;
    protected var _otp as OtpCalc;

    public function initialize(account as Account) {
        Glance.initialize();
        _account = account;
        _otp = new OtpCalc(account);
    }

    protected function getAccount() as String {
        return _account.name();
    }

    protected function getCode() as String {
        return _otp.code();
    }
}

(:glance)
class TOTPGlance extends OTPGlance {
    (:live) private var _code as String;
    (:live) private var _timer as Timer.Timer;
    (:live) private var _lastTimeout as Number;

    (:nolive)
    public function initialize (account as Account) {
        OTPGlance.initialize(account);
    }

    (:live)
    public function initialize(account as Account) {
        OTPGlance.initialize(account);
        _code = _otp.code();
        _lastTimeout = -2;
        _timer = new Timer.Timer();
        _nlines = 3;
    }

    (:live)
    public function getCode() as String {
        return _code;
    }

    (:live)
    public function onLayout(dc as Dc) as Void {
        _timer.start(method(:timerCallback), 1000, true);
    }

    (:live)
    public function onUpdate(dc as Dc) as Void {
        OTPGlance.onUpdate(dc);
        var time = Time.now().value();
        var totpAccount = _account as TOTPAccount;
        var totpTime = totpAccount.timeout() - Math.floor(time % totpAccount.timeout());
        if (totpTime > _lastTimeout) {
            _otp.code();
        }
        _lastTimeout = totpTime;
        var timeLeft = totpTime.toFloat() / totpAccount.timeout();
        drawProgress(dc, timeLeft);
    }

    (:live)
    public function timerCallback() as Void {
        WatchUi.requestUpdate();
    }

    (:live)
    public function onHide() as Void {
        _timer.stop();
    }

    (:simple)
    private function drawProgress(dc as Dc, timeLeft as Float) as Void {
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
    private function drawProgress(dc as Dc, timeLeft as Float) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        dc.setPenWidth(3);
        dc.setColor(0xd1d9e1, Graphics.COLOR_BLACK);
        dc.drawLine(0, height / 2, width, height / 2);
        dc.drawScaledBitmap(0, height / 2-8, width * timeLeft, 16, WatchUi.loadResource($.Rez.Drawables.glanceGradient));
    }

    (:bitmapfr)
    private function drawProgress(dc as Dc, timeLeft as Float) as Void {
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
}