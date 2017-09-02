import model_object : ModelObject;
import material : Material;
import hit : Hit;
import ray : Ray;
import vector : Vec3;
import std.typecons : Nullable, nullable;

class Plane : ModelObject
{
    private Material _material;
    Vec3 normal;
    double offset;

    this(Material material, Vec3 normal, double offset)
    {
        this._material = material;
        this.normal = normal;
        this.offset = offset;
    }

    override Material material()
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
        auto hitPoint = ray.position + (t * ray.direction);
        auto hitNormal = cosAngle > 0 ? -normal : normal;
        return Hit(ray, t, hitNormal, hitPoint, this).nullable;
    }
}
