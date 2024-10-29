using Godot;

[GlobalClass]
public partial class MetaData : GodotObject
{
    public MetaData() { }
    public MetaData(string Title = "", string Album = "", int Index = 0)
    {
        this.Title = Title;
        this.Album = Album;
        this.Index = Index;
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
    public int Index { get; set; } = 0;
}
