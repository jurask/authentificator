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
import Toybox.Application.Storage;
import Toybox.Application.Properties;

(:glance)
class AccountLoader {
    function loadAccount(i as Number) as Account {
        var indexStr = i.format("%i");
        var name = Properties.getValue("name" + indexStr);
        var type = Properties.getValue("type" + indexStr);
        var keyStr = Properties.getValue("key" + indexStr);
        var timeout = Properties.getValue("timeout" + indexStr);
        var digits = Properties.getValue("digits" + indexStr);
        var key = _loadKey(keyStr);
        if (type == 0) {
            return new TOTPAccount(name, key, digits, timeout);
        } else {
            return new HOTPAccount(name, key, digits, timeout, i);
        }
    }

    private function _loadKey(keystr as String) as ByteArray {
        var keys = Storage.getValue("keys");
        var keyid = keystr.substring(8, keystr.length()).toNumber();
        return (keys as Dictionary<Number, ByteArray>)[keyid];
    }
}

(:glance)
class AccountUpdater {
    function updateKey(i as Number) as Number {
        var indexStr = i.format("%i");
        var keyStr = Properties.getValue("key" + indexStr);
        if(keyStr.toCharArray()[0] != '#') {
            Properties.setValue("key" + indexStr, _registerKey(keyStr));
        }
        keyStr = Properties.getValue("key" + indexStr);
        return keyStr.substring(8, keyStr.length()).toNumber();
    }

    private function _registerKey(keyStr as String) as String {
        var keys = Storage.getValue("keys");
        if (keys == null) {
            keys = {};
        }
        var binkey = _decodeBase32(keyStr);
        var num = 0;
        while(keys.hasKey(num)) {
            num++;
        }
        (keys as Dictionary<Number, ByteArray>).put(num, binkey);
        Storage.setValue("keys", keys);
        return "#hidden "+num.format("%d");
    }

    private function _decodeBase32(key as String) as ByteArray {
        key = key.toUpper().toCharArray();
        var out = []b;
        var block = [];
        for (var i = 0; i < key.size(); i++) {
            var character = key[i];
            if (character <= 'Z'  && character >= 'A') {
                block.add(character.toNumber() - 65);
            } else if (character <= '7' && character >= '2') {
                block.add(character.toNumber() - 24);
            }
            // add padding
            var validBytes = 5;
            if (i == key.size() - 1) {
                var paddedChars = 0;
                while (block.size() != 8) {
                    block.add(0);
                    paddedChars++;
                }
                switch(paddedChars) {
                    case 6:
                        validBytes = 1;
                        break;
                    case 4:
                        validBytes = 2;
                        break;
                    case 3:
                        validBytes = 3;
                        break;
                    case 1:
                        validBytes = 4;
                        break;
                }
            }
            if (block.size() == 8) {
                // rearrange block bits
                var buf = 0l;
                var decodedBits = 0;
                var ba = []b;
                for (var j = 0; j < 8; j++) {
                    var chr = block[7 - j];
                    buf = buf | (chr << decodedBits);
                    decodedBits += 5;
                    if (decodedBits >= 8) {
                        ba.add((buf & 0xFF).toNumber());
                        buf = buf >> 8;
                        decodedBits -= 8;
                    }
                }
                ba = ba.reverse();
                out.addAll(ba.slice(0, validBytes));
                block = [];
            }
        }
        return out;
    }
}

(:glance)
class AccountsModel {
    private var _accounts as Array?;

    public function initialize() {
        _updateKeys();
        var loader = new AccountLoader();
        var operation = loader.method(:loadAccount);
        _accounts = _walkAccounts(operation);
    }

    public function reinitialize() {
        initialize();
    }

    private function _updateKeys() {
        // add new accounts
        var updater = new AccountUpdater();
        var operation = updater.method(:updateKey);
        var validAccountIDs = _walkAccounts(operation);
        // clear unused
        var keys = Storage.getValue("keys");
        if (keys == null){
            keys = {};
        }
        var storedKeys = keys.keys();
        for(var i = 0; i < storedKeys.size(); i++){
            var id = storedKeys[i];
            if (validAccountIDs.indexOf(id) == -1){
                keys.remove(id);
            }
        }
        Storage.setValue("keys", keys);
    }

    static function _walkAccounts(operation as Method) as Array {
        var results = [];
        for(var i = 1; i <=5; i++) {
            if (!_validateAccount(i)) {
                continue;
            }
            results.add(operation.invoke(i));
        }
        return results;
    }

    static function _validateAccount(index as Number) as Boolean {
        var indexStr = index.format("%i");
        var name = Properties.getValue("name" + indexStr);
        var keyStr = Properties.getValue("key" + indexStr);
        return !(name.equals("") || keyStr.equals(""));
    }

    public function numAccounts() as Number {
        return _accounts.size();
    }

    public function getAccount(index as Number) as Account {
        return _accounts[index];
    }
}

(:glance)
class Account {
    private var _accountName as String;
    private var _key as ByteArray;
    private var _digits as Number;

    function initialize(accountName as String, key as ByteArray, digits as Number) {
        _accountName = accountName;
        _key = key;
        if (digits == null) {
            _digits = 6;
        }
        else if (digits < 1) {
            _digits = 1;
        } else if (digits > 10) {
            _digits = 10;
        } else {
            _digits = digits;
        }
    }

    public function name() as String {
        return _accountName;
    }

    public function key() as ByteArray {
        return _key;
    }

    public function digits() as Number {
        return _digits;
    }

    public function message() as Number {
        return 0;
    }
}

(:glance)
class TOTPAccount extends Account {
    private var _timeout as Number;

    function initialize(accountName as String, key as ByteArray, digits as Number, timeout as Number) {
        Account.initialize(accountName, key, digits);
        _timeout = timeout;
    }

    public function timeout() as Number {
        return _timeout;
    }

    public function message() as Number {
        var time = Time.now().value();
        return Math.floor(time / _timeout);
    }
}

(:glance)
class HOTPAccount extends Account {
    private var _counter as Number;
    private var _index as Number;

    function initialize(accountName as String, key as ByteArray, digits as Number, counter as Number, index as Number) {
        Account.initialize(accountName, key, digits);
        _counter = counter;
        _index = index;
    }

    public function updateCounter(delta as Number) {
        _counter += delta;
        var indexStr = _index.format("%i");
        Properties.setValue("timeout" + indexStr, _counter);
    }

    public function counter() as Number {
        return _counter;
    }

    public function message() as Number {
        return _counter;
    }
}