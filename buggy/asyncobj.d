
module dcaflib.concurrency.asyncobj;

private {
    import std.concurrency;
    import std.traits;
    import std.variant;
}

public:
AsynchronousObject!T spawnAsynchronousObject(T, A...)(A arguments) 
        if (isObject!T) {
    Tid child = spawn(&objThread!(T, A), arguments);
    AsynchronousObject!T r;
    r.tid = child;
    return r;
}

struct AsynchronousObject(T) if (isObject!T) {
    
    void opDispatch(string name, A...)(A args) {
        auto msg = Msg!T(false, (T o) { mixin("o."~name~"(args);"); });
        send(tid, msg);
    }
    
    private Tid tid;
}

void stop(T)(AsynchronousObject!T aso) {
    send(aso.tid, Msg!T(true, (T o) {}));
}

private:

struct Msg(T) {
    bool stop;
    void delegate(T) func;
}

void objThread(T, A...)(A args) if (isObject!T) {
    T obj = new T(args);
    bool cont = true;
    while(cont) {
        receive(
            (Msg!T msg) {
                if (msg.stop) {
                    cont = false;
                } else {
                    msg.func(obj);
                }
            }
        );
    }
}

template isObject(T) { enum isObject = is(T : Object); }

version (unittest) {
    import std.stdio;

    class FiboCalculator {
        this(int arg) {
            std.stdio.writeln("creating fiboCalculator with ", arg);
        }
    
        void hiWorld() {
            std.stdio.writeln("hello world");
        }
    }

    class Alt {
        this(Tid tid) {
            send(tid, thisTid);
            auto str = receiveOnly!string();
            writeln("received str standard way: ", str);
        }
        
        void method(string str) {
            writeln("other way: ", str);
        }
    }
}

unittest {
    auto fc = spawnAsynchronousObject!(FiboCalculator)(2);
    fc.hiWorld();
    stop(fc);
    
    /+ doesn't work
    auto alt = spawnAsynchronousObject!(Alt)(thisTid);
    auto altid = receiveOnly!Tid();
    alt.method("standard");
    send(altid, "asyncobj");
    stop(alt);
    +/
}

