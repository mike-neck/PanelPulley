# PanelPulley
A utility for resizing specific windows from the terminal on macOS

Install
---

The tool can be installed in the following ways. It is not supported on Homebrew.

- Download from [Release](https://github.com/mike-neck/PanelPulley/releases)
- [Build](#build) it

Usage
---

The tool has two subcommands. Please pass the window ID obtained by the `list` command to the `resize` command and specify the size and position.

- `list` sub command - Lists the windows of the App.
- `resize` sub command - Changes the size(`width`/`height`) and display position(`xAxis`/`yAxis`(`0` is at the top, and as the value increases, it becomes the bottom)) of the specified window.

When you run the `list` subcommand, it is displayed as follows.

```shell
$ pp list
    88 Terminal                       [w=1814,h= 558,x= 190,y= 330] PanelPulley — -zsh — 164×21
 23467 Xcode                          [w=1021,h= 746,x=   6,y=  25] PanelPulley — List.swift — Edited
 36645 CLion                          [w=1884,h=1967,x=1920,y=  25] PanelPulley – List.swift
 39042 Google Chrome                  [w=1919,h=1102,x=   0,y=  25] mike-neck/PanelPulley: MacOS でターミナルからウィンドウを指定してサイズを変更するユーティリティ
```

The number appearing on the far left is the identifier for the window.
Specify this with the `resize` sub command and manipulate the size and position.

```shell
$ pp resize \
     --target-window 23467 \
     --width 1920 \
     --height 1080 \
     --xAxis 0 \
     --yAxis 25
```

For `resize` subcommand options, refer to the options displayed by `pp help resize`.

Build
---

Builds are performed using `make`.
`swift`, `swiftc` and `swift-format` are required for the build.

The tool can be built with the following command.

```shell
$ make build
```

The created binary will be in the `build/release` directory.

Limitations
---

- It has been confirmed that the `resize` command cannot be executed in Google Chrome. 
