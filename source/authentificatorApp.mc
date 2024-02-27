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

import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class ViewFactory {
    private var _accounts as AccountsModel;

    public function initialize(accountModel as AccountsModel) {
        _accounts = accountModel;
    }

    public function createView(accountNumber as Number) as BaseView {
        var numAccounts = _accounts.numAccounts();
        if (numAccounts == 0) {
            return new NoAccountsView();
        }
        var account = _accounts.getAccount(accountNumber);
        if (account instanceof TOTPAccount) {
            return new TOTPView(account);
        } else {
            return new HOTPView(account as HOTPAccount);
        }
    }

    public function createDelegate(accountNumber as Number) as BehaviorDelegate {
        var numAccounts = _accounts.numAccounts();
        if (numAccounts == 0) {
            return new WatchUi.BehaviorDelegate();
        }
        var account = _accounts.getAccount(accountNumber);
        if (account instanceof TOTPAccount) {
            return new TOTPDelegate(accountNumber, numAccounts, self);
        } else {
            return new HOTPDelegate(accountNumber, numAccounts, self, account as HOTPAccount);
        }
    }
}

class authentificatorApp extends Application.AppBase {
    private var _accounts as AccountsModel;

    function initialize() {
        AppBase.initialize();
        _accounts = new AccountsModel();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [ WatchUi.Views ] or [ WatchUi.Views, WatchUi.InputDelegates ] {
        var factory = new ViewFactory(_accounts);
        return [factory.createView(0), factory.createDelegate(0)];
    }

    (:glance)
    public function getGlanceView() as [ WatchUi.GlanceView ] or [ WatchUi.GlanceView, WatchUi.GlanceViewDelegate ] or Null {
        var glance = Application.Properties.getValue("glance");
        if (!glance) {
            return [new Glance()];
        }
        if (_accounts.numAccounts() == 0) {
            return [new NoAccountsGlance()];
        }
        var account = _accounts.getAccount(0);
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
        _accounts.reinitialize();
        var view = WatchUi.getCurrentView();
        if (view[0] instanceof BaseView) {
            var factory = new ViewFactory(_accounts);
            WatchUi.switchToView(factory.createView(0), factory.createDelegate(0), WatchUi.SLIDE_BLINK);
        }
    }
}    

function getApp() as authentificatorApp {
    return Application.getApp() as authentificatorApp;
}