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

(:glance)
class AccountsModel{

    public function numAccounts() as Number{
        var accounts = Application.Properties.getValue("accounts");
        if (accounts != null){
            return accounts.size();
        }
        return 0;
    }

    public function getAccount(index as Number) as Account{
        var accounts = Application.Properties.getValue("accounts");
        var accountName = (accounts as Array<Dictionary<String, String or Number>>)[index]["name"];
        var type = (accounts as Array<Dictionary<String, String or Number>>)[index]["type"];
        var digits = (accounts as Array<Dictionary<String, String or Number>>)[index]["digits"];
        var keystr = (accounts as Array<Dictionary<String, String or Number>>)[index]["keystr"];
        var timeoutCounter = (accounts  as Array<Dictionary<String, String or Number>>)[index]["timeout"];
        var keys = Application.Storage.getValue("keys");
        var keyid = keystr.substring(8, keystr.length()).toNumber();
        var key = (keys as Dictionary<Number, ByteArray>)[keyid];
        switch (type){
            case 0:
                return new TOTPAccount(index, accountName, key, digits, timeoutCounter);
            case 1:
                return new HOTPAccount(index, accountName, key, digits, timeoutCounter);
            default:
                throw new InvalidValueException("invalid account type");
        }
    }

    public function updateKeys() as Void {
        var accounts = Application.Properties.getValue("accounts");
        if (accounts == null){
            return;
        }
        var keys = Application.Storage.getValue("keys");
        if (keys == null){
            keys = {};
        }
        // add new keys to store
        var foundids = [];
        for(var i = 0; i < accounts.size(); i++){
            var key = (accounts as Array<Dictionary<String, String or Number>>)[i]["keystr"];
            if (key == null){
                key = "";
            }
            if(key.toCharArray()[0] != '#'){
                var binkey = decodeBase32(key);
                var num = 0;
                while(keys.hasKey(num)){
                    num++;
                }
                foundids.add(num);
                (keys as Dictionary<Number, ByteArray>).put(num, binkey);
                (accounts as Array<Dictionary<String, String or Number>>)[i].put("keystr", "#hidden "+num.format("%d"));
            } else {
                foundids.add(key.substring(8, key.length()).toNumber());
            }
        }
        // remove unused keys
        var ids = keys.keys();
        for(var i = 0; i < ids.size(); i++){
            var id = ids[i];
            if (foundids.indexOf(id) == -1){
                keys.remove(id);
            }
        }
        Application.Properties.setValue("accounts", accounts);
        Application.Storage.setValue("keys", keys);
    }

    private function decodeBase32(key as String) as ByteArray{
        key = key.toUpper().toCharArray();
        var out = []b;
        var block = [];
        for (var i = 0; i < key.size(); i++){
            var character = key[i];
            if (character <= 'Z'  && character >= 'A'){
                block.add(character.toNumber() - 65);
            } else if (character <= '7' && character >= '2'){
                block.add(character.toNumber() - 24);
            }
            // add padding
            var validBytes = 5;
            if (i == key.size() - 1){
                var paddedChars = 0;
                while (block.size() != 8){
                    block.add(0);
                    paddedChars++;
                }
                switch(paddedChars){
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
            if (block.size() == 8){
                // rearrange block bits
                var buf = 0l;
                var decodedBits = 0;
                var ba = []b;
                for (var j = 0; j < 8; j++){
                    var chr = block[7 - j];
                    buf = buf | (chr << decodedBits);
                    decodedBits += 5;
                    if (decodedBits >= 8){
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
class Account{
    private var _id as Number;
    private var _accountName as String;
    private var _key as ByteArray;
    private var _digits as Number;

    function initialize(id as Number, accountName as String, key as ByteArray, digits as Number){
        _id = id;
        _accountName = accountName;
        _key = key;
        if (digits == null){
            _digits = 6;
        }
        else if (digits < 1){
            _digits = 1;
        } else if (digits > 10){
            _digits = 10;
        } else {
            _digits = digits;
        }
    }

    public function name() as String{
        return _accountName;
    }

    public function key() as ByteArray{
        return _key;
    }

    public function digits() as Number{
        return _digits;
    }
}

(:glance)
class TOTPAccount extends Account{
    private var _timeout as Number;

    function initialize(id as Number, accountName as String, key as ByteArray, digits as Number, timeout as Number){
        Account.initialize(id, accountName, key, digits);
        _timeout = timeout;
    }

    public function timeout() as Number{
        return _timeout;
    }
}

(:glance)
class HOTPAccount extends Account{
    private var _counter as Number;

    function initialize(id as Number, accountName as String, key as ByteArray, digits as Number, counter as Number){
        Account.initialize(id, accountName, key, digits);
        _counter = counter;
    }

    public function counter() as Number{
        return _counter;
    }
}