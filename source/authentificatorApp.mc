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

class authentificatorApp extends Application.AppBase {
    private var _accounts as AccountsModel;

    function initialize() {
        AppBase.initialize();
        AccountsModel.updateKeys();
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
        if (_accounts.numAccounts() != 0){
            return [ new AuthentificatorView(0), new AuthentificatorViewDelegate(0) ];
        }
        return [ new NoAccountsView() ];
    }

    (:glance)
    public function getGlanceView() as [ WatchUi.GlanceView ] or [ WatchUi.GlanceView, WatchUi.GlanceViewDelegate ] or Null {
        return [new Glance()];
    }

    (:glance)
    public function getGlanceTheme() as AppBase.GlanceTheme{
        return AppBase.GLANCE_THEME_GOLD;
    }

    public function onSettingsChanged() as Void {
        AccountsModel.updateKeys();
        _accounts = new AccountsModel();
        var view = WatchUi.getCurrentView();
        if (view[0] instanceof AuthentificatorView || view[0] instanceof NoAccountsView ){
            if (_accounts.numAccounts() != 0){
                WatchUi.switchToView(new AuthentificatorView(0), new AuthentificatorViewDelegate(0), WatchUi.SLIDE_BLINK);
            } else {
                WatchUi.switchToView(new NoAccountsView(), null, WatchUi.SLIDE_BLINK);
            }
        }
    }

    public function accounts() as AccountsModel{
        return _accounts;
    }
}    

function getApp() as authentificatorApp {
    return Application.getApp() as authentificatorApp;
}