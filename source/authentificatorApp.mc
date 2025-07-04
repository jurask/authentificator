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

import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

(:typecheck(disableGlanceCheck))
class ViewFactory {
    private var _accounts as Array<Account>;

    public function initialize(accountModel as Array<Account>) {
        _accounts = accountModel;
    }

    public function createView(accountNumber as Number) as BaseView {
        var numAccounts = _accounts.size();
        if (numAccounts == 0) {
            return new NoAccountsView();
        }
        var account = _accounts[accountNumber];
        if (account instanceof TOTPAccount) {
            return new TOTPView(account);
        } else {
            return new HOTPView(account as HOTPAccount);
        }
    }

    public function createDelegate(accountNumber as Number) as BehaviorDelegate {
        var numAccounts = _accounts.size();
        if (numAccounts == 0) {
            return new WatchUi.BehaviorDelegate();
        }
        var account = _accounts[accountNumber];
        if (account instanceof TOTPAccount) {
            return new TOTPDelegate(accountNumber, numAccounts, self);
        } else {
            return new HOTPDelegate(accountNumber, numAccounts, self, account as HOTPAccount);
        }
    }
}

class AuthentificatorApp extends Application.AppBase {
    private var _accounts as Array<Account> or Null;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [ Views ] or [ Views, InputDelegates ] {
        _accounts = loadAccounts(true);
        var factory = new ViewFactory(_accounts);
        return [factory.createView(0), factory.createDelegate(0)];
    }

    (:glance)
    public function getGlanceView() as [ GlanceView ] or [ GlanceView, GlanceViewDelegate ] or Null {
        _accounts = loadAccounts(false);
        var glance = Application.Properties.getValue("glance") as Boolean;
        if (!glance) {
            return [new Glance()];
        }
        if ((_accounts as Array<Account>).size() == 0) {
            return [new NoAccountsGlance()];
        }
        var account = (_accounts as Array<Account>)[0];
        if (account instanceof TOTPAccount) {
            return [new TOTPGlance(account)];
        } else {
            return [new OTPGlance(account)];
        }
    }

    (:glance)
    public function getGlanceTheme() as AppBase.GlanceTheme {
        return AppBase.GLANCE_THEME_GOLD;
    }

    public function onSettingsChanged() as Void {
        var view = WatchUi.getCurrentView();
        var glance = view[0] instanceof Glance;
        _accounts = loadAccounts(!glance);
        if (!glance) {
            var factory = new ViewFactory(_accounts as Array<Account>);
            WatchUi.switchToView(factory.createView(0), factory.createDelegate(0), WatchUi.SLIDE_BLINK);
        }
    }
}    

function getApp() as AuthentificatorApp {
    return Application.getApp() as AuthentificatorApp;
}