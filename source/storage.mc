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
import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Application.Properties;
import Toybox.StringUtil;

(:glance)
class AccountLoader {
    function loadAccount(i as Number) as Account {
        var indexStr = i.format("%i");
        var name = Properties.getValue("name" + indexStr) as String;
        var type = Properties.getValue("type" + indexStr) as String;
        var keyStr = Properties.getValue("key" + indexStr) as String;
        var timeout = Properties.getValue("timeout" + indexStr) as Number;
        var digits = Properties.getValue("digits" + indexStr) as Number;
        var key = _loadKey(keyStr);
        if (type == 0) {
            return new TOTPAccount(name, key, digits, timeout);
        } else {
            return new HOTPAccount(name, key, digits, timeout, i);
        }
    }

    private function _loadKey(keystr as String) as ByteArray {
        var keys = Storage.getValue("keys") as Dictionary<Number, String>;
        var keyid = keystr.substring(8, keystr.length());
        if (keyid == null){
            throw new InvalidValueException("Failed to parse key id");
        }
        var encodedKey = keys[keyid.toNumber()];
        if (encodedKey == null){
            throw new ValueOutOfBoundsException("Key not found in database");
        }
        var decodedKey = StringUtil.convertEncodedString(encodedKey,
                                                {:fromRepresentation => StringUtil.REPRESENTATION_STRING_BASE64,
                                                 :toRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY}) as ByteArray;
        return decodedKey;
    }
}

(:glance)
class AccountUpdater {
    function checkKey(i as Number) as Number {
        var keyName = "key" + i.format("%i");
        var keyStr = Properties.getValue(keyName) as String;
        var keyNumber = _getKeyNumber(keyStr);
        if (keyNumber == null){
            keyStr = _updateKey(keyName, keyStr);
            keyNumber = _getKeyNumber(keyStr) as Number;
        }
        return keyNumber;
    }

    private function _getKeyNumber(keyStr as String) as Number or Null {
        if(keyStr.toCharArray()[0] != '#') {
            return null;
        }
        var numberString = keyStr.substring(8, keyStr.length());
        if (numberString == null){
            return null;
        }
        var keyNumber = numberString.toNumber();
        if (keyNumber == null) {
            return null;
        }
        return keyNumber;
    }

    private function _updateKey(keyName as String, keyStr as String) as String {
        var keys = Storage.getValue("keys");
        if (keys == null) {
            keys = {};
        }
        keys = keys as Dictionary<Number, String>;
        var binkey = decodeBase32(keyStr);
        var base64Key = StringUtil.convertEncodedString(binkey,
                                                {:toRepresentation => StringUtil.REPRESENTATION_STRING_BASE64,
                                                 :fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY}) as String;
        var num = 0;
        while(keys.hasKey(num)) {
            num++;
        }
        keys.put(num, base64Key);
        Storage.setValue("keys", keys as Dictionary<Application.PropertyKeyType, Application.PropertyValueType>);
        var newString = "#hidden "+num.format("%d");
        Properties.setValue(keyName, newString);
        return newString;
    }
}

(:glance)
class AccountsModel {
    private var _accounts as Array<Account>;

    public function initialize() {
        _updateKeys();
        var loader = new AccountLoader();
        var operation = loader.method(:loadAccount);
        _accounts = _walkAccounts(operation) as Array<Account>;
    }

    public function reinitialize() as Void {
        initialize();
    }

    private function _updateKeys() as Void {
        // add new accounts
        var updater = new AccountUpdater();
        var operation = updater.method(:checkKey);
        var validAccountIDs = _walkAccounts(operation) as Array<Number>;
        // clear unused
        var keys = Storage.getValue("keys");
        if (keys == null){
            keys = {};
        }
        keys = keys as Dictionary<Number, String or ByteArray>;
        var storedKeys = keys.keys();
        for(var i = 0; i < storedKeys.size(); i++){
            var id = storedKeys[i] as Number;
            if (validAccountIDs.indexOf(id) == -1){
                keys.remove(id);
            } else if (keys[id] instanceof ByteArray){
                //convert keys stored as byte array to string
                keys[id] = StringUtil.convertEncodedString(keys[id] as ByteArray,
                                                {:toRepresentation => StringUtil.REPRESENTATION_STRING_BASE64,
                                                 :fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY}) as String;
            }
        }
        Storage.setValue("keys", keys as Dictionary<Application.PropertyKeyType, Application.PropertyValueType>);
    }

    static function _walkAccounts(operation as Method(i as Number) as Number or Account) as Array<Account or Number> {
        var results = [] as Array<Account or Number>;
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
        var name = Properties.getValue("name" + indexStr) as String;
        var keyStr = Properties.getValue("key" + indexStr) as String;
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
        return Math.floor(time / _timeout).toNumber();
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

    public function updateCounter(delta as Number) as Void {
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

(:glance)
function decodeBase32(key as String) as ByteArray {
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
                    ba.add(((buf & 0xFF) as Long).toNumber());
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