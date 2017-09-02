immutable EPSILON = 0.00001;

bool almostEq(double a, double b)
{
    import std.math : abs;
    return (a - b).abs <= EPSILON;
}
