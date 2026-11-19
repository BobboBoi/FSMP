using Godot;

[GlobalClass]
public partial class MusicData : MetaData
{
    public string path {  get; set; }
    public string name { get { return title; } set { title = value; } }
    public int albumIndex { get { return index; } set { index = value; } }

    public string GetArtistsString()
    {
        string result = string.Empty;
        
        for (int i = 0; i < artists.Length-2; i++)
            result += $"{artists[i]}, ";

        if (artists.Length > 1)
            result += $"{artists[^2]} & {artists[^1]}";
        else if (artists.Length > 0)
            result = artists[0];


        return result;
    }
}