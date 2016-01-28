# dglsl

**このライブラリはα版であり、ほとんどの機能が未実装です。**

GLSL3.3のシェーダをD言語から使いやすくするためのライブラリです。

## インストール

dub.jsonに以下のように書いてください。

```json
  ...
  "stringImportPaths": ["./"],
  "dependencies": {
    "dglsl": "~>0.6.0"
  }
  ...
```

`stringImportPaths`の指定を忘れないようにしてください。

## 使い方

次のようにクラスとしてシェーダプログラムを定義します。
```dlang
import dglsl;

class VertShader : Shader!Vertex {
  @layout(location = 0)
  @input vec3 position;
  
  @layout(location = 1)
  @input vec3 color;
  
  @output vec3 vertColor;
  
  @uniform mat4 projectionMatrix;
  
  void main() {
    vertColor = color;
    gl_Position = projectionMatrix * vec4(position, 1.0);
  }
}

class FragShader : Shader!Fragment {
  @input vec3 vertColor;
  @output vec3 fragColor;
  
  void main() {
    fragColor = vec3(vertColor);
  }
}
```

次に、シェーダをコンパイルしてプログラムを作成します。

```dlang
auto shader = new VertShader();
shader.compile();

auto frag = new FragShader();
frag.compile();

auto p = makeProgram(shader, frag);
glUseProgram(p.id);
p.projectionMatrix = mat4.identity;
```

あとは標準のOpenGL3の機能を使って描画を行うことができます。
