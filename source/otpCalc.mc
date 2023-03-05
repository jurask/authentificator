import Toybox.Lang;
import Toybox.Time;

(:glance)
class OtpCalc{
    private var _id;
    private var _accountName as String;
    private var _type as Number;
    private var _timeout as Number;
    private var _key as ByteArray;
    private var _digits as Number;

    function initialize(id as Number){
        _id = id;
        var accounts = Application.Properties.getValue("accounts");
        _accountName = (accounts as Array<Dictionary<String, String or Number>>)[id]["name"];
        _type = (accounts as Array<Dictionary<String, String or Number>>)[id]["type"];
        _digits = (accounts as Array<Dictionary<String, String or Number>>)[id]["digits"];
        var keystr = (accounts as Array<Dictionary<String, String or Number>>)[id]["keystr"];
        _timeout = 0;
        if (_digits == null){
            _digits = 6;
        }
        if (_digits < 1){
            _digits = 1;
        } else if (_digits > 10){
            _digits = 10;
        }
        reloadCounter();
        // load key from db
        var keys = Application.Storage.getValue("keys");
        var keyid = keystr.substring(8, keystr.length()).toNumber();
        _key = (keys as Dictionary<Number, ByteArray>)[keyid];
    }

    public function name() as String{
        return _accountName;
    }

    public function type() as Number{
        return _type;
    }

    public function timeout() as Number{
        return _timeout;
    }

    public function reloadCounter() as Void{
        var accounts = Application.Properties.getValue("accounts");
        _timeout = (accounts  as Array<Dictionary<String, String or Number>>)[_id]["timeout"];
        if (_timeout == null){
            _timeout = 30;
        }
        if (_timeout < 0){
            _timeout = 30;
        }
    }

    private function otpHmacSha1(key as ByteArray, message as Number) as Number{
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
        if (_type == 0){
            var time = Time.now().value();
            msg = Math.floor(time / _timeout);
        } else {
            msg = _timeout;
        }
        var value = otpHmacSha1(_key, msg).format("%010d");
        return (value.substring(10-_digits, 10));
    }
}