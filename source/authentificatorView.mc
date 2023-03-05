import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Math;
import Toybox.Cryptography;

class AuthentificatorView extends WatchUi.View {
    private var _accountName as String;
    private var _type as Number;
    private var _timeout as Number;
    private var _key as ByteArray;
    private var _digits as Number;
    private var _accountNum as Number;

    function initialize(accountNum as Number) {
        View.initialize();
        _accountNum = accountNum;
        var accounts = Application.Properties.getValue("accounts");
        _accountName = (accounts[accountNum] as Dictionary<String, Number or String>)["name"];
        _type = (accounts[accountNum] as Dictionary<String, Number or String>)["type"];
        _timeout = (accounts[accountNum] as Dictionary<String, Number or String>)["timeout"];
        _digits = (accounts[accountNum] as Dictionary<String, Number or String>)["digits"];
        _key = decodeBase32((accounts[accountNum] as Dictionary<String, Number or String>)["keystr"]);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        var name = findDrawableById("name") as Text;
        name.setText(_accountName);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        if (_type == 0){
            var hint = findDrawableById("menu");
            hint.setVisible(false);
            animateTOTP();
        } else {
            var progress = findDrawableById("innerCircle");
            progress.setVisible(false);
            var accounts = Application.Properties.getValue("accounts");
            var value = (accounts[_accountNum] as Dictionary<String, Number or String>)["timeout"];
            updateCode(value);
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        WatchUi.cancelAllAnimations();
    }

    function animateTOTP() as Void {
        var time = Time.now().value();
        var totpValue = Math.floor(time / _timeout);
        var totpTime = _timeout - Math.floor(time % _timeout);
        var initValue = totpTime.toFloat() / _timeout * 100;
        var progress = findDrawableById("innerCircle");
        updateCode(totpValue);
        animate(progress, :percents, ANIM_TYPE_LINEAR, initValue, 0, totpTime, method(:animateTOTP));
    }

    private function updateCode(totpValue as Number){
        var value = otpHmacSha1(_key, totpValue).format("%010d");
        var codeLabel = findDrawableById("code") as Text;
        codeLabel.setText(value.substring(10-_digits, 10));
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
