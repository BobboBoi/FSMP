using Godot;
using System.IO;
using TagLib;
using File = TagLib.File;
using SkiaSharp;
using System;
using System.Threading.Tasks;

[GlobalClass]
public partial class MetaDataReader : Node
{
    [Signal]
    public delegate void CoverLoadedEventHandler(ImageTexture img);

    public static MetaData GetMetaDataFromAudioFile(string path)
    {
        try
        {
            var raw = File.Create(path, ReadStyle.PictureLazy);
            if (raw is null) return null;

            MetaData data = new()
            {
                title = raw.Tag.Title ?? Path.GetFileName(path),
                album = raw.Tag.Album,
                index = (int)raw.Tag.Track,
                disc = (int)raw.Tag.Disc,
                artists = raw.Tag.Performers,
                type = GetFileType(path)
            };

            return data;
        }
        catch (UnsupportedFormatException)
        {
            return new() { title = Path.GetFileName(path), artists = [""] };
        }
        catch(CorruptFileException)
        {
            return new() { title = Path.GetFileName(path), artists = [""] };
        }
    }

    public static MusicData GetMusicDataFromAudioFile(string path)
    {
        try
        {
            var raw = File.Create(path, ReadStyle.PictureLazy);
            if (raw is null) return null;

            MusicData data = new()
            {
                path = path,
                title = raw.Tag.Title ?? Path.GetFileName(path),
                album = raw.Tag.Album,
                index = (int)raw.Tag.Track,
                disc = (int)raw.Tag.Disc,
                artists = raw.Tag.Performers,
                type = GetFileType(path)
            };

            return data;
        }
        catch (UnsupportedFormatException)
        {
            return new() { title = Path.GetFileName(path), artists = [""] };
        }
        catch (CorruptFileException)
        {
            return new() { title = Path.GetFileName(path), artists = [""] };
        }
    }

    public async void GetImageFromAudioFileAsync(string path, int index)
    {
        ImageTexture img = await Task.Run(() => GetImageFromAudioFile(path, index));
        EmitSignal(SignalName.CoverLoaded, img);
    }

    public ImageTexture GetImageFromAudioFile(string path, int index)
    {
        if (index < 0) return null;
        try
        {
            var raw = File.Create(path);
            if (raw is null) return null;

            IPicture[] result = raw.Tag.Pictures;
            if (index > result.Length - 1 || result.Length == 0) return null;

            try
            {
                Image img = new();
                if (!IsValidGDIPlusImage(result[index].Data.Data))
                {
                    GD.PushWarning("Corrupt image");
                    return null;
                }

                switch (result[index].MimeType)
                {
                    case "image/jpeg":
                        img.LoadJpgFromBuffer(result[index].Data.Data);
                        if (img.IsEmpty == null) return null;
                        ImageTexture final = ImageTexture.CreateFromImage(img);
                        return final;
                    case "image/png":
                        img.LoadPngFromBuffer(result[index].Data.Data);
                        return ImageTexture.CreateFromImage(img);
                    default:
                        GD.Print("Unsupported image format: ", result[index].MimeType);
                        return null;
                }
            }
            catch
            {
                return null;
            }
            
        }
        catch (UnsupportedFormatException)
        {
            return null;
        }
    }

    public static string GetImageTypeFromAudioFile(string path, int index)
    {
        if (index < 0) return String.Empty;
        
        var raw = File.Create(path);
        if (raw is null) return String.Empty;

        IPicture[] result = raw.Tag.Pictures;

        if (index > result.Length - 1 || result.Length == 0) return String.Empty;
        return result[index].MimeType;
    }

    public static byte[] GetImageBytesFromAudioFile(string path, int index)
    {
        if (index < 0) return [];
        
        var raw = File.Create(path);
        if (raw is null) return [];

        IPicture[] result = raw.Tag.Pictures;

        if (index > result.Length - 1 || result.Length == 0) return [];
        return result[index].Data.Data;
    }

    private static bool IsValidGDIPlusImage(byte[] imageData)
    {
        using var codec = SKCodec.Create(new MemoryStream(imageData), out var result);
        return !(codec == null || result != SKCodecResult.Success);
    }

    private static MetaData.FileType GetFileType(string path)
    {
        string extension = Path.GetExtension(path.ToLower());
        return extension switch
        {
            ".mp3" => MetaData.FileType.MP3,
            ".wav" => MetaData.FileType.WAV,
            ".ogg" => MetaData.FileType.OGG,
            ".flac" => MetaData.FileType.FLAC,
            _ => MetaData.FileType.UNKOWN
        };
    }
}
