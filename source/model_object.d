import material : Material;
import hit : Hit;
import ray : Ray;
import std.typecons : Nullable;

interface ModelObject
{
    Material material();
    Nullable!Hit tryHit(ref Ray ray);
}
