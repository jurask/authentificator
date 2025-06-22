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
class KeyStorage {
    function initialize(storage as Application.PropertyValueType) {
        if (storage == null) {
            keys = {} as Dictionary<Number, String>;
        } else {
            keys = storage as Dictionary<Number, String>;
        }
    }

    public function registerKey(keyStr as String) as Number {
        var binkey = decodeBase32(keyStr);
        var base64Key = StringUtil.convertEncodedString(binkey,
                                                        {:toRepresentation => StringUtil.REPRESENTATION_STRING_BASE64,
                                                         :fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY}) as String;
        var num = 0;
        while(keys.hasKey(num)) {
            num++;
        }
        keys.put(num, base64Key);
        return num;
    }

    public function loadKey(keyID as Number) as ByteArray {
        var encodedKey = keys[keyID];
        if (encodedKey == null){
            throw new ValueOutOfBoundsException("Key not found in database");
        }
        var decodedKey = StringUtil.convertEncodedString(encodedKey,
                                                         {:fromRepresentation => StringUtil.REPRESENTATION_STRING_BASE64,
                                                          :toRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY}) as ByteArray;
        return decodedKey;
    }

    public function getStorage() as Application.PropertyValueType {
        return keys as Application.PropertyValueType;
    }

    public function cleanup(keyIDs as Array<Number>) as Void {
        var storedKeys = keys.keys();
        for(var i = 0; i < storedKeys.size(); i++){
            var id = storedKeys[i] as Number;
            if (keyIDs.indexOf(id) == -1){
                keys.remove(id);
            }
        }
    }

    private var keys as Dictionary<Number, String>;
}

(:glance)
function getKeyNumber(keyStr as String) as Number or Null {
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

(:glance)
function loadAccount(i as Number, keys as KeyStorage, validKeys as Array<Number>) as Account or Null {
    var indexStr = i.format("%i");
    var name = Properties.getValue("name" + indexStr) as String;
    var type = Properties.getValue("type" + indexStr) as Number;
    var keyStr = Properties.getValue("key" + indexStr) as String;
    var timeout = Properties.getValue("timeout" + indexStr) as Number;
    var digits = Properties.getValue("digits" + indexStr) as Number;
    if (name == null || name.equals("")){
        return null;
    }
    var keyID;
    var idSubStr = keyStr.substring(0, 7);
    if (idSubStr == null || !idSubStr.equals("#hidden")){
        keyID = keys.registerKey(keyStr);
        Properties.setValue("key" + indexStr, "#hidden " + keyID.format("%i"));
    } else {
        keyID = getKeyNumber(keyStr);
        if(keyID == null){
            return null;
        }
    }
    var key = keys.loadKey(keyID);
    validKeys.add(keyID);
    if (type == 0) {
        return new TOTPAccount(name, key, digits, timeout);
    } else {
        return new HOTPAccount(name, key, digits, timeout, i);
    }
}

(:glance)
function loadAccounts(full as Boolean) as Array<Account> {
    var accounts = [];
    var keyIds = [];
    var keys = new KeyStorage(Storage.getValue("keys"));
    for (var i = 1; i < 6; i++){
        var account = loadAccount(i, keys, keyIds);
        if (account != null){
            accounts.add(account);
            if (!full){
                break;
            }
        }
    }
    if (full){
        keys.cleanup(keyIds);
    }
    Storage.setValue("keys", keys.getStorage());
    return accounts;
}

(:glance)
class Account {
    private var _accountName as String;
    private var _key as ByteArray;
    private var _digits as Number;

    function initialize(accountName as String, key as ByteArray, digits as Number or Null) {
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