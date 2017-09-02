import material : Material;
import hit : Hit;
import ray : Ray;
import std.typecons : Nullable;

interface ModelObject
{
    Material material() const;
    Nullable!Hit tryHit(const ref Ray ray) const;
}
