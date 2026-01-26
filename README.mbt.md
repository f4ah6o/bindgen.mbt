# bindgen.mbt

C/C++ ヘッダーファイルから MoonBit FFI バインディングを自動生成するツール。

## 機能

- **構造体 (struct)** - フィールドアクセス関数付きの不透明ポインタとして生成
- **共用体 (union)** - 構造体と同様にサポート
- **列挙型 (enum)** - `to_int` / `from_int` 変換関数付きで生成
- **関数** - `extern "C"` 宣言として生成
- **変数** - 定数として生成
- **Typedef** - タイプエイリアスとして生成

## CLI の使い方

### 基本的な使い方

```bash
bindgen.mbt mylib.h
```

### 出力をファイルに保存

```bash
bindgen.mbt -o bindings.mbt mylib.h
```

### インクルードパスを指定

```bash
bindgen.mbt -I /usr/include -I ./include mylib.h
```

### プリプロセッサマクロを定義

```bash
bindgen.mbt -D DEBUG -D VERSION='"1.0"' mylib.h
```

## オプション

| オプション | 説明 |
|-----------|------|
| `-h, --help` | ヘルプを表示 |
| `-o, --output <file>` | 出力ファイル（デフォルト: stdout） |
| `-I <path>` | インクルードパスを追加 |
| `-D <macro>` | プリプロセッサマクロを定義 |

## 生成されるコードの例

### C ヘッダー (example.h)

```c
typedef int my_int;

enum Color {
    RED,
    GREEN,
    BLUE
};

typedef struct {
    int x;
    int y;
} Point;

int add(int a, int b);
```

### 生成される MoonBit コード

```moonbit
///| Auto-generated MoonBit FFI bindings.
///| Do not edit manually.

///|
///| Type alias for my_int.
pub typealias my_int = Int

///|
///| Enum Color.
pub(all) enum Color {
  Red
  Green
  Blue
} derive(Eq, Show)

///|
///| Convert Color to its integer value.
pub fn Color::to_int(self : Color) -> Int {
  match self {
    Red => 0
    Green => 1
    Blue => 2
  }
}

///|
///| Create Color from an integer value.
pub fn Color::from_int(value : Int) -> Color? {
  match value {
    0 => Some(Red)
    1 => Some(Green)
    2 => Some(Blue)
    _ => None
  }
}

///|
///| Opaque pointer to Point.
pub struct Point(Int64)

///|
///| Get the 'x' field.
pub fn Point::x(self : Point) -> Int {
  // TODO: Implement field access
  abort("Not implemented")
}

///|
///| Get the 'y' field.
pub fn Point::y(self : Point) -> Int {
  // TODO: Implement field access
  abort("Not implemented")
}

///|
extern "C" fn add(a : Int, b : Int) -> Int = "add"
```

## 型マッピング

| C 型 | MoonBit 型 |
|------|-----------|
| `bool` | `Bool` |
| `char`, `signed char` | `Int` |
| `unsigned char` | `UInt` |
| `short` | `Int` |
| `unsigned short` | `UInt` |
| `int` | `Int` |
| `unsigned int` | `UInt` |
| `long`, `long long` | `Int64` |
| `unsigned long`, `unsigned long long` | `UInt64` |
| `float` | `Float` |
| `double` | `Double` |
| `void` | `Unit` |
| ポインタ型 | `Int64` |
| 配列 | `Int64` |

## ライブラリとしての使用方法

プログラム内で使用する場合:

```moonbit
let ctx = @parse.parse_header("mylib.h", clang_args)
let config = @codegen.CodegenConfig::default()
let output = @codegen.generate(ctx, config)
```

### CodegenConfig オプション

```moonbit
pub struct CodegenConfig {
  type_prefix : String           // 生成される型名のプレフィックス
  generate_accessors : Bool      // 構造体フィールドのアクセサ関数を生成
  use_opaque_pointers : Bool     // 不透明ポインタを使用
}

// デフォルト値
CodegenConfig::default() // {
//   type_prefix: "",
//   generate_accessors: true,
//   use_opaque_pointers: true
// }
```
