package scene

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "vendor:raylib"

Scene :: struct {
    title:             cstring,
    amountOfAnswers: i32,
    answers:           []cstring,
    correctAnswer:     i32,
}

Game_Scenes :: struct {
    scenes: []Scene,
}

parseScenes :: proc() -> (scenes: []Scene, ok: bool) {
    file_path :: #directory + "/scenes.json"
    file, file_err := os.read_entire_file_from_filename(file_path)

    if !file_err {
        fmt.eprintln("Failed to load scenes")
        return nil, false
    }

    defer delete(file)
    game_scenes: Game_Scenes
    err := json.unmarshal(file, &game_scenes)
    if err != nil {
        fmt.eprintf("Failed to parse json file\nError: %s", err)
        return nil, false
    }
    return game_scenes.scenes, true
}
