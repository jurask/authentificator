import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.Timer;

(:glance)
class Glance extends WatchUi.GlanceView{
    private var _name as String;
    private var _account as String;
    private var _code as String;
    private var _timer as Timer.Timer;
    private var _otp as OtpCalc or Null;
    private var _live as Boolean;
    private var _lastTimeout as Number;

    function initialize(){
        GlanceView.initialize();
        _name = WatchUi.loadResource($.Rez.Strings.AppName).toUpper();
        _account = "";
        _code = "";
        _timer = new Timer.Timer();
        _live = Application.loadResource($.Rez.JsonData.liveGalnce) as Boolean;
        _otp = null;
        _lastTimeout = -2;
    }

    function onLayout(dc as Dc){
        var glance = Application.Properties.getValue("glance");
        if (glance){
            if (numAccounts() != 0){
                _otp = new OtpCalc(0);
                _account = _otp.name();
                updateCode();
            } else {
                _account = "No accounts defined";
                _code = "";
            }
            if (_live && _otp != null){
                if (_otp.type() == 0){
                    _timer.start(method(:timerCallback), 1000, true);
                }
            }
        } else {
            _account = "";
            _code = "";
        }
    }

    private function updateCode(){
        _code = _otp.code();
    }

    function timerCallback() as Void{
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc){
        // calculate all data
        var width = dc.getWidth();
        var height = dc.getHeight();
        var line = Graphics.getFontHeight(Graphics.FONT_GLANCE);
        var nlines = 2;
        if (_live && _otp != null){
            if (_otp.type() == 0){
                nlines = 3;
                var time = Time.now().value();
                var totpTime = _otp.timeout() - Math.floor(time % _otp.timeout());
                if (totpTime > _lastTimeout){
                    updateCode();
                }
                _lastTimeout = totpTime;
                var timeLeft = totpTime.toFloat() / _otp.timeout();
                dc.setPenWidth(1);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                dc.drawLine(width * timeLeft + 2, height / 2, width, height / 2);
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
                dc.setPenWidth(5);
                dc.drawLine(0, height / 2, width * timeLeft - 2, height / 2);
            }
        }
        // draw glance
        var space = (height - nlines * line) / 2;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(0, space, Graphics.FONT_GLANCE, _name, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(0, space + (nlines - 1) * line, Graphics.FONT_GLANCE, _account, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(width, space + (nlines - 1) * line, Graphics.FONT_GLANCE, _code, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    public function numAccounts() as Number{
        var accounts = Application.Properties.getValue("accounts");
        if (accounts != null){
            return accounts.size();
        }
        return 0;
    }

    function onHide() as Void{
        _timer.stop();
    }
}