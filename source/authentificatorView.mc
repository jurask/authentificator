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

import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Math;
import Toybox.Cryptography;

class AuthentificatorView extends WatchUi.View {
    private var _otp as OtpCalc;

    function initialize(accountNum as Number) {
        View.initialize();
        _otp = new OtpCalc(accountNum);
    }

    // Load your resources here
    public function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        var name = findDrawableById("name") as Text;
        name.setText(_otp.name());
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    public function onShow() as Void {
        if (_otp.type() == 0){
            var hint = findDrawableById("menu");
            hint.setVisible(false);
            animateTOTP();
        } else {
            var progress = findDrawableById("innerCircle");
            progress.setVisible(false);
            var circle = findDrawableById("outerCircle");
            circle.setVisible(false);
            _otp.reloadCounter();
            updateCode();
        }
    }

    // Update the view
    public function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    public function onHide() as Void {
        WatchUi.cancelAllAnimations();
    }

    public function animateTOTP() as Void {
        var time = Time.now().value();
        var totpTime = _otp.timeout() - Math.floor(time % _otp.timeout());
        var initValue = totpTime.toFloat() / _otp.timeout() * 100;
        var progress = findDrawableById("innerCircle");
        updateCode();
        animate(progress, :percents, ANIM_TYPE_LINEAR, initValue, 0, totpTime, method(:animateTOTP));
    }

    private function updateCode() as Void{
        var codeLabel = findDrawableById("code") as Text;
        codeLabel.setText(_otp.code());
    }
}
