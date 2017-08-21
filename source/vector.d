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

    T dot(const ref Vector other) const
    {
        import std.range : zip;
        import std.algorithm : map, sum;

        return zip(data[0 .. $], other.data[0 .. $]).map!"a[0]*a[1]".sum;
    }

    static if (n == 3)
    {
        Vector cross(const ref Vector other)
        {
            auto x = this.y * other.z - this.z * other.y;
            auto y = other.x * this.z - other.z * this.x;
            auto z = this.x * other.y - this.y * other.x;
            return Vector(x, y, z);
        }
    }
}

alias Vec3 = Vector!(double, 3);
