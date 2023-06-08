# zig-micro-game

How to write a very small Linux game in Zig.

The goal of this project is to provide a working example of a small Linux game,
that can be used as starting point for your own game development.
This makes it easier to compete in game jams like the [4MB Jam](https://itch.io/jam/4mb).

The compressed binary of this example "game" has 8K and it contains:

* A trippy animated GLSL shader background
* A (OpenGL) triangle that can be moved with the cursor keys
* Interactive sound effects: Moving the triangle plays notes
* Simple music generated in real time

Predefined keyboard shortcuts:
* Esc = Quit
* f = Toggle between window and fullscreen mode
* A / Cursor Left = Left
* D / Cursor Right = Right
* W / Cursor Up  = Up
* S / Cursor Down  = Down


Please note that the animation is in reality much smoother (60fps) and with no screen tearing compared to this video: 

[![Demo Video](http://img.youtube.com/vi/9-FE2YLY7X0/0.jpg)](http://www.youtube.com/watch?v=9-FE2YLY7X0 "Demo Video")

If you want to build a real small game based on this basis, have a look at [game.zig](./src/game.zig) and have fun!

You might want to learn about OpenGL, for example here: [Learn OpenGL](https://learnopengl.com/).

## Build and Run

Tested with zig v0.10.1 on Ubuntu 20.04.

First install [Zig](https://ziglang.org/learn/getting-started/).

Then install lib dev packages:

    sudo apt install libgtk-3-dev libgl-dev libasound2-dev

Run with:

    zig build run

Build compressed release version:

    ./build-compressed-release.sh 

Running this script will also update the [size.txt](./size.txt) file, so you are always aware and in control of the file size and can compare it to previous versions.


## Inspired by

* https://github.com/Swoogan/ziggtk
* https://github.com/blackle/Linux-OpenGL-Examples
* https://github.com/donnerbrenn/gtk_4k_template
* https://in4k.github.io/wiki/linux

## Tools

* https://ziglang.org/
* https://github.com/aunali1/super-strip
* https://gitlab.com/PoroCYon/vondehi


## License

MIT


## Copyright

Copyright (c) 2023 Marco Stahl