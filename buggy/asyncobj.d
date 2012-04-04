
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
        Msg!T msg;
        msg.stop = false;
        Tid me = thisTid;
        msg.func = (T o) {
            mixin("o."~name~"(args);");
        };
        send(tid, msg);
    }
    
    private Tid tid;
    private bool stopped;
}

bool stopped(T)(AsynchronousObject!T aso) {
    return aso.stopped;
}

void stop(T)(AsynchronousObject!T aso) {
    assert(!stopped(aso));
    send(aso.tid, Msg!T(true, (T o) {}));
}

private:

struct Msg(T) {
    bool stop;
    void delegate(T) func;
}

struct ReturnMsg(T) {
    T r;
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
            auto str = receiveNext!string();
            writeln("received str standard way: ", str);
        }
        
        void method(string str) {
            writeln("other way: ", str);
        }
        
        int newMethod() {
            writeln("new methoding");
            return 3;
        }
        
        int prop;
    }
    
    T receiveNext(T)() {
        T r;
        receive((T t) {r = t;});
        return r;
    }
}

unittest {
    auto fc = spawnAsynchronousObject!(FiboCalculator)(2);
    fc.hiWorld();
    stop(fc);
    
    // /+ doesn't work
    auto alt = spawnAsynchronousObject!(Alt)(thisTid);
    auto altid = receiveNext!Tid();
    alt.method("asyncobj");
    send(altid, "standard");
    alt.newMethod();
    writeln(alt.prop);
    stop(alt);
    // +/
}

