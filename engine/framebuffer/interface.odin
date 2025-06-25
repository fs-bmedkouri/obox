package framebuffer

import "core:slice"

Color :: struct #packed {
	r, g, b, _: u8,
}

memory :: proc() -> []byte {
	fb := kernel_fb_definition()
	return slice.bytes_from_ptr(fb.ptr, int(fb.pitch * fb.height))
}

pixels :: proc() -> []Color {
	return slice.reinterpret([]Color, memory())
}

put_pixel :: proc(x, y: int, c: Color) {
	if x < 0 || y < 0 {
		return
	}

	fb := kernel_fb_definition()
	if x >= int(fb.width) || y >= int(fb.height) {
		return
	}
	pixels()[y * int(fb.pitch / 4) + x] = c
}

clear :: proc(color := Color{}) {
	slice.fill(pixels(), color)
}

geometry :: proc() -> (width, height, pitch: int) {
	fb := kernel_fb_definition()
	width = int(fb.width)
	height = int(fb.height)
	pitch = int(fb.pitch)
	return
}
