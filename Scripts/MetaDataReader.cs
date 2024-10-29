using Godot;
using TagLib;

[GlobalClass]
public partial class MetaDataReader : Node
{
    static public MetaData GetFromAudioFile(string path)
    {
        //try
        //{
        var raw = File.Create(path);
        if (raw is null) return null;

        MetaData data = new()
        {
            Title = raw.Tag.Title,
            Album = raw.Tag.Album,
            Index = (int)raw.Tag.Track
        };

        return data;
        //}
        //catch(System.Runtime.InteropServices.SEHException e)
        //{
        //    GD.Print(e);
        //    return null;
        //}
        
    }
}
