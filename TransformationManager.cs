using GNSAgain;
using Raylib_cs;
using System.Numerics;
using System.Runtime.InteropServices;

namespace GNSUsingCS
{
    internal static class TransformationManager
    {
        private static Camera2D camera = new Camera2D();
        public static void init()
        {
            camera.Target = new Vector2(0, 0); // The point to which the camera is looking (world coordinates)
            camera.Offset = new Vector2(0, 0); // The offset from the target point (screen coordinates)
            camera.Rotation = 0.0f;           // Camera rotation in degrees
            camera.Zoom = 1.0f;               // Camera zoom (1.0 is no zoom)
        }

        [LuaMethod("rl", "camera")]
        public static void set(float x = 0, float y = 0, float rotation = 0, float zoom = 1.0f)
        {
            camera.Target = new Vector2(x, y);
            camera.Rotation = rotation;
            camera.Zoom *= zoom;

            Raylib.BeginMode2D(camera);
        }

        [LuaMethod("rl", "camera")]
        public static void reset()
        {
            Raylib.EndMode2D();
        }
    }
}
