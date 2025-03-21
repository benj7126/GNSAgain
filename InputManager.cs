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
using NLua;

namespace GNSUsingCS
{
    internal class InputEvent : Event
    {
        public string key;
        public InputEvent(char key) : base(new(), "input")
        {
            this.key = key.ToString();
        }
    }
    internal class KeyboardEvent : Event
    {
        public int key;
        public List<KeyAddition> additions;
        public KeyboardEvent(int key, List<KeyAddition> additions) : base(new(), "specialKey")
        {
            this.key = key;
            this.additions = additions;
        }
    }
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

        private static List<LuaTable> _fakeEventOrder = [];

        private static KeyboardKey _specialHeldKey;
        private static float _heldRepeatTimer;

        [LuaMethod("rl")]
        private static void setInput(Event luaEvent)
        {
            _fakeEventOrder = luaEvent.chain;
        }

        [LuaMethod("rl")]
        private static bool checkReceiving(LuaTable obj)
        {
            return _fakeEventOrder.Contains(obj);
        }
        
        /*public static void ClearInput()
        {
            _fakeEventOrder.Clear();
        }*/

        public static void Update()
        {
            if (_fakeEventOrder.Count == 0)
            {
                _specialHeldKey = 0;
                return;
            }

            List<KeyAddition> additions = [];
            if (IsKeyDown(KeyboardKey.LeftControl) || IsKeyDown(KeyboardKey.RightControl))
                additions.Add(KeyAddition.Ctrl);

            if (IsKeyDown(KeyboardKey.LeftAlt) || IsKeyDown(KeyboardKey.RightAlt))
                additions.Add(KeyAddition.Alt);

            if (IsKeyDown(KeyboardKey.LeftShift) || IsKeyDown(KeyboardKey.RightShift))
                additions.Add(KeyAddition.Shift);

            // Character input

            int c = GetCharPressed();
            while (c != 0)
            {
                // _inputObject.IncommingCharacter((char)c);
                LuaHandler.FakeEvent(_fakeEventOrder, new InputEvent((char)c));

                c = GetCharPressed();
            }

            _heldRepeatTimer -= GetFrameTime();

            int k = GetKeyPressed();
            while (k != 0)
            {
                _specialHeldKey = 0;
                if (_specialKeys.Contains((KeyboardKey)k))
                {
                    // _inputObject.IncommingSpecialKey((KeyboardKey)k, additions);
                    LuaHandler.FakeEvent(_fakeEventOrder, new KeyboardEvent(k, additions));
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
                    //_inputObject.IncommingSpecialKey(_specialHeldKey, additions);
                    LuaHandler.FakeEvent(_fakeEventOrder, new KeyboardEvent((int)_specialHeldKey, additions));
                }
                else
                {
                    //_inputObject.IncommingCharacter((char)_specialHeldKey);
                    LuaHandler.FakeEvent(_fakeEventOrder, new InputEvent((char)_specialHeldKey));
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