using GNSAgain.luaLinkings;
using GNSUsingCS;
using KeraLua;
using NLua;
using System.Diagnostics;
using System.Numerics;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.Marshalling;
using System.Text;

namespace GNSAgain
{
    internal class LuaMethod : Attribute { public LuaMethod(params string[] path) { this.path = path; } internal string[] path = []; }
    internal class Event(Vector2 pos, string type) {
        public List<LuaTable> chain = [];
        public Vector2 pos = pos;
        public string type = type;
        public void passed(LuaTable obj) { chain.Add(obj); }
    }

    internal static class LuaHandler
    {
        public static NLua.Lua L;
        private static Dictionary<string, string> Modules;
        private static List<string> CustomMethods; // CS methods

        internal static void SetupLuaInterfacer()
        {
            L = new();
            L.State.Encoding = Encoding.GetEncoding("ISO-8859-1");

            loadModules();
            setupMethods();

            ExecuteLuaCode(Modules["core"], "core");
        }

        private static void ExecuteLuaCode(string code, string chunkName)
        {
            try
            {
                // xpcall is a protected call with an error handler.
                // debug.traceback is the error handler we want.
                // The chunkName argument is what makes the traceback useful.
                L.DoString($@"
        
                    local status, err = xpcall(function()
                        { code}
                end, debug.traceback)

            if not status then
                        print('--- Lua Error ---')
                        print(err)
                    end
                ", chunkName);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"C# Exception during Lua execution: {ex.Message}");
            }
        }

        public static bool SameTable(LuaTable a, LuaTable b)
        {
            NLua.LuaFunction sameTableFn = L.DoString("return function(a, b) return a == b end")[0] as NLua.LuaFunction;

            return (bool)sameTableFn.Call(a, b)[0];
        }

        private static void callFunctionFromCode(string code, string functionName, params object[] args)
        {
            using (var lua = new NLua.Lua())
            {
                if (lua.GetObjectFromPath(functionName) is not NLua.LuaFunction)
                    return;

                // Define the function and serialize to bytecode
                lua.DoString(code);
                lua.State.Encoding = Encoding.GetEncoding("ISO-8859-1");

                var result = lua.DoString("return string.dump(" + functionName + ")");
                byte[] bytecode = Encoding.GetEncoding("ISO-8859-1").GetBytes((string)result[0]);

                // Load it into main state
                KeraLua.Lua state = L.State;

                var status = state.LoadBuffer(bytecode, functionName);
                if (status != LuaStatus.OK)
                    throw new Exception($"Load failed: {state.ToString(-1)}");

                state.SetGlobal(functionName); // Assign to global

                CallFromPath(functionName, args);

                state.PushNil();
                state.SetGlobal(functionName); // Clear from global
            }
        }

        private static string securePath(string[] pathArray)
        {
            string path = "";

            foreach (string pathPart in pathArray)
            {
                path += pathPart;
                L.DoString($$"""local type = type({{path}}); if type ~= "table" then if type ~= "nil" then print("Override of type " .. type .. " while securing path '{{path}}'") end; {{path}} = {} end""");
                path += ".";
            }

            return path;
        }
        private static void setupMethods()
        {
            RaylibMethods.Setup(L);

            CustomMethods = [];

            foreach (Assembly assembly in AppDomain.CurrentDomain.GetAssemblies())
            {
                foreach (Type type in assembly.GetTypes())
                {
                    foreach (MethodInfo method in type.GetMethods(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static))
                    {
                        LuaMethod lm = (LuaMethod)method.GetCustomAttribute(typeof(LuaMethod), true);
                        if (lm is not null)
                        {
                            string path = securePath(lm.path) + method.Name;
                            if (L.GetObjectFromPath(path) is not null)
                                Console.WriteLine("The creation of " + path + " is overriding something already there");
                            // should probably have some deapth-related print for ^this^ and also some error level of debugging or something.

                            CustomMethods.Add(path);
                            L.RegisterFunction(path, method);
                        }
                    }
                }
            }
        }

        internal static void loadModules()
        {
            Modules = SaveAndLoadManager.GetModules();
            // should be able to reload moduels
            // L.DoString("""package.loaded.moduleName = nil"""); clears a module, then re-require it.

            foreach (string module in Modules.Values)
            {
                // Run setup on all modules
                callFunctionFromCode(module, "Setup"); // neither know if this works nor if i actually need it like this...
            }

            L.SetObjectToPath("_modules", Modules);

            L.DoString("""
                -- replace searchers (for require)
                package.searchers = { function(moduleName)
                    if _modules[moduleName] then
                        local code = _modules[moduleName]
                        local chunk, err = load(code, moduleName, 't')
                        if chunk then
                            return chunk
                        else
                            error(err)
                        end
                    end
                end}
            """);
        }

        /* -- would like to have this but lets call it a work in progress for now.
        [LuaMethod]
        internal static void reLoadModules()
        {
            Dictionary<string, string> newModules = SaveAndLoadManager.GetModules();
            // should be able to reload moduels
            // L.DoString("""package.loaded.moduleName = nil"""); clears a module, then re-require it.

            List<string> toRequire = new List<string>();

            foreach (KeyValuePair<string, string> module in newModules)
            {
                if (Modules.ContainsKey(module.Key))
                {
                    if (Modules[module.Key] != module.Value)
                    {
                        Modules[module.Key] = module.Value;
                        L.DoString("package.loaded[" + module.Key + "] = nil");
                        toRequire.Add(module.Key);
                    }
                }
                else
                {
                    Modules.Add(module.Key, module.Value);
                }
            }
        }
        */


        [LuaMethod]
        private static string getUUID()
        {
            return Guid.NewGuid().ToString();
        }

        private static FieldInfo reference = typeof(LuaBase).GetField("_Reference", BindingFlags.NonPublic | BindingFlags.Instance);
        // [LuaMethod]
        private static void print(params object[] objs) // this doesnt work too well...
        {
            printS("\t", objs);
        }
        [LuaMethod]
        private static void printS(string seperator, params object[] objs)
        { // make custom console - also let you change the console to a textbox - so you can run code within if you want to; or something...
            bool start = true;
            foreach (object obj in objs)
            {
                if (!start)
                    Console.Write(seperator);

                Console.Write(obj is null ? "nil" : (obj is LuaBase lobj ? lobj.ToString() + "-" + reference.GetValue(lobj) : obj));

                start = false;
            }
            Console.Write("\n");
        }
        public static void CallFromPath(string functionName, params object[] objs)
        {
            if (L.GetObjectFromPath(functionName) is NLua.LuaFunction func)
                    func.Call(objs);
        }

        internal static void CoreUpdate()
        {
            CallFromPath("CoreUpdate");
        }

        internal static void CoreDraw()
        {
            CallFromPath("CoreDraw");
        }

        internal static void Quitting()
        {
            CallFromPath("Quitting");
        }

        internal static void SendEvent(object @event)
        {
            CallFromPath("CorePropagateEvent", @event);
        }

        internal static void FakeEvent(List<LuaTable> fakeEventOrder, Event @event)
        {
            foreach (LuaTable luaTable in fakeEventOrder)
            {
                if (luaTable["handleEvent"] is NLua.LuaFunction func)
                {
                    object[] t = func.Call(luaTable, @event);

                    if (!t.Any())
                    {
                        // TODO: report to error otuput; some 'handleEvent' [something] is missing a return
                        continue;
                    }

                    bool consumed = (bool)t[0];
                    if (consumed)
                        return;
                }
            }
        }
    }
}