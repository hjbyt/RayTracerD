import model_object : ModelObject;
import material : Material;
import hit : Hit;
import ray : Ray;
import vector : Vec3;
import std.typecons : Nullable, nullable;

class Triangle : ModelObject
{
    private Material _material;
    Vec3 v1;
    Vec3 v2;
    Vec3 v3;

    private Vec3 normal;
    private double offset;

    this(Material material, Vec3 v1, Vec3 v2, Vec3 v3)
    {
        this._material = material;
        auto s1 = v2 - v1;
        auto s2 = v3 - v1;
        this._material = material;
        this.v1 = v1;
        this.v2 = v2;
        this.v3 = v3;
        this.normal = s1.cross(s2).normalized();
        this.offset = this.normal * v1;
    }

    override Material material() const
    {
        return _material;
    }

    override Nullable!Hit tryHit(const ref Ray ray) const
    {
        auto cosAngle = normal * ray.direction;
        if (cosAngle == 0)
        {
            return Nullable!Hit.init;
        }
        auto t = (offset - (ray.position * normal)) / cosAngle;
        if (t < 0)
        {
            return Nullable!Hit.init;
        }

        auto hitPoint = ray.position + ray.direction * t;
        auto in1 = checkVecAbovePlane(ray.direction, ray.position, v1, v2, v3);
        auto in2 = checkVecAbovePlane(ray.direction, ray.position, v2, v3, v1);
        auto in3 = checkVecAbovePlane(ray.direction, ray.position, v3, v1, v2);
        if (!(in1 && in2 && in3))
        {
            return Nullable!Hit.init;
        }
        auto hitNormal = cosAngle > 0 ? -normal : normal;

        return Hit(ray, t, hitNormal, hitPoint, this).nullable;
    }
}

bool checkVecAbovePlane(const ref Vec3 vec, const ref Vec3 p1, const ref Vec3 p2,
        const ref Vec3 p3, const ref Vec3 referencePoint)
{
    auto v1 = p2 - p1;
    auto v2 = p3 - p1;
    auto n = v2.cross(v1).normalize;
    if (n * (referencePoint - p1) < 0)
    {
        n *= -1;
    }
    return (vec * n) >= 0;

}
