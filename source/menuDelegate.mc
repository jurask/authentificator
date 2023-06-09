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

import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Input handler to respond to main menu selections
class MenuDelegate extends WatchUi.ActionMenuDelegate {
    private var _accountNum as Lang.Number;

    //! Constructor
    public function initialize(accountNum as Number) {
        ActionMenuDelegate.initialize();
        _accountNum = accountNum;
    }

    //! Handle a menu item being selected
    //! @param item Symbol identifier of the menu item that was chosen
    public function onSelect(item as WatchUi.MenuItem) as Void {
        if (item.getId() == :next) {
            modifyCounter(1);
        } else if (item.getId() == :previous) {
            modifyCounter(-1);
        }
    }

    private function modifyCounter(delta as Number) as Void {
        var accounts = Application.Properties.getValue("accounts");
        var timeout = (accounts as Array<Dictionary<String, String or Number>>)[_accountNum]["timeout"];
        if (timeout == null){
            timeout = 0;
        }
        timeout = timeout + delta;
        if(timeout < 0){
            timeout = 0;
        }
        (accounts as Array<Dictionary<String, String or Number>>)[_accountNum].put("timeout", timeout);
        Application.Properties.setValue("accounts", accounts);
        WatchUi.getCurrentView()[0].onShow();
    }
}
