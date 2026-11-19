using Godot;

[GlobalClass]
public partial class MetaData : GodotObject
{
	public MetaData() { }
	public MetaData(string title = "", string album = "", int index = 0)
	{
		this.title = title;
		this.album = album;
		this.index = index;
	}
	public MetaData(string[] artists, string title = "", string album = "", int index = 0)
	{
		this.title = title;
		this.album = album;
		this.index = index;
		this.artists = artists;
	}
    public MetaData(FileType type, string[] artists, string title = "", string album = "", int index = 0)
    {
        this.title = title;
        this.album = album;
        this.index = index;
        this.artists = artists;
		this.type = type;
    }

    public override string ToString()
	{
		string final = $"Title: {title} \n";
		final += $"Album: {album} \n";
		final += $"Index: {index} \n";
		return final ;
	}

	public string title { get; set; } = "";
	public string album { get; set; } = "";
	public string[] artists { get; set; } = new string[0];
	public int index { get; set; } = 0;
	public int disc { get; set; } = 0;

	public FileType type { get; set; }
	public enum FileType
	{
		MP3,
		OGG,
		WAV,
        FLAC,
		UNKOWN
	}
}
