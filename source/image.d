import color : Color;
import imageformats : write_image, ColFmt;

struct Image
{
    Color[] pixels;
    uint height;
    uint width;

    this(uint width, uint height)
    {
        this.height = height;
        this.width = width;
        this.pixels = new Color[height * width];
    }

    Color get(uint x, uint y) const
    {
        return pixels[y * width + x];
    }

    void set(uint x, uint y, Color color)
    {
        pixels[y * width + x] = color;
    }

    void save(string path) const
    {
        ubyte[] data = new ubyte[pixels.length * 3];
        for (uint y = 0; y < height; ++y)
        {
            for (uint x = 0; x < width; ++x)
            {
                auto i = (y * width + x) * 3;
                data[i .. i + 3] = get(x, y).bytes[];
            }
        }
        write_image(path, width, height, data);
    }
}
