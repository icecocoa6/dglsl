
module dglsl.program;

import std.string;

import derelict.opengl3.gl3;
import gl3n.linalg : Vector, Matrix;

import dglsl.gspl;
import dglsl.shader;


class Program(T...) {
    private GLuint _programid;
    @property auto id() const { return _programid; }

    mixin(shader_uniform!T);

    this(T shaders) {
        _programid = glCreateProgram();

        foreach (s; shaders) {
            glAttachShader(_programid, s.id);
        }

        glLinkProgram(_programid);

        GLint linked;
        glGetProgramiv(_programid, GL_LINK_STATUS, &linked);

        if (linked == GL_FALSE) {
            throw new Exception(infoLog(this));
        }

        setUniformLocations();
    }
}

/*
** プログラムの情報を表示する
** from: http://marina.sys.wakayama-u.ac.jp/~tokoi/?date=20090827
*/
string infoLog(T...)(Program!T p)
{
    GLsizei bufSize;

    /* シェーダのリンク時のログの長さを取得する */
    glGetProgramiv(p.id, GL_INFO_LOG_LENGTH , &bufSize);

    if (bufSize == 0) return "";

    GLchar[] infoLog = new GLchar[](bufSize);
    GLsizei length;

    /* シェーダのリンク時のログの内容を取得する */
    glGetProgramInfoLog(p.id, bufSize, &length, infoLog.ptr);
    return format("InfoLog:\n%s\n", infoLog);
}

auto makeProgram(T...)(T shaders) {
    return new Program!T(shaders);
}

import std.typecons;

Tuple!(string, string)[] shader_uniform_list(T: ShaderBase)() {
    import std.traits;
    Tuple!(string, string)[] lst;
    foreach (immutable s; __traits(derivedMembers, T)) {
        static if (!hasUDA!(__traits(getMember, T, s), ignore) && hasUDA!(__traits(getMember, T, s), uniform)) {
            immutable type = typeof(__traits(getMember, T, s)).stringof;
            lst ~= Tuple!(string, string)(s, (type.startsWith("Sampler")) ? "int" : type);
        }
    }
    return lst;
}

Tuple!(string, string)[] shader_uniform_list(T...)() if (T.length > 1) {
    import std.algorithm;
    auto ls = shader_uniform_list!(T[0]);
    auto ls2 = shader_uniform_list!(T[1 .. $]);

    foreach (s; ls) {
        if (!ls2.canFind(s)) ls2 ~= s;
    }

    return ls2;
}


string shader_uniform(T...)() {
    import std.algorithm;
    string result = "";
    auto lst = shader_uniform_list!T;

    foreach (sym; lst) {
        result ~= "GLint %sLoc;\n".format(sym[0]);
        result ~= "@property void %s(%s v) { glUniform(%sLoc, v); }\n".format(sym[0], sym[1], sym[0]);
    }

    auto locs = lst
        .map!(sym => "\t%sLoc = glGetUniformLocation(_programid, `%s`.toStringz);".format(sym[0], sym[0]))
        .join("\n");

    result ~= "void setUniformLocations() {\n" ~ locs ~ "\n}\n";

    return result;
}
