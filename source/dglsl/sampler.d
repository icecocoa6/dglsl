
module dglsl.sampler;

import dglsl.type;

struct Sampler1D(Type) { alias type = Type; }
struct Sampler2D(Type) { alias type = Type; }
struct Sampler3D(Type) { alias type = Type; }
struct SamplerCube(Type) { alias type = Type; }
struct Sampler2DRect(Type) { alias type = Type; }
struct Sampler1DShadow(Type) { alias type = Type; }
struct Sampler2DShadow(Type) { alias type = Type; }
struct SamplerCubeShadow(Type) { alias type = Type; }
struct Sampler2DRectShadow(Type) { alias type = Type; }
struct Sampler1DArray(Type) { alias type = Type; }
struct Sampler2DArray(Type) { alias type = Type; }
struct Sampler1DArrayShadow(Type) { alias type = Type; }
struct Sampler2DArrayShadow(Type) { alias type = Type; }
struct SamplerBuffer(Type) { alias type = Type; }
struct Sampler2DMS(Type) { alias type = Type; }
struct Sampler2DMSArray(Type) { alias type = Type; }

alias sampler1D = Sampler1D!(float);
alias sampler2D = Sampler2D!(float);
alias sampler3D = Sampler3D!(float);
alias samplerCube = SamplerCube!(float);
alias sampler2DRect = Sampler2DRect!(float);
alias sampler1DShadow = Sampler1DShadow!(float);
alias sampler2DShadow = Sampler2DShadow!(float);
alias samplerCubeShadow = SamplerCubeShadow!(float);
alias sampler2DRectShadow = Sampler2DRectShadow!(float);
alias sampler1DArray = Sampler1DArray!(float);
alias sampler2DArray = Sampler2DArray!(float);
alias sampler1DArrayShadow = Sampler1DArrayShadow!(float);
alias sampler2DArrayShadow = Sampler2DArrayShadow!(float);
alias samplerBuffer = SamplerBuffer!(float);
alias sampler2DMS = Sampler2DMS!(float);
alias sampler2DMSArray = Sampler2DMSArray!(float);

alias isampler1D = Sampler1D!(int);
alias isampler2D = Sampler2D!(int);
alias isampler3D = Sampler3D!(int);
alias isamplerCube = SamplerCube!(int);
alias isampler2DRect = Sampler2DRect!(int);
alias isampler1DArray = Sampler1DArray!(int);
alias isampler2DArray = Sampler2DArray!(int);
alias isamplerBuffer = SamplerBuffer!(int);
alias isampler2DMS = Sampler2DMS!(int);
alias isampler2DMSArray = Sampler2DMSArray!(int);

alias usampler1D = Sampler1D!(uint);
alias usampler2D = Sampler2D!(uint);
alias usampler3D = Sampler3D!(uint);
alias usamplerCube = SamplerCube!(uint);
alias usampler2DRect = Sampler2DRect!(uint);
alias usampler1DArray = Sampler1DArray!(uint);
alias usampler2DArray = Sampler2DArray!(uint);
alias usamplerBuffer = SamplerBuffer!(uint);
alias usampler2DMS = Sampler2DMS!(uint);
alias usampler2DMSArray = Sampler2DMSArray!(uint);

import std.string;
import std.algorithm;
import std.array;
string specialize(string source) {
    return source.lineSplitter
        .map!((l) {
            if (l.canFind('g')) return l.replace("g", "") ~ "\n" ~ l.replace("g", "i") ~ "\n" ~ l.replace("g", "u");
            else return l.strip;
        })
        .filter!(l => !l.empty)
        .join("\n")
        .lineSplitter
        .map!(l => l.chomp(";") ~ ` { throw new Error(__FUNCTION__ ~ "is not implemented."); }`)
        .join("\n");
}

mixin template TextureLookupFunctions() {
    mixin(q{
        int textureSize(gsampler1D sampler, int lod);
        ivec2 textureSize(gsampler2D sampler, int lod);
        ivec3 textureSize(gsampler3D sampler, int lod);
        ivec2 textureSize(gsamplerCube sampler, int lod);
        int textureSize(sampler1DShadow sampler, int lod);
        ivec2 textureSize(sampler2DShadow sampler, int lod);
        ivec2 textureSize(samplerCubeShadow sampler, int lod);
        ivec2 textureSize(gsampler2DRect sampler);
        ivec2 textureSize(sampler2DRectShadow sampler);
        ivec2 textureSize(gsampler1DArray sampler, int lod);
        ivec3 textureSize(gsampler2DArray sampler, int lod);
        ivec2 textureSize(sampler1DArrayShadow sampler, int lod);
        ivec3 textureSize(sampler2DArrayShadow sampler, int lod);
        int textureSize(gsamplerBuffer sampler);
        ivec2 textureSize(gsampler2DMS sampler);
        ivec2 textureSize(gsampler2DMSArray sampler);
    }.specialize);    
    mixin(q{
        gvec4 texture(gsampler1D sampler, float P, float bias = float.nan);
        gvec4 texture(gsampler2D sampler, vec2 P, float bias = float.nan);
        gvec4 texture(gsampler3D sampler, vec3 P, float bias = float.nan);
        gvec4 texture(gsamplerCube sampler, vec3 P, float bias = float.nan);
        float texture(sampler1DShadow sampler, vec3 P, float bias = float.nan);
        float texture(sampler2DShadow sampler, vec3 P, float bias = float.nan);
        float texture(samplerCubeShadow sampler, vec4 P, float bias = float.nan);
        gvec4 texture(gsampler1DArray sampler, vec2 P, float bias = float.nan);
        gvec4 texture(gsampler2DArray sampler, vec3 P, float bias = float.nan);
        float texture(sampler1DArrayShadow sampler, vec3 P, float bias = float.nan);
        float texture(sampler2DArrayShadow sampler, vec4 P);
        gvec4 texture(gsampler2DRect sampler, vec2 P);
        float texture(sampler2DRectShadow sampler, vec3 P);
    }.specialize);
    mixin(q{
        gvec4 textureProj(gsampler1D sampler, vec2 P, float bias = float.nan);
        gvec4 textureProj(gsampler1D sampler, vec4 P, float bias = float.nan);
        gvec4 textureProj(gsampler2D sampler, vec3 P, float bias = float.nan);
        gvec4 textureProj(gsampler2D sampler, vec4 P, float bias = float.nan);
        gvec4 textureProj(gsampler3D sampler, vec4 P, float bias = float.nan);
        float textureProj(sampler1DShadow sampler, vec4 P, float bias = float.nan);
        float textureProj(sampler2DShadow sampler, vec4 P, float bias = float.nan);
        gvec4 textureProj(gsampler2DRect sampler, vec3 P);
        gvec4 textureProj(gsampler2DRect sampler, vec4 P);
        float textureProj(sampler2DRectShadow sampler, vec4 P);
    }.specialize);
    mixin(q{
        gvec4 textureLod(gsampler1D sampler, float P, float lod);
        gvec4 textureLod(gsampler2D sampler, vec2 P, float lod);
        gvec4 textureLod(gsampler3D sampler, vec3 P, float lod);
        gvec4 textureLod(gsamplerCube sampler, vec3 P, float lod);
        float textureLod(sampler1DShadow sampler, vec3 P, float lod);
        float textureLod(sampler2DShadow sampler, vec3 P, float lod);
        gvec4 textureLod(gsampler1DArray sampler, vec2 P, float lod);
        gvec4 textureLod(gsampler2DArray sampler, vec3 P, float lod);
        float textureLod(sampler1DArrayShadow sampler, vec3 P, float lod);
    }.specialize);
    mixin(q{
        gvec4 textureOffset(gsampler1D sampler, float P, int offset, float bias = float.nan);
        gvec4 textureOffset(gsampler2D sampler, vec2 P, ivec2 offset, float bias = float.nan);
        gvec4 textureOffset(gsampler3D sampler, vec3 P, ivec3 offset, float bias = float.nan);
        gvec4 textureOffset(gsampler2DRect sampler, vec2 P, ivec2 offset);
        float textureOffset(sampler2DRectShadow sampler, vec3 P, ivec2 offset);
        float textureOffset(sampler1DShadow sampler, vec3 P, int offset, float bias = float.nan);
        float textureOffset(sampler2DShadow sampler, vec3 P, ivec2 offset, float bias = float.nan);
        gvec4 textureOffset(gsampler1DArray sampler, vec2 P, int offset, float bias = float.nan);
        gvec4 textureOffset(gsampler2DArray sampler, vec3 P, ivec2 offset, float bias = float.nan);
        float textureOffset(sampler1DArrayShadow sampler, vec3 P, int offset, float bias = float.nan);
    }.specialize);
    mixin(q{
        gvec4 texelFetch(gsampler1D sampler, int P, int lod);
        gvec4 texelFetch(gsampler2D sampler, ivec2 P, int lod);
        gvec4 texelFetch(gsampler3D sampler, ivec3 P, int lod);
        gvec4 texelFetch(gsampler2DRect sampler, ivec2 P);
        gvec4 texelFetch(gsampler1DArray sampler, ivec2 P, int lod);
        gvec4 texelFetch(gsampler2DArray sampler, ivec3 P, int lod);
        gvec4 texelFetch(gsamplerBuffer sampler, int P);
        gvec4 texelFetch(gsampler2DMS sampler, ivec2 P, int sample);
        gvec4 texelFetch(gsampler2DMSArray sampler, ivec3 P, int sample);
    }.specialize);
    mixin(q{
        gvec4 texelFetchOffset(gsampler1D sampler, int P, int lod, int offset);
        gvec4 texelFetchOffset(gsampler2D sampler, ivec2 P, int lod, ivec2 offset);
        gvec4 texelFetchOffset(gsampler3D sampler, ivec3 P, int lod, ivec3 offset);
        gvec4 texelFetchOffset(gsampler2DRect sampler, ivec2 P, ivec2 offset);
        gvec4 texelFetchOffset(gsampler1DArray sampler, ivec2 P, int lod, int offset);
        gvec4 texelFetchOffset(gsampler2DArray sampler, ivec3 P, int lod,ivec2 offset);
    }.specialize);
    mixin(q{
        gvec4 textureProjOffset(gsampler1D sampler, vec2 P, int offset, float bias = float.nan);
        gvec4 textureProjOffset(gsampler1D sampler, vec4 P, int offset, float bias = float.nan);
        gvec4 textureProjOffset(gsampler2D sampler, vec3 P, ivec2 offset, float bias = float.nan);
        gvec4 textureProjOffset(gsampler2D sampler, vec4 P, ivec2 offset, float bias = float.nan);
        gvec4 textureProjOffset(gsampler3D sampler, vec4 P, ivec3 offset, float bias = float.nan);
        gvec4 textureProjOffset(gsampler2DRect sampler, vec3 P, ivec2 offset);
        gvec4 textureProjOffset(gsampler2DRect sampler, vec4 P, ivec2 offset);
        float textureProjOffset(sampler2DRectShadow sampler, vec4 P, ivec2 offset);
        float textureProjOffset(sampler1DShadow sampler, vec4 P, int offset, float bias = float.nan);
        float textureProjOffset(sampler2DShadow sampler, vec4 P, ivec2 offset, float bias = float.nan);
    }.specialize);
    mixin(q{
        gvec4 textureLodOffset(gsampler1D sampler, float P, float lod, int offset);
        gvec4 textureLodOffset(gsampler2D sampler, vec2 P, float lod, ivec2 offset);
        gvec4 textureLodOffset(gsampler3D sampler, vec3 P, float lod, ivec3 offset);
        float textureLodOffset(sampler1DShadow sampler, vec3 P, float lod, int offset);
        float textureLodOffset(sampler2DShadow sampler, vec3 P, float lod, ivec2 offset);
        gvec4 textureLodOffset(gsampler1DArray sampler, vec2 P, float lod, int offset);
        gvec4 textureLodOffset(gsampler2DArray sampler, vec3 P, float lod, ivec2 offset);
        float textureLodOffset(sampler1DArrayShadow sampler, vec3 P, float lod, int offset);
    }.specialize);
    mixin(q{
        gvec4 textureProjLod (gsampler1D sampler, vec2 P, float lod);
        gvec4 textureProjLod (gsampler1D sampler, vec4 P, float lod);
        gvec4 textureProjLod (gsampler2D sampler, vec3 P, float lod);
        gvec4 textureProjLod (gsampler2D sampler, vec4 P, float lod);
        gvec4 textureProjLod (gsampler3D sampler, vec4 P, float lod);
        float textureProjLod (sampler1DShadow sampler, vec4 P, float lod);
        float textureProjLod (sampler2DShadow sampler, vec4 P, float lod);
    }.specialize);
    mixin(q{
        gvec4 textureProjLodOffset(gsampler1D sampler, vec2 P, float lod, int offset);
        gvec4 textureProjLodOffset(gsampler1D sampler, vec4 P, float lod, int offset);
        gvec4 textureProjLodOffset(gsampler2D sampler, vec3 P, float lod, ivec2 offset);
        gvec4 textureProjLodOffset(gsampler2D sampler, vec4 P, float lod, ivec2 offset);
        gvec4 textureProjLodOffset(gsampler3D sampler, vec4 P, float lod, ivec3 offset);
        float textureProjLodOffset(sampler1DShadow sampler, vec4 P, float lod, int offset);
        float textureProjLodOffset(sampler2DShadow sampler, vec4 P, float lod, ivec2 offset);
    }.specialize);
    mixin(q{
        gvec4 textureGrad(gsampler1D sampler, float P, float dPdx, float dPdy);
        gvec4 textureGrad(gsampler2D sampler, vec2 P, vec2 dPdx, vec2 dPdy);
        gvec4 textureGrad(gsampler3D sampler, vec3 P, vec3 dPdx, vec3 dPdy);
        gvec4 textureGrad(gsamplerCube sampler, vec3 P, vec3 dPdx, vec3 dPdy);
        gvec4 textureGrad(gsampler2DRect sampler, vec2 P, vec2 dPdx, vec2 dPdy);
        float textureGrad(sampler2DRectShadow sampler, vec3 P, vec2 dPdx, vec2 dPdy);
        float textureGrad(sampler1DShadow sampler, vec3 P, float dPdx, float dPdy);
        float textureGrad(sampler2DShadow sampler, vec3 P, vec2 dPdx, vec2 dPdy);
        float textureGrad(samplerCubeShadow sampler, vec4 P, vec3 dPdx, vec3 dPdy);
        gvec4 textureGrad(gsampler1DArray sampler, vec2 P, float dPdx, float dPdy);
        gvec4 textureGrad(gsampler2DArray sampler, vec3 P, vec2 dPdx, vec2 dPdy);
        float textureGrad(sampler1DArrayShadow sampler, vec3 P, float dPdx, float dPdy);
        float textureGrad(sampler2DArrayShadow sampler, vec4 P, vec2 dPdx, vec2 dPdy);
    }.specialize);
    mixin(q{
        gvec4 textureGradOffset(gsampler1D sampler, float P, float dPdx, float dPdy, int offset);
        gvec4 textureGradOffset(gsampler2D sampler, vec2 P, vec2 dPdx, vec2 dPdy, ivec2 offset);
        gvec4 textureGradOffset(gsampler3D sampler, vec3 P, vec3 dPdx, vec3 dPdy, ivec3 offset);
        gvec4 textureGradOffset(gsampler2DRect sampler, vec2 P, vec2 dPdx, vec2 dPdy, ivec2 offset);
        float textureGradOffset(sampler2DRectShadow sampler, vec3 P, vec2 dPdx, vec2 dPdy, ivec2 offset);
        float textureGradOffset(sampler1DShadow sampler, vec3 P, float dPdx, float dPdy, int offset );
        float textureGradOffset(sampler2DShadow sampler, vec3 P, vec2 dPdx, vec2 dPdy, ivec2 offset);
        gvec4 textureGradOffset(gsampler1DArray sampler, vec2 P, float dPdx, float dPdy, int offset);
        gvec4 textureGradOffset(gsampler2DArray sampler, vec3 P, vec2 dPdx, vec2 dPdy, ivec2 offset);
        float textureGradOffset(sampler1DArrayShadow sampler, vec3 P, float dPdx, float dPdy, int offset);
        float textureGradOffset(sampler2DArrayShadow sampler, vec4 P, vec2 dPdx, vec2 dPdy, ivec2 offset);
    }.specialize);
    mixin(q{
        gvec4 textureProjGrad(gsampler1D sampler, vec2 P, float dPdx, float dPdy);
        gvec4 textureProjGrad(gsampler1D sampler, vec4 P, float dPdx, float dPdy);
        gvec4 textureProjGrad(gsampler2D sampler, vec3 P, vec2 dPdx, vec2 dPdy);
        gvec4 textureProjGrad(gsampler2D sampler, vec4 P, vec2 dPdx, vec2 dPdy);
        gvec4 textureProjGrad(gsampler3D sampler, vec4 P, vec3 dPdx, vec3 dPdy);
        gvec4 textureProjGrad(gsampler2DRect sampler, vec3 P, vec2 dPdx, vec2 dPdy);
        gvec4 textureProjGrad(gsampler2DRect sampler, vec4 P, vec2 dPdx, vec2 dPdy);
        float textureProjGrad(sampler2DRectShadow sampler, vec4 P, vec2 dPdx, vec2 dPdy);
        float textureProjGrad(sampler1DShadow sampler, vec4 P, float dPdx, float dPdy);
        float textureProjGrad(sampler2DShadow sampler, vec4 P, vec2 dPdx, vec2 dPdy);
    }.specialize);
    mixin(q{
        gvec4 textureProjGradOffset(gsampler1D sampler, vec2 P, float dPdx, float dPdy, int offset);
        gvec4 textureProjGradOffset(gsampler1D sampler, vec4 P, float dPdx, float dPdy, int offset);
        gvec4 textureProjGradOffset(gsampler2D sampler, vec3 P, vec2 dPdx, vec2 dPdy, vec2 offset);
        gvec4 textureProjGradOffset(gsampler2D sampler, vec4 P, vec2 dPdx, vec2 dPdy, vec2 offset);
        gvec4 textureProjGradOffset(gsampler2DRect sampler, vec3 P, vec2 dPdx, vec2 dPdy, ivec2 offset);
        gvec4 textureProjGradOffset(gsampler2DRect sampler, vec4 P, vec2 dPdx, vec2 dPdy, ivec2 offset);
        float textureProjGradOffset(sampler2DRectShadow sampler, vec4 P, vec2 dPdx, vec2 dPdy, ivec2 offset);
        gvec4 textureProjGradOffset(gsampler3D sampler, vec4 P, vec3 dPdx, vec3 dPdy, vec3 offset);
        float textureProjGradOffset(sampler1DShadow sampler, vec4 P, float dPdx, float dPdy, int offset);
        float textureProjGradOffset(sampler2DShadow sampler, vec4 P, vec2 dPdx, vec2 dPdy, vec2 offset);
    }.specialize);
}
