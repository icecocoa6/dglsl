
module dglsl.shader;

import std.string;
import std.conv;

import derelict.opengl3.gl3;

import dglsl.type;
import dglsl.sampler;
import dglsl.translator;

class ShaderBase {
    mixin TextureLookupFunctions;

    protected GLuint _shaderid;
    @property auto id() const { return _shaderid; }
}

enum input;
enum output;
enum uniform;
enum ignore;

private struct MaxVertices {
    int value = -1;
}
private struct Location {
    int value = -1;
}
private struct Primitive {
    string value;
}
struct Layout {
    Primitive qualifier;
    MaxVertices maxVertices;
    Location location;

    string glsl() {
        import std.conv;
        import std.array;
        string[] lst;
        if (qualifier != Primitive.init) lst ~= qualifier.value;
        if (maxVertices != MaxVertices.init) lst ~= "max_vertices = " ~ maxVertices.value.to!string;
        if (location != Location.init) lst ~= "location = " ~ location.value.to!string;
        return "layout(" ~ lst.join(", ") ~ ")";
    }
}

string layout_attributes(T...)() {
    string[] lst;
    foreach (int i, immutable s; T) {
        static if (is(s == Primitive)) lst ~= "qualifier: args[%d]".format(i);
        else static if (is(s == MaxVertices)) lst ~= "maxVertices: args[%d]".format(i);
        else static if (is(s == Location)) lst ~= "location: args[%d]".format(i);
    }
    return lst.join(",");
}
auto layout(T...)(T args) {
    mixin("Layout l = {" ~ layout_attributes!T ~ "};");
    return l;
}
@property auto max_vertices(int i) { return MaxVertices(i); }
@property auto location(int i) { return Location(i); }


class Shader(alias Type, int _version = 330, string file = __FILE__, int line = __LINE__) : ShaderBase {
    static immutable glslVersion = _version;
    static immutable filepath = file;
    static immutable lineno = line;
    mixin Type;
}

mixin template Vertex() {
    static assert(glslVersion >= 330, "You need at least GLSL version 330 for vertex shaders!");
    static immutable type = "vertex";
    vec4 gl_Position;
}

mixin template Fragment() {
    static assert(glslVersion >= 330, "You need at least GLSL version 330 for fragment shaders!");
    static immutable type = "fragment";
}

mixin template Geometry() {
    static assert(glslVersion >= 330, "You need at least GLSL version 330 for geometry shaders!");
    static immutable type = "geometry";
    void EmitVertex() {};
    void EndPrimitive() {};

    struct PerVertex {
        vec4 gl_Position;
        float gl_PointSize;
        float[] gl_ClipDistance;
    }
    PerVertex[] gl_in;

    vec4 gl_Position;
    float gl_PointSize;
    float[] gl_ClipDistance;

    struct of {}

    enum {
        points = Primitive("points"),
        lines = Primitive("lines"),
        lines_adjacency = Primitive("lines_adjacency"),
        triangles = Primitive("triangles"),
        triangles_adjacency = Primitive("triangles_adjacency"),
        triangle_strip = Primitive("triangle_strip"),
        line_strip = Primitive("line_strip")
    }
}

mixin template TessellationControl() {
    static assert(glslVersion >= 400, "You need at least GLSL version 400 for tessellation control shaders!");
    static immutable type = "tessellationControl";
}

mixin template TessellationEvaluation() {
    static assert(glslVersion >= 400, "You need at least GLSL version 400 for tessellation evaluation shaders!");
    static immutable type = "tessellationEvaluation";
}

mixin template Compute() {
    static assert(glslVersion >= 430, "You need at least GLSL version 430 for compute shaders!");
    static immutable type = "compute";
}


void compile(T : ShaderBase)(T shader) {
    static if (T.type == "vertex")
        GLuint id = glCreateShader(GL_VERTEX_SHADER);
    static if (T.type == "fragment")
        GLuint id = glCreateShader(GL_FRAGMENT_SHADER);
    static if (T.type == "geometry")
        GLuint id = glCreateShader(GL_GEOMETRY_SHADER);
    static if (T.type == "tessellationControl")
        GLuint id = glCreateShader(GL_GEOMETRY_SHADER);
    static if (T.type == "tessellationEvaluation")
        GLuint id = glCreateShader(GL_GEOMETRY_SHADER);
    static if (T.type == "compute")
        GLuint id = glCreateShader(GL_GEOMETRY_SHADER);

    auto src = dtoglsl!(T).toStringz;
    shader._shaderid = id;
    glShaderSource(id, 1, &src, null);
    glCompileShader(id);
    
    GLint compiled;
    glGetShaderiv(shader._shaderid, GL_COMPILE_STATUS, &compiled);
    if (compiled == GL_FALSE) {
        throw new Exception(infoLog(shader));
    }
}

/*
** プログラムの情報を表示する
** ref: http://marina.sys.wakayama-u.ac.jp/~tokoi/?date=20090827
*/
string infoLog(T : ShaderBase)(T shader) {
    GLsizei bufSize;

    /* シェーダのコンパイル時のログの長さを取得する */
    glGetShaderiv(shader._shaderid, GL_INFO_LOG_LENGTH , &bufSize);

    if (bufSize == 0) return "";
    
    GLchar[] infoLog = new GLchar[](bufSize);
    GLsizei length;

    /* シェーダのコンパイル時のログの内容を取得する */
    glGetShaderInfoLog(shader._shaderid, bufSize, &length, infoLog.ptr);
    return format("InfoLog:\n%s\n", infoLog);
}
