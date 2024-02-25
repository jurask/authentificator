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

class TOTPDelegate extends AuthentificatorViewDelegate {
    public function initialize(current as Number, total as Number, factory as ViewFactory){
        AuthentificatorViewDelegate.initialize(current, total, factory);
    }
}

class HOTPDelegate extends AuthentificatorViewDelegate {
    public function initialize(current as Number, total as Number, factory as ViewFactory){
        AuthentificatorViewDelegate.initialize(current, total, factory);
    }

   public function onSelect() as Boolean {
        /*var account = Application.getApp().accounts().getAccount(_accountNum);
        if (account instanceof HOTPAccount){
            WatchUi.showActionMenu(new $.MainMenu(), new $.MenuDelegate(_accountNum));
            return true;
        } else {
            return false;
        }*/
        return true;
    }
}

class AuthentificatorViewDelegate extends WatchUi.BehaviorDelegate{
    private var _current as Number;
    private var _total as Number;
    private var _factory as ViewFactory;

    function initialize(current as Number, total as Number, factory as ViewFactory) {
        BehaviorDelegate.initialize();
        _current = current;
        _total = total;
        _factory = factory;
    }

    public function onNextPage() as Boolean {
        var next = _current + 1;
        if (next >= _total){
            next = 0;
        }
        WatchUi.switchToView(_factory.createView(next), _factory.createDelegate(next), WatchUi.SLIDE_UP);
        return true;
    }

    public function onPreviousPage() as Boolean {
        var next = _current - 1;
        if (next >= _total){
            next = 0;
        } else if (next < 0){
            next = _total - 1;
        }
        WatchUi.switchToView(_factory.createView(next), _factory.createDelegate(next), WatchUi.SLIDE_DOWN);
        return true;
    }
}