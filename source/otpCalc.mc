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
import Toybox.Time;

(:glance)
class OtpCalc{
    private var _account as Account;

    function initialize(id as Number){
        var accounts = Application.getApp().accounts();
        _account = accounts.getAccount(id);
    }

    public function account() as Account{
        return _account;
    }

    private function otpHmacSha1(message as Number) as Number{
        var key = _account.key();
        // prepare key
        var sha1 = new Cryptography.Hash({:algorithm => Cryptography.HASH_SHA1});
        if (key.size() > 64){
            sha1.update(key);
            key = sha1.digest();
        }
        while(key.size() != 64){
            key.add(0x00);
        }
        // pad key with ipad and opad bytes
        var ipad = 0x36;
        var opad = 0x5C;
        var outerKey = padKey(key, opad);
        var innerKey = padKey(key, ipad);
        // encode message
        var msgdata = new[8]b;
        msgdata.encodeNumber(message, Lang.NUMBER_FORMAT_UINT32, {:offset => 4, :endianness => Lang.ENDIAN_BIG});
        // calculate hmac signature
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
        return result;
    }

    private function padKey(key as ByteArray, pad as Number) as ByteArray{
        var out = []b;
        for (var i = 0; i < key.size(); i++){
            out.add(key[i] ^ pad);
        }
        return out;
    }

    public function code() as String{
        var msg = 0;
        if (_account instanceof TOTPAccount){
            var time = Time.now().value();
            var totpAccount = _account as TOTPAccount;
            msg = Math.floor(time / totpAccount.timeout());
        } else {
            var hotpAccount = _account as HOTPAccount;
            msg = hotpAccount.counter();
        }
        var value = otpHmacSha1(msg).format("%010d");
        return (value.substring(10-_account.digits(), 10));
    }
}