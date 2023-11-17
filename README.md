# NES My Beloved

Final project for the *Computer Architecture and Organization* course.

# How to run the game

First of all, you should be on Windows to build this game.

If you are not on Windows, God help you, cause this tutorial will not.

This project uses [cc65](https://cc65.github.io/) to build the actual NES rom.
You can download the Windows version [here](https://cc65.github.io/getting-started.html)

After downloading, make sure the `bin` folder of `cc65` is available in your `$PATH` variable.
So for example, if you downloaded and unzip the `cc65` into the folder `C:\cc65-snapshot-win32`, you should add `C:\cc65-snapshot-win32\bin` to the `$PATH`.

[How to add Executables to your `$PATH`](https://medium.com/@kevinmarkvi/how-to-add-executables-to-your-path-in-windows-5ffa4ce61a53).

After that, just run in the shell:
```
./build.bat
```
This will build the game, creating the `main.nes` file, and execute it with the emulator `Mesen.exe`

It is possible that Mesen will ask you to install the .NET 6 Runtime when you run it for the first time. Just follow their instruction and you'll probably be ok.
