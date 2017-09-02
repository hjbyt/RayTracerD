import vector : Vec3;

struct Ray
{
    Vec3 position;
    Vec3 direction;

    this(Vec3 position, Vec3 direction)
    {
        import utils : almostEq;
        assert(direction.norm.almostEq(1));
        this.position = position;
        this.direction = direction;
    }

    static Ray constructRay(Vec3 from, Vec3 to)
    {
        return Ray(from, from.directionTo(to));
    }

    void advance(double by)
    {
        this.position += this.direction * by;
    }
}
