package game

import "engine:kernel"
import "core:log"

@(export)
game_update :: proc "c" (dt: f64) {
	context = kernel.default_context

	log.info("Hi!")
}

@(export)
game_render :: proc "c" () {
	context = kernel.default_context

	// something
}
