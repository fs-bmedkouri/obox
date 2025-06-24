package game

import "core:log"
import "core:time"
import "engine:kernel"
import fb "engine:framebuffer"

@(init)
initialize :: proc() {
	// Logging is not setup and sdcard assets can not be loaded here.
	// You can make use of static assests and allocate memory though.
}

startup :: proc() {
	log.info("Hello World!")
}

update :: proc(dt: time.Duration) {

}

render :: proc() {
	@(static) color_index: int
	w, h, _ := fb.geometry()

	for y := 0; y < h; y += 1 {
		for x := 0; x < w; x += 1 {
			colors := [4]fb.Pixel{
				{0xFF, 0xFF, 0xFF, 0},
				{0x00, 0xFF, 0xFF, 0},
				{0xFF, 0x00, 0xFF, 0},
				{0xFF, 0xFF, 0x00, 0},
			}

			fb.put_pixel(x, y, colors[color_index % 4])
		}
	}

	color_index += 1

	kernel.sleep(500 * time.Millisecond)
}

shutdown :: proc() {
	log.info("By by!")
}
