
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
        static if (true) {
            struct Caller {
                void call(T o, Variant va) {
                    A a = va.peek!(A);
                    mixin("o."~name~"(a);");
                }
            }
            Variant f = Caller();
            Variant a = args;
            send(tid, f, a);
        } else static assert(0, "asyncobj doesn't work with non-void yet");
    }
    
    private Tid tid;
}

void stop(T)(AsynchronousObject!T aso) {
    send(aso.tid, false);
}

private:
void objThread(T, A...)(A args) if (isObject!T) {
    T obj = new T(args);
    bool cont = true;
    while(cont) {
        receive(
            (bool b) { cont = false; },
            (Variant f, Variant a) {
                f.call(obj, a);
            }
        );
    }
}

template isObject(T) { enum isObject = is(T : Object); }

version (unittest)
    class FiboCalculator {
        this(int arg) {
            std.stdio.writeln("creating fiboCalculator with ", arg);
        }
    
        void hiWorld() {
            std.stdio.writeln("hello world");
        }
    }

unittest {
    auto fc = spawnAsynchronousObject!(FiboCalculator)(2);
    fc.hiWorld();
    stop(fc);
}

void main(){}
