import color : Color;

struct Material
{
    Color diffuseColor;
    Color specularColor;
    Color reflectionColor;
    double phongSpecularity;
    double transparency;
    private bool _isTransparent;
    private bool _isReflective;
    private bool _isSpecular;

    this(Color diffuseColor, Color specularColor, Color reflectionColor,
            double phongSpecularity, double transparency)
    {
        this.diffuseColor = diffuseColor;
        this.specularColor = specularColor;
        this.reflectionColor = reflectionColor;
        this.phongSpecularity = phongSpecularity;
        this.transparency = transparency;
        this._isTransparent = transparency > 0;
        this._isReflective = reflectionColor != Color.black;
        this._isSpecular = specularColor != Color.black;
    }

    @property bool isTransparent() const
    {
        return _isTransparent;
    }

    @property bool isReflective() const
    {
        return _isReflective;
    }

    @property bool isSpecular() const
    {
        return _isSpecular;
    }
}
