import Toybox.WatchUi;

class AuthentificatorViewDelegate extends WatchUi.BehaviorDelegate{
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onNextPage(){
        System.println("next");
        WatchUi.switchToView(new AuthentificatorView(), new AuthentificatorViewDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onPreviousPage(){
        System.println("previous");
        WatchUi.switchToView(new AuthentificatorView(), new AuthentificatorViewDelegate(), WatchUi.SLIDE_DOWN);
        return true;
    }
}