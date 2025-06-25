package game

import "core:log"
import "core:time"
import fb "engine:framebuffer"
import "engine:gamepad"

SQUARE_SIZE :: 40
SQUARE_SPEED :: 0.1

square_pos := [2]f64{100, 100}
bg_color_index: int
square_color_index := 1

button_state: gamepad.Buttons

@(init)
initialize :: proc() {
	log.info("Hello World!")
}

update :: proc(dt: time.Duration) {
	buttons := gamepad.read(0)

	ms := time.duration_milliseconds(dt)
	switch {
		case .LEFT in buttons:
			square_pos[0] -= SQUARE_SPEED * ms
		case .RIGHT in buttons:
			square_pos[0] += SQUARE_SPEED * ms
		case .UP in buttons:
			square_pos[1] -= SQUARE_SPEED * ms
		case .DOWN in buttons:
			square_pos[1] += SQUARE_SPEED * ms
	}

	if buttons != button_state {
		log.info("Gamepad button state: ", buttons)
		switch {
			case .A in buttons:
				square_color_index += 1
			case .B in buttons:
				bg_color_index += 1
		}
		button_state = buttons
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
	for y := 0; y < SQUARE_SIZE; y += 1 {
		for x := 0; x < SQUARE_SIZE; x += 1 {
			fb.put_pixel(int(square_pos[0]) + x, int(square_pos[1]) + y, colors[square_color_index % len(colors)])
		}
	}

	fb.swap()
}

shutdown :: proc() {
	log.info("By by!")
}
