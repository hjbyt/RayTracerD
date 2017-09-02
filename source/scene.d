import vector : Vec3;
import camera : Camera;
import color : Color;
import model_object : ModelObject;
import material : Material;
import sphere : Sphere;
import plane : Plane;
import triangle : Triangle;
import image : Image;
import ray : Ray;
import light : Light;
import hit : Hit;
import std.conv : to;

//TODO: import only specific names
import utils;
import std.math;
import std.algorithm;

immutable RAY_SMALL_ADVANCEMENT = 0.000000001;

struct Scene
{
    Color backgroundColor;
    uint shadowRaysN;
    uint maxRecursion;
    uint superSamplingN;
    ModelObject[] objects;
    Camera camera;
    Light[] lights;

    static Scene fromFile(const string path)
    {
        import std.stdio;
        import std.string;
        import std.ascii : isWhite;
        import std.array;
        import std.typecons : Nullable, nullable, tuple;
        import std.exception : enforce;

        Nullable!Camera camera;
        Nullable!Color backgroundColor;
        Nullable!uint shadowRaysN;
        Nullable!uint maxRecursion;
        Nullable!uint superSamplingN;
        Material[] materials;
        ModelObject[] objects;
        Light[] lights;

        auto file = File(path, "r");
        foreach (string line; lines(file))
        {
            line = line.strip;
            if (line.empty || line.startsWith("#"))
            {
                continue;
            }
            auto parts = line.split();
            auto itemType = parts.pop();
            switch (itemType)
            {
            case "cam":
                //TODO: parse image size from file
                //TODO: restore default image size to 500x500
                camera = Camera(parts.parseVec3, parts.parseVec3, parts.parseVec3,
                        parts.parseDouble, parts.parseDouble, 50, 50, 1).nullable;
                break;
            case "set":
                backgroundColor = parts.parseColor.nullable;
                shadowRaysN = parts.parseUint.nullable;
                maxRecursion = parts.parseUint.nullable;
                superSamplingN = parts.parseUint.nullable;
                break;
            case "mtl":
                materials ~= Material(parts.parseColor, parts.parseColor,
                        parts.parseColor, parts.parseDouble, parts.parseDouble);
                break;
            case "sph":
                auto center = parts.parseVec3;
                auto radius = parts.parseDouble;
                auto material = materials[parts.parseUint - 1];
                objects ~= new Sphere(material, center, radius);
                break;
            case "pln":
                auto normal = parts.parseVec3;
                auto offset = parts.parseDouble;
                auto material = materials[parts.parseUint - 1];
                objects ~= new Plane(material, normal, offset);
                break;
            case "trg":
                auto v1 = parts.parseVec3;
                auto v2 = parts.parseVec3;
                auto v3 = parts.parseVec3;
                auto material = materials[parts.parseUint - 1];
                objects ~= new Triangle(material, v1, v2, v3);
                break;
            case "lgt":
                lights ~= Light(parts.parseVec3, parts.parseColor,
                        parts.parseDouble, parts.parseDouble, parts.parseDouble);
                break;
            default:
                throw new Exception("Unrecognized scene item");
            }
        }

        enforce(!camera.isNull, "Camera item not found");
        enforce(!backgroundColor.isNull, "Settings item not found");
        enforce(!shadowRaysN.isNull, "Settings item not found");
        enforce(!maxRecursion.isNull, "Settings item not found");
        enforce(!superSamplingN.isNull, "Settings item not found");

        camera.superSamplingN = superSamplingN;

        return Scene(backgroundColor, shadowRaysN, maxRecursion,
                superSamplingN, objects, camera, lights);
    }

    Image render() const
    {
        //TODO: multithreaded
        Image image = Image(camera.imageWidth, camera.imageHeight);
        for (uint y = 0; y < camera.imageHeight; ++y)
        {
            for (uint x = 0; x < camera.imageWidth; ++x)
            {
                auto pixel = renderPixel(x, y);
                image.set(x, y, pixel);
            }
        }
        return image;
    }

    Color renderPixel(uint x, uint y) const
    {
        import std.algorithm;

        auto rays = camera.constructRaysThroughPixel(x, y);
        auto length = rays.length;
        Color totalColor = rays.map!(ray => colorRayHits(ray, 0)).sum();
        return totalColor / length;
    }

    Color colorRayHits(const ref Ray ray, uint recursionLevel) const
    {
        recursionLevel += 1;
        if (recursionLevel > maxRecursion)
        {
            return backgroundColor;
        }
        auto hits = findHits(ray);
        return colorHits(hits, recursionLevel);
    }

    Hit[] findHits(const ref Ray ray) const
    {
        import std.algorithm : map, filter, sort, makeIndex, SwapStrategy;
        import std.array : array;

        alias myComp = (a, b) => a.distance < b.distance;
        alias myComp2 = (a, b) => a < b;
        auto hits = objects.map!(object => object.tryHit(ray))
            .filter!(hit => !hit.isNull).map!(hit => hit.get).array;
        auto index = new size_t[hits.length];
        makeIndex!("a.distance < b.distance")(hits, index);
        return index.map!(i => hits[i]).array;
    }

    Color colorHits(const ref Hit[] hits, uint recursionLevel) const
    {
        Color totalColor = Color.black;
        double prevTransparency = 1;
        foreach (hit; hits)
        {
            auto currentTransparency = hit.object.material.transparency;
            auto direct = getHitDirectColor(hit) * (1 - currentTransparency);
            auto reflection = getHitReflectionColor(hit, recursionLevel);
            auto color = (direct + reflection) * prevTransparency;
            totalColor += color;
            prevTransparency *= currentTransparency;
            if (currentTransparency == 0)
            {
                return totalColor;
            }
        }

        return totalColor + backgroundColor * prevTransparency;
    }

    Color getHitDirectColor(const ref Hit hit) const
    {
        Color totalDiffuseComponent = Color.black;
        Color totalSpecularComponent = Color.black;

        foreach (light; lights)
        {
            auto lightIntensity = getLightIntensityForHit(light, hit);
            if (lightIntensity == 0)
            {
                continue;
            }

            auto lightColor = light.color * lightIntensity;
            auto directionToLight = hit.hitPoint.directionTo(light.position);

            // Diffuse component
            auto diffusion = hit.hitNormal * directionToLight;
            assert(!diffusion.isNaN && diffusion <= 1);
            diffusion = diffusion.max(0);
            auto diffuseColor = lightColor * diffusion;
            totalDiffuseComponent += diffuseColor;

            // Specular Component
            if (hit.object.material.isSpecular)
            {
                auto directionToLightReflection = directionToLight.reflectAround(hit.hitNormal);
                auto cosAngle = directionToLightReflection * hit.directionToSource;
                if (cosAngle > 0)
                {
                    auto specular = cosAngle ^^ hit.object.material.phongSpecularity;
                    auto specularColor = (specular * light.specularIntensity) * lightColor;
                    totalSpecularComponent += specularColor;
                }
            }
        }
        totalDiffuseComponent *= hit.object.material.diffuseColor;
        totalSpecularComponent *= hit.object.material.specularColor;

        return totalDiffuseComponent + totalSpecularComponent;
    }

    Color getHitReflectionColor(const ref Hit hit, uint recursionLevel) const
    {
        if (!hit.object.material.isReflective)
        {
            return Color.black;
        }
        auto hitReflectionDirection = hit.directionToSource.reflectAround(hit.hitNormal);
        assert(almostEq(hitReflectionDirection.norm, 1));
        auto reflectionRay = Ray(hit.hitPoint, hitReflectionDirection);
        // Move reflection exit point forward a bit to avoid numeric issues (hitting the same surface)
        reflectionRay.advance(RAY_SMALL_ADVANCEMENT);
        auto reflectionColor = colorRayHits(reflectionRay, recursionLevel);
        return reflectionColor * hit.object.material.reflectionColor;
    }

    double getLightIntensityForHit(const ref Light light, const ref Hit hit) const
    {
        import std.random : uniform01;

        auto lightDirection = hit.hitPoint.directionTo(light.position);
        bool edgeCase = lightDirection.x == 0 && lightDirection.y == 0;
        auto directionX = edgeCase ? Vec3(1, 0, 0) : Vec3(-lightDirection.y,
                lightDirection.x, lightDirection.z);
        auto directionY = lightDirection.cross(directionX).normalize();

        alias n = shadowRaysN;
        auto cellRadius = light.radius / double(n);
        auto halfRadius = cellRadius / 2;

        double totalIntensity = 0;
        for (uint x = 0; x < n; ++x)
        {
            for (uint y = 0; y < n; ++y)
            {
                auto xOffset = cellRadius * (double(x) + uniform01()) - halfRadius;
                auto yOffset = cellRadius * (double(y) + uniform01()) - halfRadius;
                auto xDelta = directionX * xOffset;
                auto yDelta = directionY * yOffset;
                auto cellPoint = light.position + xDelta + yDelta;
                auto ray = Ray.constructRay(cellPoint, hit.hitPoint);
                totalIntensity += getRayIntensity(hit, ray);
            }
        }

        auto intensity = totalIntensity / double(n ^^ 2);
        // Interpolate intensity such that the minimum is shadow_intensity
        intensity = 1 - ((1 - intensity) * light.shadowIntensity);
        return intensity;
    }

    double getRayIntensity(const ref Hit hit, const ref Ray ray) const
    {
        double rayIntensity = 1;
        auto maxHitDistance = hit.hitPoint.distanceTo(ray.position) + EPSILON;
        foreach (rayHit; findHits(ray))
        {
            //TODO: make sure this short circuits
            // Check if we got to the given hit or if we passed it
            // (at object edges ray_hit can miss the original ray hit)
            auto objectsEqual = rayHit.object == hit.object;
            auto hitsAlmostEqual = objectsEqual
                && rayHit.hitPoint.almostEqualTo(hit.hitPoint, EPSILON);
            auto passedMaxDistance = rayHit.hitPoint.distanceTo(ray.position) > maxHitDistance;
            if (hitsAlmostEqual || passedMaxDistance)
            {
                break;
            }
            // Check if we hit an opaque object
            if (!rayHit.object.material.isTransparent())
            {
                rayIntensity = 0;
                break;
            }
            // Attenuate intensity
            rayIntensity *= rayHit.object.material.transparency;
        }
        return rayIntensity;
    }
}

auto pop(T)(ref T params)
{
    import std.range;

    auto r = params.front;
    params.popFront();
    return r;
}

double parseDouble(T)(ref T params)
{
    return params.pop.to!double;
}

uint parseUint(T)(ref T params)
{
    return params.pop.to!uint;
}

Vec3 parseVec3(T)(ref T params)
{
    return Vec3(params.parseDouble, params.parseDouble, params.parseDouble);
}

Color parseColor(T)(ref T params)
{
    return Color(params.parseDouble, params.parseDouble, params.parseDouble);
}

//TODO: compile only for tests
void testScene(string fileName)
{
    import std.path;
    import std.file;
    import std.datetime;
    import std.stdio;

    immutable outputsDir = "outputs";
    auto scenePath = buildPath("scenes", fileName);
    auto outputPath = buildPath(outputsDir, fileName);

    auto scene = Scene.fromFile(scenePath);
    auto start = MonoTime.currTime;
    auto image = scene.render();
    auto duration = MonoTime.currTime - start;
    writefln("Rendered scene %s in %s", fileName, duration);
    outputPath = outputPath.setExtension("png");
    if (!outputsDir.exists)
    {
        outputsDir.mkdir();
    }
    image.save(outputPath);
}

unittest
{
    testScene("Room1.txt");
}
