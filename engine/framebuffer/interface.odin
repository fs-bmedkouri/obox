package framebuffer

import "core:slice"

Pixel :: struct #packed {
	r, g, b, _: u8,
}

memory :: proc() -> []byte {
	fb := kernel_fb_definition()
	return slice.bytes_from_ptr(fb.ptr, int(fb.pitch * fb.height))
}

pixels :: proc() -> []Pixel {
	return slice.reinterpret([]Pixel, memory())
}

put_pixel :: proc(x, y: int, c: Pixel) {
	if x < 0 || y < 0 {
		return
	}

	fb := kernel_fb_definition()
	if x >= int(fb.width) || y >= int(fb.height) {
		return
	}
	pixels()[y * int(fb.pitch / 4) + x] = c
}

geometry :: proc() -> (width, height, pitch: int) {
	fb := kernel_fb_definition()
	width = int(fb.width)
	height = int(fb.height)
	pitch = int(fb.pitch)
	return
}
