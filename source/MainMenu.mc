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

class MainMenu extends WatchUi.ActionMenu {
    function initialize() {
        ActionMenu.initialize({:theme=>WatchUi.ACTION_MENU_THEME_DARK});
        var previous = WatchUi.loadResource(Rez.Strings.Previous);
        var next = WatchUi.loadResource(Rez.Strings.Next);
        addItem(new WatchUi.ActionMenuItem({:label=>next}, :next));
        addItem(new WatchUi.ActionMenuItem({:label=>previous}, :previous));
    }
}