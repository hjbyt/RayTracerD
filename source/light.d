import color : Color;
import vector : Vec3;

struct Light
{
    Vec3 position;
    Color color;
    double specularIntensity;
    double shadowIntensity;
    double radius;

    this(Vec3 position, Color color, double specularIntensity, double shadowIntensity, double radius)
    {
        assert(0 <= shadowIntensity && shadowIntensity <= 1);
        this.position = position;
        this.color = color;
        this.shadowIntensity = shadowIntensity;
        this.radius = radius;
    }
}
