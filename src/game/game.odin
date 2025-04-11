package game

import scene "../scene"
import "core:fmt"
import rl "vendor:raylib"

REM :: 16

GFont :: struct {
    core:    rl.Font,
    size:    i32,
    spacing: i32,
    color:   rl.Color,
}

GSound :: struct {
    load:        rl.Music,
    wrong:       rl.Music,
    time_played: f32,
}

Answer :: enum {
    Yes,
    No,
}

State :: enum {
    MainMenu,
    Question,
    Loading,
    Exit,
    BlankLoad,
    BlankLoadWrong,
    WrongAnswer,
}

Game :: struct {
    screenWidth:  i32,
    screenHeight: i32,
    font:         GFont,
    state:        State,
    quit:         bool,
    background:   rl.Image,
    bgVisible:    bool,
    sound:        GSound,
    scenes:       []scene.Scene,
    currentScene: i32,
}

newGame :: proc(width, height: i32, font: GFont) -> (game: Game) {
    scenes, ok := scene.parseScenes()
    if !ok {
        fmt.eprintln("Can't open scenes")
    }
    game = {
        screenWidth  = width,
        screenHeight = height,
        font         = font,
        state        = .MainMenu,
        quit         = false,
        bgVisible    = true,
        scenes       = scenes,
        currentScene = 0,
    }
    return
}

closeGame :: proc(game: ^Game) {
    rl.UnloadFont(game.font.core)
    game.state = .Exit
}

mainMenu :: proc(game: ^Game) {
    title: cstring = "Dream Job"
    start: cstring = "Start"
    exit: cstring = "Exit"
    option_fontsize: i32 = REM * 4

    title_x, title_y :=
        game.screenWidth / 2 -
        rl.MeasureText(title, game.font.size) / 2,
        60 +
        game.font.size

    start_x, start_y :=
        game.screenWidth / 2 -
        rl.MeasureText(start, option_fontsize) / 2,
        rl.GetScreenHeight() / 2 +
        50

    exit_x, exit_y :=
        game.screenWidth / 2 -
        rl.MeasureText(exit, option_fontsize) / 2,
        start_y +
        100

    rl.DrawText(title, title_x, title_y, game.font.size, game.font.color)
    rl.DrawText(start, start_x, start_y, option_fontsize, game.font.color)
    rl.DrawText(exit, exit_x, exit_y, option_fontsize, game.font.color)

    if (rl.IsKeyPressed(rl.KeyboardKey.ENTER)) {
        game.state = .Question
    } else if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
        mpos := rl.GetMousePosition()
        mx, my := i32(mpos.x), i32(mpos.y)
        if start_x <= mx &&
           mx <= start_x + rl.MeasureText(start, option_fontsize) &&
           start_y <= my &&
           my <= start_y + option_fontsize {
            game.state = .BlankLoad
        } else if exit_x <= mx &&
           mx <= exit_x + rl.MeasureText(exit, option_fontsize) &&
           exit_y <= my &&
           my <= exit_y + option_fontsize {
            game.state = .Exit
        }
    }
    return
}

question :: proc(game: ^Game, correct_answer: Answer) {
    title: cstring = "Do you like\n to smile?"

    title_x := game.screenWidth / 2 - rl.MeasureText(title, game.font.size) / 2
    title_y := 60 + game.font.size

    rl.DrawText(title, title_x, title_y, game.font.size, game.font.color)

    yes_pos, no_pos := drawAnswers(game, .Yes)

    if rl.IsKeyPressed(rl.KeyboardKey.ENTER) {
        game.state = .MainMenu
    } else if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
        mpos := rl.GetMousePosition()
        mx, my := mpos.x, mpos.y

        if yes_pos.x <= mx &&
           mx <= yes_pos.x + f32(rl.MeasureText("Yes", 32)) &&
           yes_pos.y <= my &&
           my <= yes_pos.y + 32 {
            game.state =
                .BlankLoad if correct_answer == .Yes else .BlankLoadWrong
        } else if no_pos.x <= mx &&
           mx <= no_pos.x + f32(rl.MeasureText("No", 32)) &&
           no_pos.y <= my &&
           my <= no_pos.y + 32 {
            game.state =
                .BlankLoad if correct_answer == .No else .BlankLoadWrong
        }
    }
    return
}

loading :: proc(game: ^Game) {
    time_played: f32
    rl.PlayMusicStream(game.sound.load)

    for rl.IsMusicStreamPlaying(game.sound.load) {
        time_played =
            rl.GetMusicTimePlayed(game.sound.load) /
            rl.GetMusicTimeLength(game.sound.load)
        if time_played >= 0.9 {
            rl.StopMusicStream(game.sound.load)
            game.state = .Question
        } else {
            rl.UpdateMusicStream(game.sound.load)
        }
    }
}

drawAnswers :: proc(
    game: ^Game,
    correct_answer: Answer,
) -> (
    yes_pos, no_pos: rl.Vector2,
) {
    yes, no: cstring = "Yes", "No"
    center_x := rl.GetScreenWidth() / 2
    center_y := rl.GetScreenHeight() / 2
    yes_pos.x, yes_pos.y = f32(center_x - 100), f32(center_y)
    no_pos.x, no_pos.y = f32(center_x + 100), f32(center_y)
    rl.DrawText(yes, i32(yes_pos.x), i32(yes_pos.y), 32, game.font.color)
    rl.DrawText(no, i32(no_pos.x), i32(no_pos.y), 32, game.font.color)
    return
}

exit :: proc(game: ^Game) {
    game.quit = true
}

resizeWindow :: proc(game: ^Game) {
    game.screenWidth = rl.GetScreenWidth()
    game.screenHeight = rl.GetScreenHeight()
}

transferTo :: proc(game: ^Game, state: State) {
    game.state = state
}

wrongAnswer :: proc(game: ^Game) {
    text: cstring = "WRONG ANSWER"

    rl.DrawRectangle(0, 0, game.screenWidth, game.screenHeight, rl.RED)
    rl.DrawText(
        text,
        rl.GetScreenWidth() / 2 - rl.MeasureText(text, 54) / 2,
        rl.GetScreenHeight() / 2,
        54,
        rl.BLACK,
    )

    rl.PlayMusicStream(game.sound.wrong)
    rl.SetMusicVolume(game.sound.wrong, 0.4)
    game.sound.time_played =
        rl.GetMusicTimePlayed(game.sound.wrong) /
        rl.GetMusicTimeLength(game.sound.wrong)
    if game.sound.time_played >= 0.4 {
        rl.StopMusicStream(game.sound.wrong)
        game.sound.time_played = 0
        game.state = .Question
        return
    } else {
        rl.UpdateMusicStream(game.sound.wrong)
    }
}

handleState :: proc(game: ^Game) {
    if rl.IsWindowResized() {
        resizeWindow(game)
    }
    #partial switch game.state {
    case .MainMenu:
        mainMenu(game)
    case .Loading:
        loading(game)
    case .Exit:
        exit(game)
        case .Question:
        loadScene(game)
    case .BlankLoad:
        transferTo(game, .Loading)
    }
}

loadScene :: proc(game: ^Game) {
    currentScene := game.scenes[game.currentScene]
    switch currentScene.amountOfAnswers {
    case 1:
        drawScene1(game)
    case 2:
        drawScene2(game)
    case 4:
        drawScene4(game)
    case:
        exit(game)
    }
}

drawScene1 :: proc(game: ^Game) {
    src := game.scenes[game.currentScene]
    option_fontsize: i32 = 32
    answer_width := rl.MeasureText(src.answers[0], game.font.size)

    title_x, title_y :=
        game.screenWidth / 2 -
        rl.MeasureText(src.title, game.font.size) / 2,
        60 +
        game.font.size

    answer_x, answer_y :=
        game.screenWidth / 2 - answer_width / 2, rl.GetScreenHeight() / 2 + 50

    rl.DrawText(src.title, title_x, title_y, game.font.size, game.font.color)

    answer_rec: rl.Rectangle = {
        x      = f32(answer_x),
        y      = f32(answer_y),
        width  = f32(answer_width),
        height = f32(option_fontsize),
    }

    rl.DrawRectangleRec(answer_rec, rl.WHITE)
    rl.DrawText(
        src.answers[0],
        answer_x,
        answer_y,
        option_fontsize,
        game.font.color,
    )

    if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
        mpos := rl.GetMousePosition()
        if (rl.CheckCollisionPointRec(mpos, answer_rec)) {
            game.currentScene += 1
            game.state = .BlankLoad
        }
    }
    return
}

drawScene2 :: proc(game: ^Game) {}

drawScene4 :: proc(game: ^Game) {

}
