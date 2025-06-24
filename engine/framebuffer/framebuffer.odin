#+private

package framebuffer

import "core:c"

FB_Definition :: struct {
	ptr: rawptr,
	width, height, pitch: c.int,
}

foreign {
	kernel_fb_definition :: proc "c" () -> ^FB_Definition ---
}
