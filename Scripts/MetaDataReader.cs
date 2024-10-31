using Godot;
using System.IO;
using System.Drawing;
using TagLib;
using File = TagLib.File;
using System;
using SkiaSharp;

[GlobalClass]
public partial class MetaDataReader : Node
{
    public static MetaData GetFromAudioFile(string path)
    {
        try
        {
            var raw = File.Create(path);
            if (raw is null) return null;

            MetaData data = new()
            {
                Title = raw.Tag.Title,
                Album = raw.Tag.Album,
                Index = (int)raw.Tag.Track
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

    private static bool IsValidGDIPlusImage(byte[] imageData)
    {
        using var codec = SKCodec.Create(new MemoryStream(imageData), out var result);
        return !(codec == null || result != SKCodecResult.Success);
    }

}
