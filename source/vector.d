struct Vector(T, int n)
{
    T[n] data;
    alias data this;

    this(T[n] data)
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

    @property T x()
    {
        return data[0];
    }

    @property void x(T t)
    {
        data[0] = t;
    }

    @property T y()
    {
        return data[1];
    }

    @property void y(T t)
    {
        data[1] = t;
    }

    @property T z()
    {
        return data[2];
    }

    @property void z(T t)
    {
        data[2] = t;
    }
}

alias Vec3 = Vector!(real, 3);
