
module dglsl.translator;

import std.range;

import dglsl.type;
import dglsl.sampler;

enum input;
enum output;
enum uniform;
enum ignore;

class _Shader {
    mixin TextureLookupFunctions;
}

class Shader(alias Type, string file = __FILE__, int line = __LINE__) : _Shader {
    static immutable glsl = "330";
    static immutable filepath = file;
    static immutable lineno = line;
    mixin Type;
}

mixin template Vertex() {
	vec4 gl_Position;
}

mixin template Fragment() {

}


string dtoglsl(Shader)() {
    import std.traits;
    import std.string;
    import std.algorithm;
    string result = "#version %s\n".format(Shader.glsl);
    string[] functions;

    foreach (immutable s; __traits(derivedMembers, Shader)) {
        static if (!hasUDA!(__traits(getMember, Shader, s), ignore)) {
            static if(is(typeof(__traits(getMember, Shader, s)) == function)) {
                functions ~= s;
            } else {
                static if (hasUDA!(__traits(getMember, Shader, s), input)) {
                    result ~= "in ";
                }

                static if (hasUDA!(__traits(getMember, Shader, s), output)) {
                    result ~= "out ";
                }

                static if (hasUDA!(__traits(getMember, Shader, s), uniform)) {
                    result ~= "uniform ";
                }

                result ~= "%s %s;".format(glslType!(typeof(__traits(getMember, Shader, s))), s);
            }
        }
    }

    auto source = import(Shader.filepath).lineSplitter.drop(Shader.lineno - 1);
    int level = 0;
    while (!source.empty && level >= 0) {
        string line = source.front;

        if (functions.any!(s => line.canFind(s))) {
            int lvl = level;
            while (!source.empty) {
                if (source.front.canFind('{')) level++;
                if (source.front.canFind('}')) {
                    level--;
                    if (level < lvl) break;
                }
                result ~= source.front;
                source.popFront();
            }
            
            continue;
        }

        if (line.canFind('{')) level++;
        if (line.canFind('}')) level--;
        
        source.popFront();
    }

    return result;
}