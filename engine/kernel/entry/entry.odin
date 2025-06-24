#+private

package entry

import "core:c"
import "core:time"

import "engine:kernel"
import game "game:."

@(require) import "engine:framebuffer"

@(export)
game_update :: proc "c" (dt: c.int64_t) {
	context = kernel.default_context
	game.update(time.Duration(dt))
}

@(export)
game_render :: proc "c" () {
	context = kernel.default_context
	game.render()
}
