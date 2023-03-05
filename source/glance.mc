import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;

(:glance)
class Glance extends WatchUi.GlanceView{
    private var _name as String;
    private var _account as String;
    private var _code as String;

    function initialize(){
        GlanceView.initialize();
        _name = WatchUi.loadResource($.Rez.Strings.AppName).toUpper();
        _account = "";
        _code = "";
    }

    function onLayout(dc as Dc){
        var glance = Application.Properties.getValue("glance");
        if (glance){
            if (numAccounts() != 0){
                var otp = new OtpCalc(0);
                _account = otp.name();
                _code = otp.code();
            } else {
                _account = "No accounts defined";
                _code = "";
            }
        } else {
            _account = "";
            _code = "";
        }
    }

    function onUpdate(dc as Dc){
        // draw glance
        var width = dc.getWidth();
        var height = dc.getHeight();
        var line = Graphics.getFontHeight(Graphics.FONT_GLANCE);
        var space = (height - 2 * line) / 2;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(0, space, Graphics.FONT_GLANCE, _name, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(0, space + line, Graphics.FONT_GLANCE, _account, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(width, space + line, Graphics.FONT_GLANCE, _code, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    public function numAccounts() as Number{
        var accounts = Application.Properties.getValue("accounts");
        if (accounts != null){
            return accounts.size();
        }
        return 0;
    }
}