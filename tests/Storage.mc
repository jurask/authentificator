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
import Toybox.Test;

class KeyNumber {
    (:test)
    public function happyPath(logger as Logger) as Boolean {
        var number = getKeyNumber("#hidden 12");
        if (number == null){
            logger.debug("expected 12, got null");
            return false;
        }
        logger.debug("expected 12, got " + number.format("%i"));
        return number == 12;
    }

    (:test)
    public function garbage(logger as Logger) as Boolean {
        var number = getKeyNumber("aaa");
        if (number != null){
            logger.debug("expected null, got " + number.format("%i"));
            return false;
        }
        return true;
    }

    (:test)
    public function parseFail(logger as Logger) as Boolean {
        var number = getKeyNumber("#hidden aaa");
        if (number != null){
            logger.debug("expected null, got " + number.format("%i"));
            return false;
        }
        return true;
    }
}

class KeyStorageTest {
    (:test)
    public function initializeEmpty(logger as Logger) as Boolean {
        var storage = new KeyStorage(null);
        var data = storage.getStorage() as Dictionary<Number, String>;
        return data.size() == 0;
    }

    (:test)
    public function initializeDict(logger as Logger) as Boolean {
        var dict = {0 => "aaa",
                    1 => "bbb"};
        var storage = new KeyStorage(dict);
        var data = storage.getStorage() as Dictionary<Number, String>;
        return data.size() == 2;
    }

    (:test)
    public function register(logger as Logger) as Boolean {
        var dict = {0 => "aaa",
                    1 => "bbb"};
        var storage = new KeyStorage(dict);
        var index = storage.registerKey("MY======");
        var data = storage.getStorage() as Dictionary<Number, String>;
        return data.size() == 3 && index == 2;
    }

    (:test)
    public function registerSparse(logger as Logger) as Boolean {
        var dict = {0 => "aaa",
                    2 => "bbb"};
        var storage = new KeyStorage(dict);
        var index = storage.registerKey("MY======");
        var data = storage.getStorage() as Dictionary<Number, String>;
        return data.size() == 3 && index == 1;
    }

    (:test)
    public function cleanup(logger as Logger) as Boolean {
        var dict = {0 => "aaa",
                    2 => "bbb",
                    3 => "ccc"};
        var storage = new KeyStorage(dict);
        storage.cleanup([0,3]);
        var data = storage.getStorage() as Dictionary<Number, String>;
        return data.size() == 2 && data.keys()[0] == 0 && data.keys()[1] == 3;
    }
}