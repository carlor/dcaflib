
// Written in the D Programming Language

/**
 * json.d contains functions and classes for reading, parsing, and writing JSON
 * documents. It is adapted from LibDJSON:
 *      $(LINK https://256.makerslocal.org/wiki/index.php/Libdjson)
 *
 * Copyright:
 *      (c) 2009 William K. Moore, III 
 *      (nyphbl8d (at) gmail (dot) com, opticron on freenode)
 * Authors:
 *      William K. Moore, III (original author of LibDJSON)
 *      Nathan M. Swan (added motifications)
 *
 * License:	Boost Software License - Version 1.0 - August 17th, 2003
 * 
 * Permission is hereby granted, free of charge, to any person or organization
 * obtaining a copy of the software and accompanying documentation covered by
 * this license (the "Software") to use, reproduce, display, distribute,
 * execute, and transmit the Software, and to prepare derivative works of the
 * Software, and to permit third-parties to whom the Software is furnished to
 * do so, all subject to the following:
 *
 * The copyright notices in the Software and this entire statement, including
 * the above license grant, this restriction and the following disclaimer,
 * must be included in all copies of the Software, in whole or in part, and
 * all derivative works of the Software, unless such copies or derivative
 * works are solely in the form of machine-executable object code generated by
 * a source language processor.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
 * SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
 * FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * Standards: Attempts to conform to the subset of Javascript required to 
 * implement the JSON Specification.
 */

module dcaflib.text.json;

private:
import std.traits;
import std.uni;

public:

/// Thrown when parsing goes wrong.
class JSONException : Exception {
	this(string msg) {
		super(msg);
	}
}

/// Thrown when enforceType fails.
class JSONTypeException : JSONException {
    this(string msg) {
        super(msg);
    }
}

/// Represents any JSONValue.
abstract class JSONValue {
    abstract string toString(bool prettify=false);
    
    JSONValue parse(string str) {
        removePrefixedWhitespace(str);
        switch (str[0]) {
            case '{': return readObject(str);
            case '[': return readArray(str);
            case '"': return readString(str);
            case '-','0','1','2','3','4','5','6','7','8','9': 
                return readNumber(str);
            default:
                return readKeyword(str);
        }
        return null;
    }
}

private:
JSONObject readObject(string str) {
    assert(str[0] == '{');
    str = str[1 .. $];
    while(true) {
        removePrefixedWhitespace(str);
        if (str.length) {
        
        }
    }
}


// " whatever" -> "whatever", "  " -> ""
void removePrefixedWhitespace(ref string str) {
    foreach(i, dchar c; str) {
        if (!isWhite(c)) {
            str = str[i .. $];
            return;
        }
    }
    str = "";
}

