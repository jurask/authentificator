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
import Toybox.Time;

(:glance)
class OtpCalc {
    private var _key as ByteArray;
    private var _digits as Number;

    function initialize(key as ByteArray, digits as Number) {
        _digits = digits;    
        _key = _prepareKey(key);
    }

    private function _prepareKey(key as ByteArray) as ByteArray {
        var sha1 = new Cryptography.Hash({:algorithm => Cryptography.HASH_SHA1});
        if (key.size() > 64) {
            sha1.update(key);
            key = sha1.digest();
        }
        while(key.size() != 64) {
            key.add(0x00);
        }
        return key;
    }

    private function _otpHmacSha1(message as Number) as Number {
        // pad key with ipad and opad bytes
        var ipad = 0x36;
        var opad = 0x5C;
        var outerKey = _padKey(_key, opad);
        var innerKey = _padKey(_key, ipad);
        // encode message
        var msgdata = new[8]b;
        msgdata.encodeNumber(message, Lang.NUMBER_FORMAT_UINT32, {:offset => 4, :endianness => Lang.ENDIAN_BIG});
        // calculate hmac signature
        var sha1 = new Cryptography.Hash({:algorithm => Cryptography.HASH_SHA1});
        innerKey.addAll(msgdata);
        sha1.update(innerKey);
        innerKey = sha1.digest();
        outerKey.addAll(innerKey);
        sha1.update(outerKey);
        outerKey = sha1.digest();
        // extract OTP code
        var offset = outerKey[19] & 0x0f;
        var code = []b;
        code.add(outerKey[offset] & 0x7f);
        code.add(outerKey[offset + 1]);
        code.add(outerKey[offset + 2]);
        code.add(outerKey[offset + 3]);
        var result = code.decodeNumber(Lang.NUMBER_FORMAT_UINT32, {:offset => 0, :endianness => Lang.ENDIAN_BIG});
        return result as Number;
    }

    private function _padKey(key as ByteArray, pad as Number) as ByteArray {
        var out = []b;
        for (var i = 0; i < key.size(); i++) {
            out.add(key[i] ^ pad);
        }
        return out;
    }

    public function code(msg as Number) as String {
        var value = _otpHmacSha1(msg).format("%010d");
        var string = value.substring(10-_digits, 10);
        if (string == null){
            throw new Lang.ValueOutOfBoundsException("Calculated code has wrong lenght");
        }
        return string;
    }
}