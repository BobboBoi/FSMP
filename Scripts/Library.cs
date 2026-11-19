using Godot;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Threading.Tasks;

[GlobalClass]
public partial class Library : Node
{
    # region windows native
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern IntPtr FindFirstFileW(string lpFileName, out WIN32_FIND_DATAW lpFindFileData);

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
    public static extern bool FindNextFile(IntPtr hFindFile, out WIN32_FIND_DATAW lpFindFileData);

    [DllImport("kernel32.dll")]
    public static extern bool FindClose(IntPtr hFindFile);

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct WIN32_FIND_DATAW
    {
        public FileAttributes dwFileAttributes;
        internal System.Runtime.InteropServices.ComTypes.FILETIME ftCreationTime;
        internal System.Runtime.InteropServices.ComTypes.FILETIME ftLastAccessTime;
        internal System.Runtime.InteropServices.ComTypes.FILETIME ftLastWriteTime;
        public int nFileSizeHigh;
        public int nFileSizeLow;
        public int dwReserved0;
        public int dwReserved1;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
        public string cFileName;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 14)]
        public string cAlternateFileName;
    }
        
    private static readonly IntPtr INVALID_HANDLE_VALUE = new IntPtr(-1);
    # endregion windows native

    [Signal]
    public delegate void LibraryLoadedEventHandler(Godot.Collections.Array<MusicData> music);

    public List<MusicData> music = [];
    public readonly string[] paths = ["D:\\SynologyDrive\\SynologyDrive\\Music", "D:\\SteamLibrary\\steamapps\\music"];

    private readonly string[] fileExtensions = [".mp3", ".wav", ".ogg", ".flac"];

    public override void _Ready()
    {
        base._Ready();
        //Reload();
    }

    private async void Reload()
    {
        ulong time = Time.GetTicksMsec();
        foreach (var path in paths)
            music.AddRange(await RecursiveScan(path));

        GD.Print("Took " + (((double)Time.GetTicksMsec() - time) / 1000) + " seonds to load");
        GD.Print("While loading: " + music.Count + " music tracks");

        time = Time.GetTicksMsec();
        await cleanLibrary2();
        GD.Print("Took " + (((double)Time.GetTicksMsec() - time) / 1000) + " seonds to clean");
        GD.Print("Final track count: " + music.Count);

        EmitSignal(SignalName.LibraryLoaded, new Godot.Collections.Array<MusicData>(music));
    }

    private async Task<List<MusicData>> RecursiveScan(string directory)
    {
        IntPtr findHandle = INVALID_HANDLE_VALUE;

        var tracks = new List<MusicData>();
        var tasks = new Queue<Task<List<MusicData>>>();

        try
        {
            findHandle = FindFirstFileW(directory + @"\*", out WIN32_FIND_DATAW findData);
            if (findHandle != INVALID_HANDLE_VALUE)
            {

                do
                {
                    if (findData.cFileName == "." || findData.cFileName == "..") continue;
                    
                    string fullpath = directory + (directory.EndsWith('\\') ? "" : "\\") + findData.cFileName;

                    if ((findData.dwFileAttributes & FileAttributes.Directory) != 0)
                        tasks.Enqueue(Task.Run(() => RecursiveScan(fullpath)));
                    else if (fileExtensions.Any(findData.cFileName.ToLower().EndsWith))
                        tracks.Add(MetaDataReader.GetMusicDataFromAudioFile(fullpath));
                }
                while (FindNextFile(findHandle, out findData));

                while(tasks.Count > 0)
                 tracks.AddRange(await tasks.Dequeue());
            }
        }
        finally
        {
            if (findHandle != INVALID_HANDLE_VALUE) FindClose(findHandle);
        }
        return tracks;
    }

    private async Task cleanLibrary2()
    {
        Dictionary<string, Task<MusicData[]>> tasks = [];

        foreach (MusicData track in music)
            if (!tasks.ContainsKey(track.title))
                tasks.Add(track.title, Task.Run(() => CleanTask(track)));

        foreach (var task in tasks.Values)
            foreach (var r in await task)
                music.Remove(r);
    }

    private MusicData[] CleanTask(MusicData current)
    {
        List<MusicData> dupes = music.FindAll(b => current.title == b.title && current.artists.Join() == b.artists.Join());
        MusicData[] remove = new MusicData[dupes.Count-1];

        for (int j = 1; j < dupes.Count; j++)
        {
            if (compareTracks(current, dupes[j]) < 0)
            {
                current = dupes[j];
                remove[j - 1] = current;
            }
            else
                remove[j - 1] = dupes[j];
        }

        return remove;
    }

    private int compareTracks(MetaData a, MetaData b)
    {
        if (a.type < b.type) return -1;
        return 1;
    }
}
