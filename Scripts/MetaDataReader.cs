using Godot;
using System.IO;
using TagLib;
using File = TagLib.File;
using SkiaSharp;
using System;

[GlobalClass]
public partial class MetaDataReader : Node
{
    public static MetaData GetFromAudioFile(string path,string altTitle = "")
    {
        try
        {
            var raw = File.Create(path);
            if (raw is null) return null;

            MetaData data = new()
            {
                Title = raw.Tag.Title is null ? altTitle : raw.Tag.Title,
                Album = raw.Tag.Album,
                Index = (int)raw.Tag.Track,
                Disc = (int)raw.Tag.Disc,
                Artists = raw.Tag.Performers.Length > 0 ? raw.Tag.Performers : new string[] {""},
            };

            return data;
        }
        catch (UnsupportedFormatException)
        {
            return null;
        }
    }

    public static ImageTexture GetImageFromAudioFile(string path,int index)
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

    public static string GetImageTypeFromAudioFile(string path,int index)
    {
        if (index < 0) return String.Empty;
        
        var raw = File.Create(path);
        if (raw is null) return String.Empty;

        IPicture[] result = raw.Tag.Pictures;

        if (index > result.Length - 1 || result.Length == 0) return String.Empty;
        return result[index].MimeType;
    }

    public static byte[] GetImageBytesFromAudioFile(string path,int index)
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

}
