package gamepad

import "core:c"

Buttons :: bit_set[enum {
	LB = 5,
	RB = 6,
	Y = 7,
	B = 8,
	A = 9,
	X = 10,
	UP = 15,
	RIGHT = 16,
	DOWN = 17,
	LEFT = 18,
}; c.uint]

read :: proc(index: int) -> Buttons {
	return transmute(Buttons)kernel_read_pad(c.int(index))
}
