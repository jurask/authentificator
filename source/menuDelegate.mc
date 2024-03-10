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

import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Input handler to respond to main menu selections
class MenuDelegate extends WatchUi.ActionMenuDelegate {
    private var _account as HOTPAccount;
    private var _factory as ViewFactory;
    private var _accNum as Number;

    //! Constructor
    public function initialize(account as HOTPAccount, factory as ViewFactory, accountNo as Number) {
        ActionMenuDelegate.initialize();
        _account = account;
        _factory = factory;
        _accNum  = accountNo;
    }

    //! Handle a menu item being selected
    //! @param item Symbol identifier of the menu item that was chosen
    public function onSelect(item as WatchUi.ActionMenuItem) as Void {
        if (item.getId() == :next) {
            _account.updateCounter(1);
        } else if (item.getId() == :previous) {
            _account.updateCounter(-1);
        }
        WatchUi.switchToView(_factory.createView(_accNum), _factory.createDelegate(_accNum), WatchUi.SLIDE_BLINK);
    }
}
