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
            L["vec"] = (float x, float y) => new Vector2(x, y);
            L.NewTable("rl");
            LuaTable rlTable = L.GetTable("rl");
            rlTable["rec"] = DrawRectangle;
            rlTable["vec"] = (float x, float y) => new Vector2(x, y);
            rlTable["drawTextCodepoint"] = DrawTextCodepoint;
            rlTable["isShiftDown"] = () => IsKeyDown(KeyboardKey.LeftShift) || IsKeyDown(KeyboardKey.RightShift);
            rlTable["isCtrlDown"] = () => IsKeyDown(KeyboardKey.LeftControl) || IsKeyDown(KeyboardKey.RightControl);
        }

        [LuaMethod(["rl"])]
        private static Color color(int r, int g, int b, int a = 255)
        {
            return new Color(r, g, b, a);
        }

        /*
        [LuaMethod(["rl"])]
        private static RenderTexture2D getCanvas(int screenWidth, int screenHeight)
        {
            return Raylib.LoadRenderTexture(screenWidth, screenHeight);
        }

        [LuaMethod(["rl"])]
        private static void drawCanvas(RenderTexture2D canvas, int x, int y, Color? inpTint = null)
        {
            Color tint = inpTint.HasValue ? inpTint.Value : Color.White;

            DrawTexture(canvas.Texture, x, y, tint);
        }
        */
    }
}
