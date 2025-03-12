/*using NLua;

namespace GNSUsingCS
{ -- i might not need this if everything is in lua..?
    internal static class ObjectIDController
    {
        // internal static ObjectIDController<LuaObject> Workspace = new("", (path, id) => new LuaObject());
    }

    internal class ObjectIDController<T>(string loadPath, Func<string, string, T> loadMethod)
    {
        private Dictionary<string, T> objects = [];

        public T Get(string id)
        {
            if (!objects.ContainsKey(id))
            {
                objects.Add(id, loadMethod(loadPath, id));
            }

            return objects[id];
        }
        public void Set(string id, T element)
        {
            objects.Add(id, element);
        }
        public bool Contains(string id)
        {
            return objects.ContainsKey(id);
        }
    }
}
*/