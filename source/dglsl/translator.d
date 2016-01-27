
module dglsl.translator;

import std.range;
import std.string;
import std.traits;
import std.algorithm;

import dglsl.type;
import dglsl.sampler;
import dglsl.shader;


string dtoglsl(Shader)() if (Shader.type == "vertex") {
    string result = "#version %s\n".format(Shader.glslVersion);
    string[] functions;
    
    foreach (immutable s; __traits(derivedMembers, Shader)) {
        static if (!hasUDA!(__traits(getMember, Shader, s), ignore)) {
            static if(is(typeof(__traits(getMember, Shader, s)) == function)) {
                functions ~= s;
            } else {
                static if (hasUDA!(__traits(getMember, Shader, s), input)) {
                    static if (Shader.type == "vertex" && hasUDA!(__traits(getMember, Shader, s), Layout)) {
                        auto l = getUDAs!(__traits(getMember, Shader, s), Layout)[0];
                        result ~= l.glsl ~ " ";
                    }
                    result ~= "in ";
                }

                static if (hasUDA!(__traits(getMember, Shader, s), output)) {
                    result ~= "out ";
                }

                static if (hasUDA!(__traits(getMember, Shader, s), uniform)) {
                    result ~= "uniform ";
                }

                result ~= "%s %s;\n".format(glslType!(typeof(__traits(getMember, Shader, s))), s);
            }
        }
    }
    
    result ~= copyFunctions!(Shader.filepath, Shader.lineno)(functions);

    return result;
}

string dtoglsl(Shader)() if (Shader.type == "fragment") {
    string result = "#version %s\n".format(Shader.glslVersion);
    string[] functions;
    
    foreach (immutable s; __traits(derivedMembers, Shader)) {
        static if (!hasUDA!(__traits(getMember, Shader, s), ignore)) {
            static if(is(typeof(__traits(getMember, Shader, s)) == function)) {
                functions ~= s;
            } else {
                static if (hasUDA!(__traits(getMember, Shader, s), input)) {
                    static if (Shader.type == "vertex" && hasUDA!(__traits(getMember, Shader, s), Layout)) {
                        auto l = getUDAs!(__traits(getMember, Shader, s), Layout)[0];
                        result ~= l.glsl ~ " ";
                    }
                    result ~= "in ";
                }

                static if (hasUDA!(__traits(getMember, Shader, s), output)) {
                    result ~= "out ";
                }

                static if (hasUDA!(__traits(getMember, Shader, s), uniform)) {
                    result ~= "uniform ";
                }

                result ~= "%s %s;\n".format(glslType!(typeof(__traits(getMember, Shader, s))), s);
            }
        }
    }
    

    result ~= copyFunctions!(Shader.filepath, Shader.lineno)(functions);

    return result;
}

string dtoglsl(Shader)() if (Shader.type == "geometry") {
    string result = "#version %s\n".format(Shader.glslVersion);
    string[] functions;

    static assert(__traits(hasMember, Shader, "_input"), "Geometry shaders need an '_input' member!");
    static assert(__traits(hasMember, Shader, "_output"), "Geometry shaders need an '_output' member!");
    static assert(__traits(hasMember, Shader, "gl_in"), "Geometry shaders need an 'gl_in' member!");

    auto input = getUDAs!(Shader._input, Layout)[0];
    result ~= input.glsl ~ " in;\n";
    auto o = getUDAs!(Shader._output, Layout)[0];
    result ~= o.glsl ~ " out;\n";

    foreach (immutable s; __traits(derivedMembers, Shader)) {
        static if (s != typeof(Shader.gl_in[0]).stringof && !hasUDA!(__traits(getMember, Shader, s), ignore)) {
            alias t = typeof(__traits(getMember, Shader, s));
            static if(is(t == function)) {
                functions ~= s;
            } else static if (s != "_input" && s != "_output") {
                static if (hasUDA!(__traits(getMember, Shader, s), uniform)) {
                    result ~= "uniform ";
                }

                static if (hasUDA!(__traits(getMember, Shader, s), output)) {
                    result ~= "out ";
                }

                result ~= "%s %s;\n".format(glslType!(typeof(__traits(getMember, Shader, s))), s);
            }
        }
    }

    result ~= copyFunctions!(Shader.filepath, Shader.lineno)(functions);

    return result;
}

string dtoglsl(Shader)() if (Shader.type == "tessellationControl") {
    string result = "#version %s\n".format(Shader.glslVersion);
    // TODO:
    return result;
}

string dtoglsl(Shader)() if (Shader.type == "tessellationEvaluation") {
    string result = "#version %s\n".format(Shader.glslVersion);
    // TODO:
    return result;
}

string dtoglsl(Shader)() if (Shader.type == "compute") {
    string result = "#version %s\n".format(Shader.glslVersion);
    // TODO:
    return result;
}

private string copyFunctions(string filepath, int lineno)(string[] functions) {
    import std.ascii;
    auto source = import(filepath).lineSplitter.drop(lineno - 1);
    string result;
    int level = 0;
    while (!source.empty && level >= 0) {
        string line = source.front;

        if (functions.any!((s) {
                auto r = line.findSplit(s);
                return !r[1].empty && !isAlphaNum(r[0][$ - 1]) && !isAlphaNum(r[2][0]);
            })) {
            int lvl = level;
            while (!source.empty) {
                if (source.front.canFind('{')) level++;
                if (source.front.canFind('}')) {
                    level--;
                    if (level < lvl) break;
                }
                result ~= source.front ~ "\n";
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
