using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Formats.Tar;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace GNSUsingCS
{
    public static class SaveAndLoadManager
    {
        public static string RelativePath = Environment.ProcessPath; // Path.GetDirectoryName(Environment.ProcessPath);

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
    }
}
