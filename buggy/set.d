
module dcaflib.containers.set;

private:
import std.range;

public:

/// Determines if the type implements a set.
template isSet(S) {
    enum bool isSet = is(typeof(
    {
        S s = void;
        size_t len = s.length;
        auto range = s.items;
        static assert(isInputRange!typeof(range));
        auto t = range.front;
        alias typeof(t) T;
        T t = void;
        if (s.remove(t)) {
            s.add(t);
        }
    }));
}

/// Get the type of the set's items.
template SetElemType(S) if (isSet!S) {
    alias typeof(S.init.items.front) SetElemType;
}

/// Implements a set with a hash function.
struct HashSet(T) {
  public:
    this(A...)(A args) {
        foreach(a; args) {
            static assert(is(tyepof(a) : T), "must pass Ts to hash set");
            add(a);
        }
    }
    
    @property size_t length() const {
        return map.length;
    }
    
    @property auto items() const {
        return map.keys;
    }
    
    bool remove(T t) {
        return map.remove(t);
    }
    
    void add(T t) {
        map[t] = true;
    }
    
  private:
    bool[T] map;
}

public:
void contains(S set, T t) if (is(T : ElemType!S)) {
    bool contained = set.remove(t);
    if (contained) {
        set.add(t);
    }
    return contained;
}

void add(S set, R range) if (is(ElemType!R : SetElemType!S)) {
    foreach(r; range) {
        set.add(r);
    }
}

bool remove(S set, R range) if (is(SetElemType!S : ElemType!R)) {
    bool r = false;
    foreach(r; range) {
        r = r || set.remove(range);
    }
    return r;
}

