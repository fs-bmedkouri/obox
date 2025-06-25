#+private

package framebuffer

import "core:c"

FB_Definition :: struct {
	ptr: rawptr,
	width, height, pitch: c.int,
}

foreign {
	kernel_fb_definition :: proc "c" () -> ^FB_Definition ---
	kernel_wait_for_vsync :: proc "c" () ---
}

intermediate_buffer: []byte

@(init)
setup_framebuffer :: proc() {
	fb := kernel_fb_definition()
	intermediate_buffer = make([]byte, int(fb.pitch * fb.height))
}
