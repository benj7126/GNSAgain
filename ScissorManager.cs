using GNSAgain;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GNSUsingCS
{
    internal static class ScissorManager
    {
        public static Stack<(int, int, int, int)> ScissorLayers = [];

        /* would ideally not be needed
        public static void ClearScissor()
        {
            ScissorLayers = [];
            EndScissorMode();
        }
        */

        [LuaMethod("scissor")]
        public static void enter(int x, int y, int w, int h)
        {
            if (!ScissorLayers.Any())
            {
                ScissorLayers.Push(new(x, y, w, h));
                BeginScissorMode(x, y, w, h);
                return;
            }

            (int, int, int, int) outerLayer = ScissorLayers.First();

            if (x < outerLayer.Item1)
            {
                x = outerLayer.Item1;
            }

            if (y < outerLayer.Item2)
            {
                y = outerLayer.Item2;
            }

            if (x + w > outerLayer.Item1 + outerLayer.Item3)
            {
                w = outerLayer.Item1 + outerLayer.Item3 - x;
            }

            if (y + h > outerLayer.Item2 + outerLayer.Item4)
            {
                h = outerLayer.Item2 + outerLayer.Item4 - y;
            }

            ScissorLayers.Push(new(x, y, w, h));
            BeginScissorMode(x, y, w, h);
        }

        [LuaMethod("scissor")]
        public static void godEnter(int x, int y, int w, int h)
        {
            ScissorLayers.Push(new(x, y, w, h));
            BeginScissorMode(x, y, w, h);
        }

        [LuaMethod("scissor")]
        public static void exit(int count = 1)
        {
            for (int i = 0; i < count; i++)
                _exit();
        }
        private static void _exit()
        {
            if (!ScissorLayers.Any())
                return;

            ScissorLayers.Pop();

            if (!ScissorLayers.Any())
            {
                EndScissorMode();
                return;
            }

            (int x, int y, int w, int h) = ScissorLayers.Last();
            BeginScissorMode(x, y, w, h);
        }

        [LuaMethod("scissor")]
        public static void clearAll()
        {
            ScissorLayers.Clear();
            EndScissorMode();
        }
    }
}
