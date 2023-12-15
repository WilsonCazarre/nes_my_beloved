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

# Project Structure

| **Folder or File** |                                                          **Description**                                                          |
|:------------------:|:---------------------------------------------------------------------------------------------------------------------------------:|
|      **src/**      |                                                Source code for generating the ROM.                                                |
|     src/main.s     |                                     Entry point of our ROM, every other file is imported here.                                    |
|       src/lib      |                     Files for controlling NES modules like talking to the PPU or reading controller input etc.                    |
|       src/bin      |              Raw binary files. Usually the end up here so we don't have a giant array of bytes directly in our code.              |
|      src/state     | Main game logic. We tried to sperate the logic into multiple chunks of code, but most of it end up living in the `player.s` file. |

# Recommended Development VSCode extensions

- [Hex Editor](https://marketplace.visualstudio.com/items?itemName=ms-vscode.hexeditor) - Allows viewing and editing files in a raw binary format, useful for the nametable and attribute tables.

- [Alchemy65](https://marketplace.visualstudio.com/items?itemName=alchemic-raker.alchemy65) - Syntax Highlighting. It also connects to the Mesen debugger, allowing you to debug the NES ROM inside VSCode.

- [Trigger Task on Save](https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.triggertaskonsave) - Builds the game
automatically on saving.

The configuration for the extensions is also provided under the `.vscode` folder.