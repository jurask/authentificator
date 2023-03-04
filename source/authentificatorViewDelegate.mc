import Toybox.WatchUi;
import Toybox.Lang;

class AuthentificatorViewDelegate extends WatchUi.BehaviorDelegate{
    private var _accountNum as Number;

    function initialize(accountNum as Number) {
        BehaviorDelegate.initialize();
        _accountNum = accountNum;
    }

    function onNextPage(){
        var totalAccounts = Application.getApp().numAccounts();
        var nextAccount = _accountNum + 1;
        if (nextAccount >= totalAccounts){
            nextAccount = 0;
        }
        WatchUi.switchToView(new AuthentificatorView(nextAccount), new AuthentificatorViewDelegate(nextAccount), WatchUi.SLIDE_UP);
        return true;
    }

    function onPreviousPage(){
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

    function onSelect(){
        var accounts = Application.Properties.getValue("accounts");
        var type = (accounts[_accountNum] as Dictionary<String, Number or String>)["type"];
        if (type == 1){
            WatchUi.pushView(new $.Rez.Menus.MainMenu(), new $.MenuDelegate(_accountNum), WatchUi.SLIDE_LEFT);
            return true;
        } else {
            return false;
        }
    }
}