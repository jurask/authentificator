import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class authentificatorApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        updateKeys();
        if (numAccounts() != 0){
            return [ new AuthentificatorView(0), new AuthentificatorViewDelegate(0) ] as Array<Views or InputDelegates>;
        }
        return [ new NoAccountsView() ] as Array<Views or InputDelegates>;
    }

    (:glance)
    function getGlanceView() as Lang.Array<WatchUi.GlanceView> or Null{
        updateKeys();
        return [new Glance()];
    }

    public function numAccounts() as Number{
        var accounts = Application.Properties.getValue("accounts");
        if (accounts != null){
            return accounts.size();
        }
        return 0;
    }

    public function onSettingsChanged(){
        updateKeys();
        var view = WatchUi.getCurrentView();
        if (view[0] instanceof AuthentificatorView){
            if (numAccounts() != 0){
                WatchUi.switchToView(new AuthentificatorView(0), new AuthentificatorViewDelegate(0), WatchUi.SLIDE_BLINK);
            } else {
                WatchUi.switchToView(new NoAccountsView(), null, WatchUi.SLIDE_BLINK);
            }
        }
    }

    private function updateKeys(){
        var accounts = Application.Properties.getValue("accounts");
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

function getApp() as authentificatorApp {
    return Application.getApp() as authentificatorApp;
}