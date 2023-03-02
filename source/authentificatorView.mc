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
}
