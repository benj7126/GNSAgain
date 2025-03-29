using GNSAgain;
using Raylib_cs;
using System;
using System.IO;
using System.Text;


namespace GNSUsingCS
{
    internal static class FontManager
    {
        private static readonly Dictionary<string, Font> _fontMap = [];

        [LuaMethod(["rl"])]
        public static Font getFont(string fontName, int size, TextureFilter filter = TextureFilter.Point)
        {
            if (fontName == "")
            {
                fontName = "Arial";
            }

            string filePath = "assets/fonts/" + fontName + ".ttf";
            fontName = $"{fontName} | {filter} | {size}";

            if (!_fontMap.ContainsKey(fontName))
            {
                Font font = LoadFontEx(filePath, size, null, 0); // no clue about these codepoints...
                // SetTextureFilter(font.Texture, filter);

                _fontMap.Add(fontName, font);
            }

            return _fontMap[fontName];
        }
    }
}
