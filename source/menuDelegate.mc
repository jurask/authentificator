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
        var dict = accounts[_accountNum] as Dictionary<String, Number or String>;
        var counter = dict["timeout"];
        dict["timeout"] = counter + delta;
        accounts[_accountNum] = dict;
        Application.Properties.setValue("accounts", accounts);
        WatchUi.getCurrentView()[0].onShow();
    }
}
