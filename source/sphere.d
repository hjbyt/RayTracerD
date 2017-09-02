import model_object : ModelObject;
import material : Material;
import hit : Hit;
import ray : Ray;
import vector : Vec3;
import std.typecons : Nullable, nullable;

class Sphere : ModelObject
{
    private Material _material;
    Vec3 center;
    double radius;

    this(Material material, Vec3 center, double radius)
    {
        this._material = material;
        this.center = center;
        this.radius = radius;
    }

    override Material material()
    {
        return _material;
    }

    override Nullable!Hit tryHit(const ref Ray ray) const
    {
        // Geometric method
        auto el = center - ray.position;
        auto t_ca = el * ray.direction;
        if (t_ca < 0)
        {
            return Nullable!Hit.init;
        }
        auto dSquare = el.normSquared - (t_ca ^^ 2);
        auto rSquare = radius ^^ 2;
        if (dSquare > rSquare)
        {
            return Nullable!Hit.init;
        }
        import std.math : sqrt;

        auto t_hc = (rSquare - dSquare).sqrt;
        double distance_near = t_ca - t_hc;
        if (distance_near < 0)
        {
            return Nullable!Hit.init;
        }
        Vec3 hitPoint = ray.position + ray.direction * distance_near;
        Vec3 hitNormal = center.directionTo(hitPoint);
        Hit hit = Hit(ray, distance_near, hitNormal, hitPoint, this);
        return hit.nullable;
    }
}
