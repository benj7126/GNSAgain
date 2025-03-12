using Raylib_cs;
using System.Numerics;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Runtime.Intrinsics;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using GNSAgain;

namespace GNSUsingCS
{
    internal static class InputManager
    {
        private static readonly KeyboardKey[] _specialKeys = [
            KeyboardKey.Up,
            KeyboardKey.Down,
            KeyboardKey.Left,
            KeyboardKey.Right,
            KeyboardKey.Backspace,
            KeyboardKey.Enter,
            KeyboardKey.Delete
        ];

        private static IInput? _inputObject; // Should be a lua string?
                                             // And the ability to "subscribe" to all key inputs.

        private static KeyboardKey _specialHeldKey;
        private static float _heldRepeatTimer;

        public static void SetInput(IInput obj)
        {
            _inputObject = obj;
        }

        public static bool CheckSelected(IInput obj)
        {
            return _inputObject == obj;
        }

        public static void ClearInput()
        {
            _inputObject = null;
        }

        public static void Update()
        {
            if (_inputObject is null)
            {
                _specialHeldKey = 0;
                return;
            }

            // Character input

            int c = GetCharPressed();
            while (c != 0)
            {
                _inputObject.IncommingCharacter((char)c);

                c = GetCharPressed();
            }

            _heldRepeatTimer -= GetFrameTime();

            List<KeyAddition> additions = [];
            if (IsKeyDown(KeyboardKey.LeftControl) || IsKeyDown(KeyboardKey.RightControl))
                additions.Add(KeyAddition.Ctrl);

            if (IsKeyDown(KeyboardKey.LeftAlt) || IsKeyDown(KeyboardKey.RightAlt))
                additions.Add(KeyAddition.Alt);

            if (IsKeyDown(KeyboardKey.LeftShift) || IsKeyDown(KeyboardKey.RightShift))
                additions.Add(KeyAddition.Shift);

            int k = GetKeyPressed();
            while (k != 0)
            {
                _specialHeldKey = 0;
                if (_specialKeys.Contains((KeyboardKey)k))
                {
                    _inputObject.IncommingSpecialKey((KeyboardKey)k, additions);
                    //_heldRepeatTimer = Settings.FirstRepeatKeyTime;
                    _specialHeldKey = (KeyboardKey)k;
                }

                k = GetKeyPressed();
            }

            if (IsKeyUp(_specialHeldKey))
            {
                _specialHeldKey = 0;
            }

            if (_specialHeldKey != 0 && _heldRepeatTimer < 0)
            {
                //_heldRepeatTimer = Settings.RepeatKeyTime;
                if (_specialKeys.Contains(_specialHeldKey))
                {
                    _inputObject.IncommingSpecialKey(_specialHeldKey, additions);
                }
                else
                {
                    _inputObject.IncommingCharacter((char)_specialHeldKey);
                }
                
                // Should call this instead and give the input to lua.
                // Let the code handle where it goes.
                // LuaHandler.CallFromPath()
            }
        }
    }

    enum KeyAddition
    {
        Alt,
        Shift,
        Ctrl,
    }

    internal interface IInput
    {
        /// <summary>
        /// Supposed to automatically handle repeating using the InputManager.
        /// The InputManager also restricts input to only go to a single element at a time.
        /// </summary>
        internal abstract void IncommingCharacter(char character);

        /// <summary>
        /// Supposed to automatically handle repeating using the InputManager.
        /// The InputManager also restricts input to only go to a single element at a time.
        /// </summary>
        internal abstract void IncommingSpecialKey(KeyboardKey key, List<KeyAddition> additions);
    }
}