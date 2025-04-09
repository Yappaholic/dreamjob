package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:net"
import gm "game"
import rl "vendor:raylib"

main :: proc() {
	font: gm.GFont = {
		core    = rl.GetFontDefault(),
		size    = gm.REM * 6,
		spacing = 1,
		color   = rl.WHITE,
	}

	game: gm.Game = gm.newGame(800, 600, font)
	defer gm.closeGame(&game)

	configFlags: rl.ConfigFlags = {rl.ConfigFlag.WINDOW_RESIZABLE}
	rl.SetConfigFlags(configFlags)
	rl.SetTargetFPS(60)

	rl.InitWindow(game.screenWidth, game.screenHeight, "Dream Job")
	defer rl.CloseWindow()

	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()

	game.sound.load = rl.LoadMusicStream("resources/tape.mp3")
	defer rl.UnloadMusicStream(game.sound.load)

	game.sound.wrong = rl.LoadMusicStream("resources/wrong.mp3")
	defer rl.UnloadMusicStream(game.sound.wrong)

	game.background = rl.LoadImage("resources/background.jpg")
	defer rl.UnloadImage(game.background)

	bg_texture := rl.LoadTextureFromImage(game.background)

	//noise_texture, anim_frames := loadNoise()
	//current_anim_frame: i32

	for !bool(rl.WindowShouldClose()) && !bool(game.quit) {
		rl.BeginDrawing()
		defer rl.EndDrawing()


		if game.bgVisible {
			loadBackground(&game.background, &bg_texture)
		}

		rl.ClearBackground(rl.WHITE)

		gm.handleState(&game)
	}
}

loadBackground :: proc(bg: ^rl.Image, bg_texture: ^rl.Texture2D) {
	if rl.IsWindowResized() {
		width, height := rl.GetScreenWidth(), rl.GetScreenHeight()
		rl.UnloadTexture(bg_texture^)
		rl.ImageResize(bg, width, height)

		bg_texture^ = rl.LoadTextureFromImage(bg^)
	}
	rl.DrawTexture(bg_texture^, 0, 0, rl.WHITE)
}

loadNoise :: proc() -> (noise_texture: rl.Texture2D, anim_frames: i32) {
	noise_anim: rl.Image = rl.LoadImageAnim("./noise.gif", &anim_frames)
	rl.ImageResize(&noise_anim, rl.GetScreenWidth(), 80)
	noise_texture = rl.LoadTextureFromImage(noise_anim)
	return
}

displayNoise :: proc(noise_texture: rl.Texture2D, anim_frames: i32) {}
