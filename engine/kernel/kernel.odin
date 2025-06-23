package kernel

import "base:runtime"
import "core:c"

default_context: runtime.Context

alloc_proc :: proc "c" (c.size_t) -> rawptr
dealloc_proc :: proc "c" (rawptr)

@(export)
odin_startup_runtime :: proc "c" (alloc: alloc_proc, dealloc: dealloc_proc) {
	context = default_context
	#force_no_inline runtime._startup_runtime()
}

@(init)
init :: proc() {
}
