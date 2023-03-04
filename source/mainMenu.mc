import Toybox.WatchUi;

class MainMenu extends WatchUi.ActionMenu {
    function initialize() {
        ActionMenu.initialize({:theme=>WatchUi.ACTION_MENU_THEME_DARK});
        var previous = WatchUi.loadResource(Rez.Strings.Previous);
        var next = WatchUi.loadResource(Rez.Strings.Next);
        addItem(new WatchUi.ActionMenuItem({:label=>next}, :next));
        addItem(new WatchUi.ActionMenuItem({:label=>previous}, :previous));
    }
}