# PanelPulley

MacOS でウィンドウを指定して、サイズとか位置をターミナルから変更するツールです。

Install
---

以下の方法でインストールできます。 Homebrew には対応していません。

- [Release](https://github.com/mike-neck/PanelPulley/releases) からダウンロードする
- [ビルド](#build)する

Usage
---

このツールには以下の二つのサブコマンドがあります。 `list` コマンドによって取得したウィンドウID を `resize` コマンドに渡した上でサイズ・位置を指定してください。

- `list` サブコマンド - App のウィンドウの一覧を表示します。
- `resize` サブコマンド - 指定したウィンドウのサイズ(`width`/`height`)および表示位置(`xAxis`/`yAxis`(`0`が上、値が大きくなると下になる))を変更します。

`list` サブコマンドを実行すると以下のとおり表示されます。

```shell
$ pp list
    88 Terminal                       [w=1814,h= 558,x= 190,y= 330] PanelPulley — -zsh — 164×21
 23467 Xcode                          [w=1021,h= 746,x=   6,y=  25] PanelPulley — List.swift — Edited
 36645 CLion                          [w=1884,h=1967,x=1920,y=  25] PanelPulley – List.swift
 39042 Google Chrome                  [w=1919,h=1102,x=   0,y=  25] mike-neck/PanelPulley: MacOS でターミナルからウィンドウを指定してサイズを変更するユーティリティ
```

一番左に表示された数値がウィンドウを識別する数値です。
これを `resize` サブコマンドで指定して、サイズや位置の操作をおこないます。

```shell
$ pp resize \
     --target-window 23467 \
     --width 1920 \
     --height 1080 \
     --xAxis 0 \
     --yAxis 25
```

`resize` サブコマンドのオプションについては `pp help resize` にて表示されるオプションを参照してください。

Build
---

ビルドは `make` でおこないます。
ビルドには `swift` 、 `swiftc` および `swift-format` が必要です。 

以下のコマンドによってビルドします。

```shell
$ make build
```

作成されたバイナリーは `build/release` ディレクトリーにあります。
