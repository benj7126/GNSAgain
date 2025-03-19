using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;

namespace GNSAgain
{
    internal static class MouseManager
    {
        public static Vector2 MousePosition;
        public static Vector2 MouseVelocity;
        public static Vector2 LastMousePosition;

        // public static HeldMouseObject heldObject; // TODO: Impliment

        public static int[] RepeatedStillClicks = [0, 0, 0];
        private static float _repeatClickTimer = 0;

        public static void Update()
        {
            LastMousePosition = MousePosition;
            MousePosition = GetMousePosition();

            MouseVelocity = MousePosition - LastMousePosition;

            if (LastMousePosition != MousePosition)
                RepeatedStillClicks = [0, 0, 0];

            for (int i = 0; i < RepeatedStillClicks.Length; i++)
            {
                if (IsMouseButtonPressed((Raylib_cs.MouseButton)i))
                {
                    if (RepeatedStillClicks[i] == 0)
                    {
                        RepeatedStillClicks = [0, 0, 0];
                    }

                    RepeatedStillClicks[i]++;

                    _repeatClickTimer = 0.6f; // Settings.AllowedRepeatClickTime;
                }
            }

            _repeatClickTimer -= GetFrameTime();

            if (_repeatClickTimer < 0)
            {
                _repeatClickTimer = 0;

                for (int i = 0; i < RepeatedStillClicks.Length; i++)
                {
                    RepeatedStillClicks[i] = 0;
                }
            }
        }
    }
}
