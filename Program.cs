global using static Raylib_cs.Raylib;
using Raylib_cs;
using System.Diagnostics;

// for online writing stuff.
// https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#Industry_use

namespace GNSAgain
{
    internal class Program
    {
        static void Main(string[] args)
        {
            LuaHandler.SetupLuaInterfacer();

            InitWindow(1200, 800, "basic window");
            SetTargetFPS(60);


            while (!WindowShouldClose())
            {
                // Update
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
