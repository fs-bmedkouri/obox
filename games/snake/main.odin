package game

import "core:log"
// import "core:math/rand"
import "core:time"
import fb "engine:framebuffer"
import "engine:gamepad"

TICK_RATE :: 0.13
GRID_WIDTH :: 1824
GRID_HEIGHT :: 984
CELL_SIZE :: 16
MAX_SNAKE_LENGTH :: GRID_WIDTH*GRID_HEIGHT
Vec2i :: [2]int

//snake: []Vec2i
snake: ^[MAX_SNAKE_LENGTH]Vec2i
snake_length: int
tick_timer: f64 = TICK_RATE
move_direction: Vec2i
game_over: bool
// food_pos: Vec2i
high_score: int
// occupied: [GRID_WIDTH][GRID_HEIGHT]bool

bg_color_index: int
snake_color_index := 1

button_state: gamepad.Buttons

place_food :: proc() {
	// for i in 0..<snake_length {
	// 	occupied[snake[i].x][snake[i].y] = true
	// }

	// free_cells := make([dynamic]Vec2i, context.temp_allocator)

	// for x in 0..<GRID_WIDTH {
	// 	for y in 0..<GRID_HEIGHT {
	// 		if !occupied[x][y] {
	// 			append(&free_cells, Vec2i {x, y})
	// 		}
	// 	}
	// }

	// if len(free_cells) > 0 {
	// 	random_cell_index := rand.int_max(len(free_cells) - 1)
	// 	food_pos = free_cells[random_cell_index]
	// }
}

restart :: proc() {
	start_head_pos := Vec2i { GRID_WIDTH / 2, GRID_HEIGHT / 2 }
	snake[0] = start_head_pos
	snake[1] = start_head_pos - {0, 1}
	snake[2] = start_head_pos - {0, 2}
	high_score = high_score < snake_length - 3 ? snake_length - 3 : high_score // snake_length is used to set the score
	snake_length = 3
	move_direction = {0, 1}
	game_over = false
	place_food()
}

@(init)
initialize :: proc() {
	log.info("Hello World!")

	snake = new([MAX_SNAKE_LENGTH]Vec2i)

	restart()
}

update :: proc(dt: time.Duration) {
	buttons := gamepad.read(0)

	if .LEFT in buttons {
		move_direction = {0, -1}
	}

	if .RIGHT in buttons {
		move_direction = {0, 1}
	}

	if .UP in buttons {
		move_direction = {-1, 0}
	}

	if .DOWN in buttons {
		move_direction = {1, 0}
	}

	if buttons != button_state {
		log.info("Gamepad button state: ", buttons)
		if .B in buttons {
			bg_color_index += 1
		}
		if .Y in buttons {
			snake_color_index += 1
		}
	}

	if game_over {
		if buttons != button_state {
			if .A in buttons {
				restart()
			}
			button_state = buttons
		}
	} else {
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
			head_pos.y = GRID_HEIGHT - 1
			snake[0].y = head_pos.y
		case head_pos.y >= GRID_HEIGHT:
			head_pos.y = 0
			snake[0].y = head_pos.y
		}

		for i in 1..<snake_length {
			cur_pos := snake[i]

			if cur_pos == head_pos {
				log.info("Game Over!", "update")
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
	}
}

render :: proc() {
	colors := [4]fb.Color{
		{0xFF, 0xFF, 0xFF, 0},
		{0x00, 0x00, 0xFF, 0},
		{0xFF, 0x00, 0xFF, 0},
		{0xFF, 0xFF, 0x00, 0},
	}

	fb.clear(colors[bg_color_index % len(colors)])

	for i in 0..<snake_length {
		dir: Vec2i

		if i == 0 {
			dir = snake[i] - snake[i + 1]
		} else {
			dir = snake[i - 1] - snake[i]
		}

		for y in 0..<CELL_SIZE {
			y_offset := i * CELL_SIZE * dir.y
			for x in 0..<CELL_SIZE {
				x_offset := i * CELL_SIZE * dir.x
				fb.put_pixel(snake[i].x + x + x_offset, snake[i].y + y + y_offset, colors[snake_color_index % len(colors)])
			}
		}
	}

	fb.swap()
}

shutdown :: proc() {
	log.info("By by!")
}
