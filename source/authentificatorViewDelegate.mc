import Toybox.WatchUi;
import Toybox.Lang;

class AuthentificatorViewDelegate extends WatchUi.BehaviorDelegate{
    private var _accountNum as Number;

    function initialize(accountNum as Number) {
        System.println(accountNum);
        BehaviorDelegate.initialize();
        _accountNum = accountNum;
    }

    function onNextPage(){
        var totalAccounts = Application.getApp().numAccounts();
        var nextAccount = _accountNum + 1;
        if (nextAccount >= totalAccounts){
            nextAccount = 0;
        }
        WatchUi.cancelAllAnimations();
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
        WatchUi.cancelAllAnimations();
        WatchUi.switchToView(new AuthentificatorView(nextAccount), new AuthentificatorViewDelegate(nextAccount), WatchUi.SLIDE_DOWN);
        return true;
    }
}