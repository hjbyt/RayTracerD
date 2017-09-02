import vector : Vec3;
import model_object : ModelObject;
import ray : Ray;

struct Hit
{
    double distance;
    Vec3 hitNormal;
    Vec3 hitPoint;
    const ModelObject object;
    Vec3 directionToSource;

    this(Ray hitRay, double distance, Vec3 hitNormal, Vec3 hitPoint, const ModelObject object)
    {
        this.distance = distance;
        this.hitNormal = hitNormal;
        this.hitPoint = hitPoint;
        this.object = object;
        this.directionToSource = -hitRay.direction;
    }
}
