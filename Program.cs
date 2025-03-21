global using static Raylib_cs.Raylib;
using GNSUsingCS;
using Raylib_cs;
using System.Diagnostics;
using System.Numerics;

// for online writing stuff.
// https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#Industry_use

namespace GNSAgain
{
    internal class Program
    {
        static void Main(string[] args)
        {
            InitWindow(1200, 800, "basic window");
            SetTargetFPS(60);

            LuaHandler.SetupLuaInterfacer();

            while (!WindowShouldClose())
            {
                // Update
                MouseManager.Update();
                InputManager.Update();
                LuaHandler.CoreUpdate();

                // Draw
                BeginDrawing(); ClearBackground(Color.White);

                LuaHandler.CoreDraw();

                EndDrawing();
            }

            CloseWindow();

        }
    }
}
