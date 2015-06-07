=====================
Using a struct to simplify format()
=====================

When using __std.conv.to()__ or __std.stdio.write()__, the arguments are formated using a predefined format.

Structs are processed differently. By default, all the members of a __struct__ are converted 
but the internal __to()__ also checks if a __struct__ implements a custom __toString()__ function. 
If so, this function is used and the default formatting of the members doesn't happen.

This can be used as a trick to override the default predefined formats of a basic type.

For example, to display a pointer, with all the hex digits, a prefix and this whatever is the address size,
we define a __struct__ with a single member of type __void*__ and a custom __toString()__ function:

```D
import std.stdio;

struct FmtPtr
{
    void* ptr;
    string toString()
    {
        import std.format;
        static if (size_t.sizeof == 4)
            return format("0X%.8X ", cast(size_t)ptr);   
        static if (size_t.sizeof == 8)
            return format("0X%.16X ", cast(size_t)ptr);        
    }    
}

void main(string[] args)
{
    import core.stdc.stdlib;
    auto a = malloc(8);
    auto b = malloc(8);
    auto c = malloc(8);
    
    // ugly custom formatting
    writeln("0X", a, " ", "0X", b, " ", "0X", c);
    writefln("0X%.8X 0X%.8X 0X%.8X", a, b, c);
	
    // clean and clear equivalent using the struct
    writeln(FmtPtr(a), FmtPtr(b), FmtPtr(c));
}
```