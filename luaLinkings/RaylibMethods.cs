using GNSAgain;
using NLua;
using Raylib_cs;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Reflection.Metadata.Ecma335;
using System.Text;
using System.Threading.Tasks;

namespace GNSAgain.luaLinkings
{
    public static class RaylibMethods
    {
        public static void Setup(Lua L)
        {
            L.NewTable("rl");
            LuaTable a = L.GetTable("rl");
            a["rec"] = DrawRectangle;
            a["vec"] = (float x, float y) => new Vector2(x, y);
            a["drawTextCodepoint"] = DrawTextCodepoint;
            a["isShiftDown"] = () => IsKeyDown(KeyboardKey.LeftShift) || IsKeyDown(KeyboardKey.RightShift);
            a["isCtrlDown"] = () => IsKeyDown(KeyboardKey.LeftControl) || IsKeyDown(KeyboardKey.RightControl);
        }

        [LuaMethod(["rl"])]
        private static Color color(int r, int g, int b, int a = 255)
        {
            return new Color(r, g, b, a);
        }
    }
}
