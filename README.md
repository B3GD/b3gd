#### License notice
B3GD is under a <a href="https://creativecommons.org/licenses/by-nc/4.0/deed.en">CC BY-NC 4.0</a> license  
Essentially, you can use this for any free projects, as long as you credit B3GD somewhere. 
(make sure to read the real terms though!)

<p align="center">
<img width="50%" height="1150" alt="logo" src="https://github.com/user-attachments/assets/bd3603df-dba9-4474-a000-970ae6d1af49" />
</p>
<p align="center">
"Engine" (Whats your definition?)
</p>

## What is it?

Modular FNF-style godot project, designed to be easy to work off and expand.
Originally designed just for [Beta 3](https://gamebanana.com/mods/639119), but cleaned up for generic use with an example project provided.

## Why use it?

B3GD is made to have a really small footprint, and to overall be something you can work with instead of working around.
Each part is written to be as digestible and customisable as possible, trying to lose a lot of the jank that comes with Legacy FNF.
If you don't like any part of the engine, you can remove it and replace it easily - input system, note rendering, chart editor, event playing, character scripts...

## Limitations

### Format Support
Any format godot supports is natively supported, for obvious reasons. What is not present is implementations for Sparrow or other less common formats. These must be provided from elsewhere or made yourself.

### Health
Health is not engine level. Its dead simple to make yourself, so i didn't see a need.

### Keybinds
The default input system expects inputs by the name of "strumline_x" (x being the strumline index).
Multikey is fully supported internally, but you may have to hotswap inputs with InputMap if you want custom keybinds.

### Chart Creation
Charts must be initialised in the godot editor, by creating a Charts resource as input into the ChartPlayer. Here you can set up the strumlines and song metadata.
Once the chart is created, there is a fully featured chart editor (Press F7 in any song while testing to swap live! This runs on-top of normal gameplay, allowing for accurate live preview)

### Event Exports
Although every format is supported, the chart editor is limited on what it can edit.
Supported types:
- Bool
- Int (Int enums included)
- Float
- String
- Vector2-4
- Vector2i-4i
- Color

## BUCKET LIST
If theres anything here you want that is not on this list, feel free to either create an issue or create a pull request for what you want.

Chart Editor:
- [ ] Vortex-style input support
- [ ] Undo / Redo
- [ ] Selection: Copy & Paste Notes & Events
- [ ] Per-Note NoteClass parameters
- [ ] Changing StrumLine options from Chart Editor (CPU, Key Count)
- [ ] Changing StrumLine count (Add, Remove)
- [ ] Chart Editor Cleanup? (The chart editor is the most complicated thing in the codebase. I think some of it could be refactored down into more digestible chunks.

Default Note Render (3dGridRenderer):
- [ ] Fix Hold Rotation for modcharts (Hold rotation currently follows the note rotation, rather than pointing in the direction it heads)
