struct Vector(T, int n)
{
    T[n] data;
    alias data this;

    this(const ref T[n] data)
    {
        this.data = data;
    }

    this(const T[n] data...)
    {
        this.data = data;
    }

    this(T value)
    {
        T[n] data = new T[n];
        data[] = value;
        this(data);
    }

    static zero()
    {
        return Vector(0);
    }

    @property T x() const
    {
        return data[0];
    }

    @property void x(T t)
    {
        data[0] = t;
    }

    @property T y() const
    {
        return data[1];
    }

    @property void y(T t)
    {
        data[1] = t;
    }

    @property T z() const
    {
        return data[2];
    }

    @property void z(T t)
    {
        data[2] = t;
    }

    //TODO: change to an implementation without ranges, as optimization?
    T dot(const ref Vector other) const
    {
        import std.range : zip;
        import std.algorithm : map, sum;

        return zip(data[], other.data[]).map!"a[0]*a[1]".sum;
    }

    static if (n == 3)
    {
        Vector cross(const ref Vector other) const
        {
            immutable x = this.y * other.z - this.z * other.y;
            immutable y = other.x * this.z - other.z * this.x;
            immutable z = this.x * other.y - this.y * other.x;
            return Vector(x, y, z);
        }
    }

    Vector opUnary(string op)() const
    {
        static if (op == "+")
        {
            return this;
        }
        else static if (op == "-")
        {
            T[n] new_data = -data[];
            return Vector(new_data);
        }
        else
        {
            static assert(0, "Operator " ~ op ~ " not implemented");
        }

    }

    Vector opBinary(string op)(const ref Vector rhs) const if (op == "+" || op == "-")
    {
        T[n] result = mixin("this[]" ~ op ~ "rhs[]");
        return Vector(result);
    }

    T opBinary(string op)(const ref Vector rhs) const if (op == "*")
    {
        return this.dot(rhs);
    }

    Vector opBinary(string op)(T rhs) const if (op == "*" || op == "/")
    {
        T[n] result = mixin("this[]" ~ op ~ "rhs");
        return Vector(result);
    }

    Vector opBinaryRight(string op)(T lhs) const if (op == "*")
    {
        T[n] result = lhs * this[];
        return Vector(result);
    }

    void opOpAssign(string op)(Vector rhs) if (op == "+" || op == "-")
    {
        mixin("this.data[] " ~ op ~ "= rhs.data[];");
    }

    void opOpAssign(string op)(T rhs) if (op == "*" || op == "/")
    {
        mixin("this.data[] " ~ op ~ "= rhs;");
    }

    T norm_squared() const
    {
        return this * this;
    }

    T norm() const
    {
        import std.math : sqrt;

        return sqrt(norm_squared);
    }
}

alias Vec3 = Vector!(double, 3);
