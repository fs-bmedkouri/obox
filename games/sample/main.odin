package game

import "core:log"
import "core:time"
import "engine:kernel"
import fb "engine:framebuffer"

update :: proc(dt: time.Duration) {
	log.info("Hi!", dt)
}

render :: proc() {
	w, h, _ := fb.geometry()

	for y := 0; y < h; y += 1 {
		for x := 0; x < w; x += 1 {
			@(static) color_index: int
			colors := [4]fb.Pixel{
				{0xFF, 0xFF, 0xFF, 0},
				{0x0, 0xFF, 0xFF, 0},
				{0xFF, 0x0, 0xFF, 0},
				{0xFF, 0xFF, 0x0, 0},
			}
		
			kernel.sleep(10 * time.Millisecond)	

			fb.put_pixel(x, y, colors[color_index % 4])
		}
	}
}
