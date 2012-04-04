
module dcaflib.concurrency.queue;

public:
class SynchronizedQueue(T) {
    this(A...)(A args) {
        head = new ArrayObject!T();
        tail = new ArrayObject!T();
        foreach(a; args) {
            static assert(is(typeof(a) : T));
            put(a);
        }
    }
    
    void put(T t) {
        synchronized (tail) {
            tail ~= t;
        }
    }
    
    @property bool empty() {
        synchronized (this) {
            return !(head.length || tail.length);
        }
    }
    
    @property T front() {
        synchronized (head) {
            transfer();
            return head[0];
        }
    }
    
    void popFront() {
        synchronized (head) {
            transfer();
            head = head[1 .. $];
        }
    }
    
    private:
    
    // note: head must be synchronized
    void transfer() {
        if (!head.length) {
            synchronized (this) {
                head = tail;
                tail = new ArrayObject!T();
            }
        }
    }

    ArrayObject!T head;
    ArrayObject!T tail;
}

public:
class MessageQueue(T) : SynchronizedQueue!T {
    this(A...)(A args) {
        super(args);
    }
    
    @property override bool empty() { return false; }
    
    @property override T front() {
        synchronized (head) {
            while (!super.empty) {}
            return head[0];
        }
    }

}

private:
class ArrayObject(T) {
    T[] arr;
    alias arr this;
}

version (unittest) {
    import std.concurrency;
    
    alias MessageQueue!(string) Msq;
    
    void fn(Msq msq) {
        msq.put("num1");
        msq.put("num2");
        msq.put("TERMIN");
    }
}

unittest {
    shared Msq mq = new Msq();
    auto tid = spawn(&fn, mq);
    foreach(str; mq) {
        writeln("received ", str);
        if (str == "TERMIN") break;
    }
}



