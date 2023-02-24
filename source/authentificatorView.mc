import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class AuthentificatorView extends WatchUi.View {
    private var _accountName as String;

    function initialize(accountNum as Number) {
        View.initialize();
        var accounts = Application.Properties.getValue("accounts");
        _accountName = (accounts[accountNum] as Dictionary<String, String or Number>)["name"];
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        dc.setColor(0xFFFFFF, 0x000000);
        // Draw account name
        dc.drawText(dc.getWidth()/2, 0.7*dc.getHeight(), Graphics.FONT_SMALL, _accountName, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setPenWidth(6);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2-6, Graphics.ARC_COUNTER_CLOCKWISE, 75, 10);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
