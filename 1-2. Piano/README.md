You can see more colourful and clear Readme in my [Notion](https://www.notion.so/Piano-Frame-Resident-f0ade7c7b0184e4b8ddb5d3b034da4ef)

The structure of piano code is described below:

Let's start with easy ones:

- **Drawing Frame (in MkFrame.asm)**
    - We simply getting access to video memory (which adress is `0b800h`) and changing symbols on screen
    - First we need to clear racktangle for frame
        - So we just fills rectangle with space symbols in double cycle
    - Then we need to draw borders
        - We doing that with functions `DrawVerticalBorder` and `DrawHorizontalBorder`, that can draw hole lines
        - And then we placing corners
- **Drawing Keys (in MkKeys.asm)**

    This action is very similar to Drawing Frame, but a little more complicated. That caused by location of keys and their structure

    - First we need to clear racktangle, that keys occupies. We doing this just like with frame - filling video memory with spaces
    - Then we need to draw key borders, so we doing it in 4 steps
        - Drawing upper border for every key
        - Drawing sides for every key
        - Drawing down border for every key
        - And drawing connections between flats and sharps and bottom of the keys

    Also in MkKeys.asm you can find functions, that drawing a keypress.

    They drawing special symbols with bright blue color on the key, that is playing now

Until this there was nothing hard, we were just drawing on screen. Let's talk about sound part of project:

- **Playing Sound (in MkSound.asm)**
    - First thing we need to `SetTimer`, it allows us to use speaker the way we need
    - To return speaker the way it was before there is `ResetTimer` function
    - To play some note we need to put its frequency in `ax` and call `PlayNote`
        - If speaker playing something it won't stop untill we `ResetTimer` or start playing something else
        - So we have `SetPause` function, that will play predefined note P that has very low frequency (so, you won't here it)
    - And we have `SetNote` function, that recieving scancode of pressed key, moving to `ax` frequency for that key and calling `PlayNote`

Maybe for now you don't understand how all these functtions cooperate with each other, but don't worry. Everything about their connection will be in the last toggle

- **Print number in different number systems (in NumOut.asm)**

    That part of program responsible for different representations of scancode that you can see on the top of the frame

    For each number system we will do the same: filling output buffer and pushing it to video memory

    - We recieving number and system in which we need to convert that number
    - So we could write number system to output buffer (like this `"bin: "`)
    - Then we converting scancode into recieved number system and writing it to output buffer (it will look like this `"bin: 11001"`)
    - After that we can push output buffer to video memory

And now we're going to talk about the most interesting thing in project. Resident and how to connect all the functions

- **Making programm resident (in Resident.asm and Main.asm)**

    Some theory about what we doing. When you press key, keyboard recieving scancode of key and sending iterrupt (9-th) to CPU. 

    It processing keypress with a standart function somewhere from memory (function's adress is written in BIOS standart segment).

    And we want to replace that standart function with our function - `Toxic`

    This toggle describes how to do that and the next one - what `Toxic` does

    - First we need to go to the BOIS segment and `ChangeIntFunction`
        - It will save sagment and offset of standart function and change them to offset and segment of our function
    - Then we need to end program but stay resident (`31` func of `int 21`)
        - So we will leave all the code (not only `Toxic`, all the functions it calls too) in memory
- **Function, that will process (in Resident.asm)**

    And now about `Toxic` function:

    - It calls after keyboard interrupt (when key was pressed), so firstly it loads scancode of pressed key in `ax`
    - Then it prints scancode in different representations (`"inp: "` corresponding to decimal representation)
    - After that it compares `ax` with different numbers to find what that key means - `Press` or `Release` pinao key, `StartPiano` or `StopPiano`
        - `StartPiano` is function that calls `SetTimer` ('S' is corresponding for that action)
        - `StopPiano` is function that calls `ResetTimer` ('A' is corresponding for that action)
        - `Press` is function that calls `SetNote` and then `DrawKeyPress` ('2', '3', '5'-'7', '9', '0' and the letter row closest to the numbers, from 'q' to 'p')
        - `Release` is function that calls `SetPause` and then `DrawKeys` to delete shadow
    - But what we should do next? There is keybord ports that should be set special way after key pressed
    - This was handled by the standard function, but we removed it, so after these 4 actions we will call `TalkToPorts` function, that setting ports the way we need
    - But after another actions we calls standart function (which segment and offset we saved)
