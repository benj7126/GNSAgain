using GNSAgain;
using NLua;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Formats.Tar;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace GNSUsingCS
{
    public class ArchiveModificationInstance
    {
        private FileStream stream;
        private ZipArchive zipArchive;
        private List<string> prePaths = [];
        private string path = ""; // within archive

        public ArchiveModificationInstance(string path, int fileMode)
        {
            path = Path.Combine(SaveAndLoadManager.RelativePath, path);
            stream = new FileStream(path, (FileMode)fileMode);
            zipArchive = new ZipArchive(stream, ZipArchiveMode.Update);
        }

        public void enter(string pathToEnter)
        {
            prePaths.Add(path);
            path = Path.Combine(path, pathToEnter);
        }

        public void exit()
        {
            if (prePaths.Count == 0) return;

            path = prePaths[prePaths.Count - 1];
            prePaths.RemoveAt(prePaths.Count - 1);
        }

        public void writeString(string name, string saveString)
        {
            ZipArchiveEntry contentEntry = zipArchive.CreateEntry(Path.Combine(path, name));
            using (StreamWriter writer = new StreamWriter(contentEntry.Open()))
            {
                writer.Write(saveString);
            }
        }

        public string readString(string name)
        {
            ZipArchiveEntry? contentEntry = zipArchive.GetEntry(Path.Combine(path, name));

            if (contentEntry == null)
                return ""; // maby an error?

            using (StreamReader reader = new StreamReader(contentEntry.Open()))
            {
                return reader.ReadToEnd();
            }
        }

        public void close()
        {
            zipArchive.Dispose();
            // stream.Dispose();
        }
    }

    public static class SaveAndLoadManager
    {
        public static string RelativePath = Path.GetDirectoryName(Environment.ProcessPath);

        public static string tmpScriptPath = "C:\\Users\\benvb\\source\\repos\\GNSAgain\\scripts";

        internal static Dictionary<string, string> GetModules(string path = "", string pathing = "")
        {
            Dictionary<string, string> ret = new Dictionary<string, string>();

            if (path == "")
                path = tmpScriptPath;

            string[] filePaths = Directory.GetFiles(path);
            string[] dirPaths = Directory.GetDirectories(path);

            foreach (string filePath in filePaths)
            {
                if (filePath.Substring(filePath.Length - 4) != ".lua")
                    throw new Exception("not a lua file, just dont load and add to the console");

                string fileName = filePath.Substring(path.Length + 1, filePath.Length - path.Length - 5);
                string thisPathing = (pathing == "" ? "" : pathing + ".") + fileName;
                ret.Add(thisPathing, File.ReadAllText(filePath));
            }

            foreach (string dirPath in dirPaths)
            {
                string dirName = dirPath.Substring(path.Length + 1);
                string thisPathing = (pathing == "" ? "" : pathing + ".") + dirName;
                foreach (KeyValuePair<string, string> entry in GetModules(dirPath, thisPathing))
                    ret.Add(entry.Key, entry.Value);
            }

            return ret;
        }

        [LuaMethod()]
        private static ArchiveModificationInstance getAMI(string path, int fileMode) => new ArchiveModificationInstance(path, fileMode);
    }
}
