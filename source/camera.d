import vector : Vec3;
import ray : Ray;

struct Camera
{
    Vec3 position;
    Vec3 direction;
    Vec3 up;
    Vec3 right;
    double screenDistance;
    double screenHeight;
    double screenWidth;
    double imageHeight;
    double imageWidth;
    Vec3 screenCenter;
    uint superSamplingN;

    double subpixelHeight;
    double subpixelWidth;

    this(Vec3 position, Vec3 lookAt, Vec3 up, double screenDistance,
            double screenWidth, uint imageHeight, uint imageWidth, uint superSamplingN)
    {
        this.position = position;
        this.direction = position.directionTo(lookAt);
        this.right = up.cross(this.direction).normalize;
        this.up = right.cross(this.direction).normalize;
        this.screenDistance = screenDistance;
        this.screenWidth = screenWidth;
        this.screenHeight = screenWidth * (double(imageHeight) / double(imageWidth));
        this.imageHeight = imageHeight;
        this.imageWidth = imageWidth;
        this.screenCenter = position + direction * screenDistance;
        this.superSamplingN = superSamplingN;
        auto pixelWidth = screenWidth / double(imageWidth);
        auto pixelHeight = screenHeight / double(imageHeight);
        this.subpixelWidth = pixelWidth / superSamplingN;
        this.subpixelHeight = pixelHeight / superSamplingN;
    }

    SubpixelRange constructRaysThroughPixel(uint x, uint y)
    {
        return SubpixelRange(this, x, y);
    }

    double getRand() const
    {
        if (superSamplingN == 1)
        {
            return 0.5;
        }
        else
        {
            import std.random : uniform01;

            return uniform01();
        }
    }
}

struct SubpixelRange
{
    const Camera* camera;
    uint x;
    uint y;
    uint i;
    uint j;

    this(const ref Camera, uint x, uint y)
    {
        this.camera = camera;
        this.x = x;
        this.y = y;
        this.i = 0;
        this.j = 0;
    }

    bool empty() const @property
    {
        return i >= camera.superSamplingN;
    }

    void popFront()
    {
        j += 1;
        if (j > camera.superSamplingN)
        {
            i += 1;
            j = 0;
        }
    }

    Ray front() const @property
    {
        auto subpixelX = camera.superSamplingN * x + i;
        auto subpixelY = camera.superSamplingN * y + j;
        auto xOffset = camera.subpixelWidth * (double(subpixelX) + camera.getRand() - 0.5) - (
                double(camera.screenWidth) / 2.0);
        auto yOffset = camera.subpixelHeight * (double(subpixelY) + camera.getRand() - 0.5) - (
                double(camera.screenHeight) / 2.0);
        auto xDelta = camera.right * xOffset;
        auto yDelta = camera.up * yOffset;
        auto subcellPoint = camera.screenCenter + xDelta + yDelta;
        auto ray = Ray.constructRay(camera.position, subcellPoint);
        return ray;
    }
}
