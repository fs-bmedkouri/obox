package assets

import "core:log"
import "core:slice"
import "core:strings"

load :: proc(name: string) -> (data: []byte, ok: bool) {
	path, err := strings.join({name}, "/", context.temp_allocator)
	if err != .None {
		return
	}

	cpath, cerr := strings.clone_to_cstring(path, context.temp_allocator)
	if cerr != .None {
		return
	}
		
	ptr := kernel_load_asset(cpath)
	if ptr == nil {
		log.error("Could not load asset: ", name)
		return
	}

	data = slice.bytes_from_ptr(ptr, int(kernel_load_asset_len()))
	ok = true
	return
}

unload :: proc(asset: []byte) {
	free(&asset[0])
}
