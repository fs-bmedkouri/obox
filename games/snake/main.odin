package game

import "core:log"
import "core:time"
import "core:slice"
import fb "engine:framebuffer"
import "engine:gamepad"

WINDOW_SIZE :: 1000
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH*CELL_SIZE
TICK_RATE :: 0.13
Vec2i :: [2]int
MAX_SNAKE_LENGTH :: GRID_WIDTH*GRID_WIDTH

snake: [MAX_SNAKE_LENGTH]Vec2i // keep in mind that we need to use cell_size per snake square when rendering
snake_length: int
tick_timer: f32 = TICK_RATE
move_direction: Vec2i
game_over: bool
food_pos: Vec2i
high_score: int

SQUARE_SIZE :: 40
SQUARE_SPEED :: 0.1

square_pos := [2]f64{100, 100}
bg_color_index: int
square_color_index := 1

button_state: gamepad.Buttons

restart :: proc() {
	start_head_pos := Vec2i { GRID_WIDTH / 2, GRID_WIDTH / 2 }
	snake[0] = start_head_pos
	snake[1] = start_head_pos - {0, 1}
	snake[2] = start_head_pos - {0, 2}
	high_score = high_score < snake_length - 3 ? snake_length - 3 : high_score // snake_length is used to set the score
	snake_length = 3
	move_direction = {0, 1}
	game_over = false
	// place_food()
}

@(init)
initialize :: proc() {
	log.info("Hello World!")

	// Checking for width and height. Remove after checking
	width, height, pitch := fb.geometry()
	log.infof("Width: %v\nHeight: %v\nPitch: %v", width, height, pitch, "Initialize")

	restart()
}

update :: proc(dt: time.Duration) {
	buttons := gamepad.read(0)

	// ms := time.duration_milliseconds(dt)
	switch {
	case .LEFT in buttons:
		move_direction = {0, -1}
		// square_pos[0] -= SQUARE_SPEED * ms
	case .RIGHT in buttons:
		move_direction = {0, 1}
		// square_pos[0] += SQUARE_SPEED * ms
	case .UP in buttons:
		move_direction = {-1, 0}
		// square_pos[1] -= SQUARE_SPEED * ms
	case .DOWN in buttons:
		move_direction = {1, 0}
		// square_pos[1] += SQUARE_SPEED * ms
	}

	if game_over {
		if buttons != button_state {
			if .A in buttons {
				restart()
			}
			// log.info("Gamepad button state: ", buttons)
			// switch {
			// 	case .A in buttons:
			// 		square_color_index += 1
			// 	case .B in buttons:
			// 		bg_color_index += 1
			// }
			button_state = buttons
		}
	} else {
		tick_timer -= dt
	}

	if tick_timer <= 0 {
		next_part_pos := snake[0]

		//TODO: Need to make this work with wraparound logic
		if next_part_pos + move_direction == snake[1] {
			move_direction = -move_direction
		}

		snake[0] += move_direction
		head_pos := snake[0]

		switch {
		case head_pos.x < 0:
			head_pos.x = GRID_WIDTH - 1
			snake[0].x = head_pos.x
		case head_pos.x >= GRID_WIDTH:
			head_pos.x = 0
			snake[0].x = head_pos.x
		case head_pos.y < 0:
			head_pos.y = GRID_WIDTH - 1
			snake[0].y = head_pos.y
		case head_pos.y >= GRID_WIDTH:
			head_pos.y = 0
			snake[0].y = head_pos.y
		}

		for i in 1..<snake_length {
			cur_pos := snake[i]

			if cur_pos == head_pos {
				game_over = true
			}

			snake[i] = next_part_pos
			next_part_pos = cur_pos
		}

		// if head_pos == food_pos {
		// 	snake_length += 1
		// 	snake[snake_length - 1] = next_part_pos
		// 	place_food()
		// }

		tick_timer = TICK_RATE + tick_timer
	}
}

render :: proc() {
	// colors := [4]fb.Color{
	// 	{0xFF, 0xFF, 0xFF, 0},
	// 	{0x00, 0x00, 0xFF, 0},
	// 	{0xFF, 0x00, 0xFF, 0},
	// 	{0xFF, 0xFF, 0x00, 0},
	// }

	slice.fill

	fb.clear(colors[bg_color_index % len(colors)])

	// snake rendering here:

	// for y := 0; y < SQUARE_SIZE; y += 1 {
	// 	for x := 0; x < SQUARE_SIZE; x += 1 {
	// 		fb.put_pixel(int(square_pos[0]) + x, int(square_pos[1]) + y, colors[square_color_index % len(colors)])
	// 	}
	// }

	fb.swap()
}

shutdown :: proc() {
	log.info("By by!")
}
