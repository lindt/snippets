=================================
cross product with alias function
=================================

import std.algorithm, std.array, std.stdio, std.string, std.typecons;

// your variadic function which will be called for every crossProduct result
auto magicVariadic(T...)(T t) {
    // do whatever you want you do here;
    string res = "%s item(s):".format(t.length);

    foreach (item; t) {
        res ~= " %s (%s)".format(item, typeid(item));  
    }
    return res;
}

unittest {
    // sure a test ;)
    assert(magicVariadic(1) == "1 item(s): 1 (int)");
}

// just in case you do not want to use Tuples straight away
auto magic(T)(T t) if (isTuple!T) {
    return t.expand.magicVariadic();   
}

// first template argument will now be the function you provide
auto crossProduct(alias T, U...)(U u) {
    return cartesianProduct(u).map!T;
}

void main() {
    // your inputs
    int[] as = [1, 2, 3, 4];
    string[] bs = ["foo", "bar"];
    float[] cs = [3.14, 23.42];

    auto result = cartesianProduct(as, bs, cs);
    // type of result is known at compile time
    pragma(msg, typeof(result.array)); // .array will allocate; so better avoid it

    auto mappedResult = crossProduct!magic(as, bs, cs);

    stdout.writefln("cross product: %s", mappedResult);
}
