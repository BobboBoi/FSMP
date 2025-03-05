using Godot;
using System.Linq;

[GlobalClass]
public partial class MetaData : GodotObject
{
    public MetaData() { }
    public MetaData(string title = "", string album = "", int index = 0)
    {
        Title = title;
        Album = album;
        Index = index;
    }
    public MetaData(string[] artists, string title = "", string album = "", int index = 0)
    {
        Title = title;
        Album = album;
        Index = index;
        Artists = artists;
    }

    public override string ToString()
    {
        string final = $"Title: {Title} \n";
        final += $"Album: {Album} \n";
        final += $"Index: {Index} \n";
        return final ;
    }

    public string Title { get; set; } = "";
    public string Album { get; set; } = "";
    public string[] Artists { get; set; } = new string[0];
    public int Index { get; set; } = 0;
    public int Disc { get; set; } = 0;
}
