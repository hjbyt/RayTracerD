struct Color_(T)
{
    T[3] data;
    alias data this;

    this(const ref T[3] data)
    {
        this.data = data;
    }

    this(const T[3] data...)
    {
        this.data = data;
    }

    this(T value)
    {
        T[3] data = value;
        this(data);
    }

    static immutable Color black = Color(0);

    @property T r() const
    {
        return data[0];
    }

    @property void r(T t)
    {
        data[0] = t;
    }

    @property T g() const
    {
        return data[1];
    }

    @property void g(T t)
    {
        data[1] = t;
    }

    @property T b() const
    {
        return data[2];
    }

    @property void b(T t)
    {
        data[2] = t;
    }

    bool opCast(T)() const if (is(T == bool))
    {
        return r != 0 || g != 0 || b != 0;
    }

    Color opBinary(string op)(const ref Color rhs) const if (op == "+" || op == "*")
    {
        T[3] result = mixin("this[]" ~ op ~ "rhs[]");
        return Color(result);
    }

    Color opBinary(string op)(Color rhs) const if (op == "+" || op == "*")
    {
        T[3] result = mixin("this[]" ~ op ~ "rhs[]");
        return Color(result);
    }

    Color opBinary(string op)(T rhs) const if (op == "*" || op == "/")
    {
        T[3] result = mixin("this[]" ~ op ~ "rhs");
        return Color(result);
    }

    Color opBinaryRight(string op)(T lhs) const if (op == "*")
    {
        T[3] result = lhs * this[];
        return Color(result);
    }

    void opOpAssign(string op)(Color rhs) if (op == "+" || op == "*")
    {
        mixin("this.data[] " ~ op ~ "= rhs.data[];");
    }

    void opOpAssign(string op)(T rhs) if (op == "*" || op == "/")
    {
        mixin("this.data[] " ~ op ~ "= rhs;");
    }

    ref Color clamp()
    {
        import std.algorithm;

        r = r.max(0).min(1);
        g = g.max(0).min(1);
        b = b.max(0).min(1);
        return this;
    }

    Color clamped() const
    {
        import std.algorithm;

        return Color(r.max(0).min(1), g.max(0).min(1), b.max(0).min(1));
    }

    ubyte[3] bytes() const
    {
        import std.math;

        auto c = clamped * T(255);
        return [cast(ubyte) c.r.lrint, cast(ubyte) c.g.lrint, cast(ubyte) c.b.lrint];
    }
}

alias Color = Color_!double;
