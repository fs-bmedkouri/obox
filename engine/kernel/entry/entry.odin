package entry

import "engine:kernel"
import "../../../game"

@(export)
game_update :: proc "c" (dt: f64) {
	context = kernel.default_context
	game.update(dt)
}

@(export)
game_render :: proc "c" () {
	context = kernel.default_context
	game.render()
}
