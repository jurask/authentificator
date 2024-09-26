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
import Toybox.StringUtil;


function executeDecodeTest(decoded as String, encoded as String, logger as Logger) as Boolean {
    var options = {
        :fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
        :toRepresentation => StringUtil.REPRESENTATION_STRING_PLAIN_TEXT,
        :encoding => StringUtil.CHAR_ENCODING_UTF8
    };
    var bytes = decodeBase32(encoded);
    var asString = StringUtil.convertEncodedString(bytes, options) as String;
    logger.debug("decoded " + asString + " expected " + decoded);
    return asString.equals(decoded);
}

class Base32DecodeTest {
    (:test)
    public function f(logger as Logger) as Boolean {
        return executeDecodeTest("f", "MY======", logger);
    }

    (:test)
    public function fo(logger as Logger) as Boolean {
        return executeDecodeTest("fo", "MZXQ====", logger);
    }

    (:test)
    public function foo(logger as Logger) as Boolean {
        return executeDecodeTest("foo", "MZXW6===", logger);
    }

    (:test)
    public function foob(logger as Logger) as Boolean {
        return executeDecodeTest("foob", "MZXW6YQ=", logger);
    }

    (:test)
    public function fooba(logger as Logger) as Boolean {
        return executeDecodeTest("fooba", "MZXW6YTB", logger);
    }

    (:test)
    public function foobar(logger as Logger) as Boolean {
        return executeDecodeTest("foobar", "MZXW6YTBOI======", logger);
    }
}