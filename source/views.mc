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

class TOTPView extends AuthentificatorView {
    public function initialize(account as TOTPAccount) {
        AuthentificatorView.initialize(account);
    }

    public function createLayout(dc as Dc) as Lang.Array<WatchUi.Drawable> {
        var layout = AuthentificatorView.createLayout(dc);
        layout.addAll(Rez.Layouts.TOTPLayout(dc));
        return layout;
    }

    public function onShow() as Void {
        animateTOTP();
    }

    public function onHide() as Void {
        WatchUi.cancelAllAnimations();
    }

    public function animateTOTP() as Void {
        var account = _account as TOTPAccount;
        var time = Time.now().value();
        var totpTime = account.timeout() - Math.floor(time % account.timeout());
        var initValue = totpTime.toFloat() / account.timeout() * 100;
        var progress = findDrawableById("innerCircle");
        updateCode();
        animate(progress, :percents, ANIM_TYPE_LINEAR, initValue, 0, totpTime, method(:animateTOTP));
    }
}

class HOTPView extends AuthentificatorView {
    public function initialize(account as HOTPAccount) {
        AuthentificatorView.initialize(account);
    }

    public function createLayout(dc as Dc) as Lang.Array<WatchUi.Drawable> {
        var layout = AuthentificatorView.createLayout(dc);
        layout.addAll(Rez.Layouts.HOTPLayout(dc));
        return layout;
    }

    public function onShow() as Void {
        updateCode();
    }
}

class AuthentificatorView extends BaseView {
    protected var _account as Account;
    protected var _calc as OtpCalc;

    public function initialize(account as Account) {
        BaseView.initialize();
        _account = account;
        _calc = new OtpCalc(account);
    }

    public function createLayout(dc as Dc) as Lang.Array<WatchUi.Drawable> {
        var layout = BaseView.createLayout(dc);
        layout.addAll(Rez.Layouts.AuthentificatorLayout(dc));
        return layout;
    }

    public function onLayout(dc as Dc) as Void {
        BaseView.onLayout(dc);
        var name = findDrawableById("name") as Text;
        name.setText(_account.name());
    }

    protected function updateCode() as Void {
        var codeLabel = findDrawableById("code") as Text;
        codeLabel.setText(_calc.code());
    }
}

class NoAccountsView extends BaseView {

    public function initialize() {
        BaseView.initialize();
    }

    public function createLayout(dc as Dc) as Lang.Array<WatchUi.Drawable> {
        var layout = BaseView.createLayout(dc);
        layout.addAll(Rez.Layouts.NoAccountsLayout(dc));
        return layout;
    }
}


class BaseView extends WatchUi.View {
    public function initialize() {
        View.initialize();
    }

    // Update the view
    public function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    public function createLayout(dc as Dc) as Lang.Array<WatchUi.Drawable> {
        return [new Rez.Drawables.Background() ];
    }

    // Load your resources here
    public function onLayout(dc as Dc) as Void {
        setLayout(createLayout(dc));
    }
}