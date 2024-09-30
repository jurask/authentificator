/*
    OTP Keychain for Garmin watches
    Copyright (C) 2023-2024 Jiri Babocky

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import Toybox.Lang;
import Toybox.Test;

function executeOtpTest(keyStr as String, code as String, message as Number, logger as Logger) as Boolean {
    var key = decodeBase32(keyStr);
    var calculator = new OtpCalc(key, code.length());
    var calculated = calculator.code(message);
    logger.debug("calculated " + calculated + " expected " + code);
    return calculated.equals(code);
}

class OTPCalcTest {
    (:test)
    public function test1(logger as Logger) as Boolean {
        return executeOtpTest("4AML523IDVG2KNSPLYCGVRTPCL5SSHOX", "851646", 12345, logger);
    }

    (:test)
    public function test2(logger as Logger) as Boolean {
        return executeOtpTest("VDIAHRITHA43ITS5XLVOETUAHZIQOQNA", "654174", 9875412, logger);
    }
}