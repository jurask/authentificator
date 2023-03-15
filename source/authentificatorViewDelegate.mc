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
import Toybox.Lang;
import Toybox.Application;

class AuthentificatorViewDelegate extends WatchUi.BehaviorDelegate{
    private var _accountNum as Number;

    function initialize(accountNum as Number) {
        BehaviorDelegate.initialize();
        _accountNum = accountNum;
    }

    public function onNextPage() as Boolean {
        var totalAccounts = Application.getApp().numAccounts();
        var nextAccount = _accountNum + 1;
        if (nextAccount >= totalAccounts){
            nextAccount = 0;
        }
        WatchUi.switchToView(new AuthentificatorView(nextAccount), new AuthentificatorViewDelegate(nextAccount), WatchUi.SLIDE_UP);
        return true;
    }

    public function onPreviousPage() as Boolean {
        var totalAccounts = Application.getApp().numAccounts();
        var nextAccount = _accountNum - 1;
        if (nextAccount >= totalAccounts){
            nextAccount = 0;
        } else if (nextAccount < 0){
            nextAccount = totalAccounts - 1;
        }
        WatchUi.switchToView(new AuthentificatorView(nextAccount), new AuthentificatorViewDelegate(nextAccount), WatchUi.SLIDE_DOWN);
        return true;
    }

    public function onSelect() as Boolean {
        var accounts = Application.Properties.getValue("accounts");
        var type = (accounts as Array<Dictionary<String, String or Number>>)[_accountNum]["type"];
        if (type == 1){
            WatchUi.showActionMenu(new $.MainMenu(), new $.MenuDelegate(_accountNum));
            return true;
        } else {
            return false;
        }
    }
}