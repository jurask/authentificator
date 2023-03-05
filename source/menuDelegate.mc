import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Input handler to respond to main menu selections
class MenuDelegate extends WatchUi.ActionMenuDelegate {
    private var _accountNum as Lang.Number;

    //! Constructor
    public function initialize(accountNum as Number) {
        ActionMenuDelegate.initialize();
        _accountNum = accountNum;
    }

    //! Handle a menu item being selected
    //! @param item Symbol identifier of the menu item that was chosen
    public function onSelect(item as WatchUi.MenuItem) as Void {
        if (item.getId() == :next) {
            modifyCounter(1);
        } else if (item.getId() == :previous) {
            modifyCounter(-1);
        }
    }

    private function modifyCounter(delta as Number){
        var accounts = Application.Properties.getValue("accounts");
        var timeout = (accounts as Array<Dictionary<String, String or Number>>)[_accountNum]["timeout"];
        if (timeout == null){
            timeout = 0;
        }
        timeout = timeout + delta;
        if(timeout < 0){
            timeout = 0;
        }
        (accounts as Array<Dictionary<String, String or Number>>)[_accountNum].put("timeout", timeout);
        Application.Properties.setValue("accounts", accounts);
        WatchUi.getCurrentView()[0].onShow();
    }
}
