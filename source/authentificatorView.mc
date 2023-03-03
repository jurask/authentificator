import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Math;

class AuthentificatorView extends WatchUi.View {
    private var _accountName as String;
    private var _type as Number;
    private var _timeout as Number;

    function initialize(accountNum as Number) {
        View.initialize();
        var accounts = Application.Properties.getValue("accounts");
        _accountName = (accounts[accountNum] as Dictionary<String, Number or String>)["name"];
        _type = (accounts[accountNum] as Dictionary<String, Number or String>)["type"];
        _timeout = (accounts[accountNum] as Dictionary<String, Number or String>)["timeout"];
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
            animateTOTP();
        } else {
            var progress = findDrawableById("innerCircle");
            progress.setVisible(false);
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
        animate(progress, :percents, ANIM_TYPE_LINEAR, initValue, 0, totpTime, method(:animateTOTP));
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
