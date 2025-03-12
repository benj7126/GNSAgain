using GNSAgain;
using NLua;
using Raylib_cs;
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
    public static class RaylibMethods
    {
        public static void Setup(Lua L)
        {
            L.NewTable("rl");
            LuaTable a = L.GetTable("rl");
            a["rec"] = DrawRectangle;
        }

        [LuaMethod(["rl"])]
        private static Color color(int r, int g, int b, int a = 255)
        {
            return new Color(r, g, b, a);
        }
    }
}
