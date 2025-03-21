using NLua;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;

namespace GNSAgain
{
    internal class MouseEvent : Event
    {
        public int button, presses;

        public MouseEvent(Vector2 pos, string type, int button, int presses) : base(pos, type)
        {
            this.button = button;
            this.presses = presses;
        }
    }
    internal static class MouseManager
    {
        private static Vector2 MousePosition;
        private static Vector2 MouseVelocity;
        private static Vector2 LastMousePosition;

        // public static HeldMouseObject heldObject; // TODO: Impliment

        public static int RepeatedStillClicks = 0;
        public static int RepeatedStillClicksButton = 0;
        private static float _repeatClickTimer = 0;

        [LuaMethod("rl.mouse")]
        private static Vector2 getMousePosition() => MousePosition;
        [LuaMethod("rl.mouse")]
        private static Vector2 getMouseVelocity() => MouseVelocity;
        [LuaMethod("rl.mouse")]
        private static Vector2 getLastMousePosition() => LastMousePosition;

        public static void Update()
        {
            LastMousePosition = MousePosition;
            MousePosition = GetMousePosition();

            MouseVelocity = MousePosition - LastMousePosition;

            if (LastMousePosition != MousePosition)
            {
                RepeatedStillClicks = 0;
                LuaHandler.SendEvent(new Event(MousePosition, "mousemoved"));
                // for textbox i will need to hook into that so that you can drag
                // even when not hovering the mouse over the textbox?
            }

            for (int i = 0; i < 3; i++)
            {
                if (IsMouseButtonPressed((Raylib_cs.MouseButton)i))
                {
                    if (RepeatedStillClicksButton != i)
                    {
                        RepeatedStillClicks = 0;
                        RepeatedStillClicksButton = i;
                    }

                    RepeatedStillClicks++;

                    LuaHandler.SendEvent(new MouseEvent(MousePosition, "mousepress", i, RepeatedStillClicks));

                    _repeatClickTimer = 0.6f; // Settings.AllowedRepeatClickTime;
                }
                else if (IsMouseButtonReleased((Raylib_cs.MouseButton)i))
                {
                    LuaHandler.SendEvent(new MouseEvent(MousePosition, "mouserelease", i, 1));
                }
            }

            _repeatClickTimer -= GetFrameTime();

            if (_repeatClickTimer < 0)
            {
                _repeatClickTimer = 0;
                RepeatedStillClicks = 0;
            }
        }
    }
}
