import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application;

class AuthentificatorViewDelegate extends WatchUi.BehaviorDelegate{
    private var _accountNum as Number;

    function initialize(accountNum as Number) {
        BehaviorDelegate.initialize();
        _accountNum = accountNum;
    }

    public function onNextPage() as Boolean {
        var totalAccounts = Application.getApp().numAccounts();
        var nextAccount = _accountNum + 1;
        if (nextAccount >= totalAccounts){
            nextAccount = 0;
        }
        WatchUi.switchToView(new AuthentificatorView(nextAccount), new AuthentificatorViewDelegate(nextAccount), WatchUi.SLIDE_UP);
        return true;
    }

    public function onPreviousPage() as Boolean {
        var totalAccounts = Application.getApp().numAccounts();
        var nextAccount = _accountNum - 1;
        if (nextAccount >= totalAccounts){
            nextAccount = 0;
        } else if (nextAccount < 0){
            nextAccount = totalAccounts - 1;
        }
        WatchUi.switchToView(new AuthentificatorView(nextAccount), new AuthentificatorViewDelegate(nextAccount), WatchUi.SLIDE_DOWN);
        return true;
    }

    public function onSelect() as Boolean {
        var accounts = Application.Properties.getValue("accounts");
        var type = (accounts as Array<Dictionary<String, String or Number>>)[_accountNum]["type"];
        if (type == 1){
            WatchUi.showActionMenu(new $.MainMenu(), new $.MenuDelegate(_accountNum));
            return true;
        } else {
            return false;
        }
    }
}