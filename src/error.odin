package main

import rl "vendor:raylib"
import "core:os"

openErrorWindow :: proc(error_text: cstring) {
    width :: 320
    height :: 240
    rl.InitWindow(width, height, "Got an error!")

    for !bool(rl.WindowShouldClose()) {
        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.ClearBackground(rl.WHITE)
        rl.DrawText(error_text, width / 2, height / 2, 12, rl.BLACK)
    }
    os.exit(1)
}
