import vector;

struct Ray
{
    Vec3 position;
    Vec3 direction;

    this(Vec3 position, Vec3 direction)
    {
        this.position = position;
        this.direction = direction;
    }

    static Ray construct_ray(Vec3 from, Vec3 to)
    {
        return Ray(from, from.directionTo(to));
    }

    void advance(double by)
    {
        this.position += this.direction * by;
    }
}
