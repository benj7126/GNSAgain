/*using NLua;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using GNSAgain;
using static GNSAgain.LuaHandler;

namespace GNSUsingCS.ConfigAttributes
{ -- unsure if i will use this or lua.
    internal abstract class ConfigAttribute : Attribute
    {
        protected string fieldName = "";
        public abstract object GetValue();
        public void SetValue(object o,  string fieldName)
        {
            this.fieldName = fieldName;
            SetValue(o);
        }
        public abstract void SetValue(object o);

        internal abstract string SaveToString(string path, ZipArchive zipArchive);

        internal abstract void LoadFromString(string loadstring, string path, ZipArchive zipArchive);
    }

    internal class Bool(bool def) : ConfigAttribute
    {
        private bool _value = def;
        private bool _default = def;

        public override object GetValue()
        {
            return _value;
        }

        public override void SetValue(object o)
        {
            _value = (bool)o;
        }

        internal override string SaveToString(string path, ZipArchive zipArchive)
        {
            return _value ? "true" : "false";
        }

        internal override void LoadFromString(string loadstring, string path, ZipArchive zipArchive)
        {
            loadstring = loadstring.Replace(" ", "").ToLower();
            if (loadstring == "true")
                _value = true;
            else if (loadstring == "false")
                _value = false;
            else
                throw new Exception("Should probably just be console write error or whatever, but theres a faulty string here");
        }

        [LuaMethod("Config")]
        private static Bool NewBool(bool v = true)
        {
            Bool config = new Bool();
            
            return config;
        }
    }

    internal class Int : ConfigAttribute
    {
        protected int _value;

        public override object GetValue()
        {
            return _value;
        }
        protected override void SetValue(object o)
        {
            _value = (int)o;
        }

        public override string SaveToString(string path, ZipArchive zipArchive)
        {
            return _value.ToString();
        }

        public override void LoadFromString(string loadstring, string path, ZipArchive zipArchive)
        {
            if (!int.TryParse(loadstring, out _value))
                throw new Exception("Should probably just be console write error or whatever, but theres a faulty string here");
        }
    }

    internal class Float : ConfigAttribute
    {
        protected float _value;

        public override object GetValue()
        {
            return _value;
        }
        protected override void SetValue(object o)
        {
            _value = (float)o;
        }

        public override string SaveToString(string path, ZipArchive zipArchive)
        {
            return _value.ToString();
        }

        public override void LoadFromString(string loadstring, string path, ZipArchive zipArchive)
        {
            if (!float.TryParse(loadstring, out _value))
                throw new Exception("Should probably just be console write error or whatever, but theres a faulty string here");
        }
    }

    internal class Vector2 : ConfigAttribute
    {
        protected System.Numerics.Vector2 _value;

        public override object GetValue()
        {
            return new System.Numerics.Vector2(_value.X, _value.Y);
        }
        protected override void SetValue(object o)
        {
            _value = (System.Numerics.Vector2)o;
        }

        public override string SaveToString(string path, ZipArchive zipArchive)
        {
            (char, float)[] colors = { ('X', _value.X), ('Y', _value.Y) };

            string s = "";

            foreach ((char, float) c in colors)
            {
                if (c.Item2 != 0)
                    s += c.Item1 + ": " + c.Item2 + ", ";
            }

            if (s.Length > 1)
            {
                s = s.Substring(0, s.Length - 2);
            }

            return s;
        }

        public override void LoadFromString(string loadstring, string path, ZipArchive zipArchive)
        {
            string[] strings = loadstring.Replace(" ", "").Split(",");

            _value = new();

            Func<string, float> getValue = (str) => {
                if (float.TryParse(str, out float val))
                    throw new Exception("Should probably just be console write error or whatever, but theres a faulty string here");

                return val;
            };

            Dictionary<char, Action<string>> actions = new() {
                { 'X', (str) => _value.X = getValue(str) },
                { 'Y', (str) => _value.Y = getValue(str) }
            };

            foreach (string s in strings)
                actions[s[0]](s[1..]);
        }
    }

    internal class IRange(int min, int max) : Int
    {
        private new int _value = min;
    }

    internal class FRange(float min, float max) : Float
    {
        private new float _value = min;
    }

    internal class V2Range(System.Numerics.Vector2 min, System.Numerics.Vector2 max) : Vector2
    {
        private new System.Numerics.Vector2 _value = min;
    }

    internal class Color : ConfigAttribute
    {
        private Raylib_cs.Color _value;

        public override object GetValue()
        {
            return new Raylib_cs.Color(_value.R, _value.G, _value.B, _value.A);
        }
        protected override void SetValue(object o)
        {
            _value = (Raylib_cs.Color)o;
        }

        public override string SaveToString(string path, ZipArchive zipArchive)
        {
            (char, byte)[] colors = { ('R', _value.R), ('G', _value.G), ('B', _value.B), ('A', _value.A) };

            string s = "";

            foreach ((char, byte) c in colors)
            {
                if (c.Item2 != 255)
                    s += c.Item1 + ": " + c.Item2 + ", ";
            }

            if (s.Length > 1)
            {
                s = s.Substring(0, s.Length - 2); // remove ", "
            }

            return s;
        }

        public override void LoadFromString(string loadstring, string path, ZipArchive zipArchive)
        {
            string[] strings = loadstring.Replace(" ", "").Split(",");

            _value = new Raylib_cs.Color(255, 255, 255, 255);

            Func<string, byte> getValue = (str) => {
                if (byte.TryParse(str, out byte val))
                    throw new Exception("Should probably just be console write error or whatever, but theres a faulty string here");

                return val;
            };

            Dictionary<char, Action<string>> actions = new() {
                { 'R', (str) => _value.R = getValue(str) },
                { 'G', (str) => _value.G = getValue(str) },
                { 'B', (str) => _value.B = getValue(str) },
                { 'A', (str) => _value.A = getValue(str) }
            };

            foreach (string s in strings)
                actions[s[0]](s[1..]);
        }
    }

    /*
    internal abstract class ConfigList<T> : ConfigAttribute where T : ConfigAttribute, new()
    {
        protected List<T> _value;

        public override object GetValue()
        {
            List<T> list = [];
            foreach (T value in _value)
            {
                list.Add((T)value.GetValue());
            }

            return list;
        }
        protected override void SetValue(object o)
        {
            _value = (List<T>)o;
        }

        public override string SaveToString(string path, ZipArchive zipArchive)
        {
            string save = "";

            foreach (T value in _value)
            {
                string valuesString = value.SaveToString(save, zipArchive);
                save = save + valuesString.Length+"|" + valuesString;
            }

            return save;
        }

        public override void LoadFromString(string loadstring, string path, ZipArchive zipArchive)
        {
            List<T> list = [];

            while (loadstring.Length > 0)
            {
                int point = loadstring.IndexOf('.');
                int size = int.Parse(loadstring[..point]);

                T value = new T();
                value.LoadFromString(loadstring[point..(point+size)], path, zipArchive);

                list.Add(value);

                loadstring = loadstring[(point + size)..];
            }

            _value = list;
        }
    }
    *//*

    internal abstract class String : ConfigAttribute
    {
        protected string _value;

        public override object GetValue()
        {
            return new string(_value);
        }
        protected override void SetValue(object o)
        {
            _value = (string)o;
        }

        public override string SaveToString(string path, ZipArchive zipArchive)
        {
            return '"' + _value + '"';
        }

        public override void LoadFromString(string loadstring, string path, ZipArchive zipArchive)
        {
            int right = loadstring.IndexOf('"');
            int left = loadstring.LastIndexOf('"');

            if (right == -1 || left == -1)
                throw new Exception("Incorrect quotation of string.");

            _value = loadstring[right..(left-1)];
        }
    }

    internal class SingleLineString : String
    {
    }

    internal class MultiLineString : String
    {
        public override string SaveToString(string path, ZipArchive zipArchive)
        {
            string fileName = path + "Assets/" + Guid.NewGuid().ToString() + ".txt";

            ZipArchiveEntry contentEntry = zipArchive.CreateEntry(fileName);
            using (StreamWriter writer = new StreamWriter(contentEntry.Open()))
            {
                writer.Write(_value);
            }

            return fileName;
        }

        public override void LoadFromString(string loadstring, string path, ZipArchive zipArchive)
        {
            using (StreamReader reader = new StreamReader(zipArchive.GetEntry(loadstring.Replace(" ", "")).Open()))
            {
                _value = reader.ReadToEnd();
            }

        }
    }

    internal class CodeString : MultiLineString
    {
    }

    internal class Enum : ConfigAttribute
    {
        private object _value;

        public override object GetValue()
        {
            return _value;
        }
        protected override void SetValue(object o)
        {
            _value = o;
        }

        public override string SaveToString(string path, ZipArchive zipArchive)
        {
            throw new NotImplementedException();
        }

        public override void LoadFromString(string loadstring, string path, ZipArchive zipArchive)
        {
            throw new NotImplementedException();
        }
    }

    internal class SavedElementStyle : ConfigAttribute
    {
        protected ElementStyle _value;

        public override object GetValue()
        {
            return _value.CreateClone();
        }
        protected override void SetValue(object o)
        {
            _value = (ElementStyle)o;
        }

        public override string SaveToString(string path, ZipArchive zipArchive)
        {
            return _value.SaveToString();
        }

        public override void LoadFromString(string loadstring, string path, ZipArchive zipArchive)
        {
            _value = ElementStyle.LoadFromString(loadstring);
        }
    }
}
*/