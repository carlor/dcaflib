/++
 + terminal.d contains functions for styling the terminal. Currently, only 
 + foreground text color on Posix is implemented, though more is planned.
 +
 + Copyright: (C) 2012 Nathan M. Swan
 + Author: Nathan M. Swan, aka carlor
 + License: Boost Software License - Version 1.0
 + 
 + Permission is hereby granted, free of charge, to any person or organization
 + obtaining a copy of the software and accompanying documentation covered by
 + this license (the "Software") to use, reproduce, display, distribute,
 + execute, and transmit the Software, and to prepare derivative works of the
 + Software, and to permit third-parties to whom the Software is furnished to
 + do so, all subject to the following:
 +
 + The copyright notices in the Software and this entire statement, including
 + the above license grant, this restriction and the following disclaimer,
 + must be included in all copies of the Software, in whole or in part, and
 + all derivative works of the Software, unless such copies or derivative
 + works are solely in the form of machine-executable object code generated by
 + a source language processor.
 +
 + THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 + IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 + FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
 + SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
 + FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 + ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 + DEALINGS IN THE SOFTWARE.
 +/


module dcaflib.ui.terminal;

version (Posix) version = tbash;

version (tbash) {
    import std.stdio;
} else {
    static assert(0, "dcaflib.ui.terminal is unsupported on your system");
}


version (unittest) import std.stdio;


public:
/// Gets the foreground color.
@property TermColor fgColor() {
    return fg;
}

/// Sets the foreground color.
@property void fgColor(TermColor tc) {
    fg = tc;
    update();
}

/// Colors supported by the terminals. They are not guaranteed to be the same
/// on all platforms, but they should be similar.
enum TermColor {
    DEFAULT,
    BLUE,
    CYAN,
    GREEN,
    YELLOW,
    RED,
    PURPLE,
    BLACK,
    WHITE,
}

private:

static ~this() {
    fgColor = TermColor.DEFAULT;
}

void update() {
    version (tbash) {
        writef("\033[0m");
        if (fg != TermColor.DEFAULT) {
            writef("\033[3%dm", colorCode(fg));
        }
    }
}

version (tbash) uint colorCode(TermColor tc) {
    switch (tc) {
        case TermColor.BLUE: return 4;
        case TermColor.CYAN: return 6;
        case TermColor.GREEN: return 2;
        case TermColor.YELLOW: return 3;
        case TermColor.RED: return 1;
        case TermColor.PURPLE: return 5;
        case TermColor.BLACK: return 0;
        case TermColor.WHITE: return 7;
        default:
            assert(0, "unknown color code");
    }
}

TermColor fg;

unittest {
    fgColor = TermColor.RED;
    writeln("this is red!");
    fgColor = TermColor.BLUE;
    writeln("this is blue!");
}

