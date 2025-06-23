#+private

package kernel

import "base:runtime"
import "core:c"
import "core:mem"
import "core:log"
import "core:slice"
import "core:strings"

default_temp_allocator: mem.Arena
log_buffer: [dynamic]byte

alloc_proc_t :: #type proc "c" (c.size_t) -> rawptr
dealloc_proc_t :: #type proc "c" (rawptr)

alloc_proc: alloc_proc_t
dealloc_proc: dealloc_proc_t

LOG_BUFFER_SIZE :: 1024
log_proc_t :: #type proc "c" (cstring)

@(export)
odin_startup_runtime :: proc "c" (alloc: alloc_proc_t, dealloc: dealloc_proc_t, log_proc: log_proc_t) {
	context = default_context

	alloc_proc = alloc
	dealloc_proc = dealloc
	
	context.allocator.procedure = proc(
		allocator_data: rawptr,
		mode: runtime.Allocator_Mode,
		size, alignment: int,
		old_memory: rawptr,
		old_size: int,
		location: runtime.Source_Code_Location = #caller_location,
	) -> (
		[]byte,
		runtime.Allocator_Error,
	) {
		if mode == .Free {
			dealloc_proc(old_memory)
			return nil, .None
		}
		ptr := alloc_proc(c.size_t(size))
		if ptr == nil {
			panic("Out of memory!")
		}
		return slice.bytes_from_ptr(ptr, size), .None
	}

	mem.arena_init(&default_temp_allocator, make([]byte, DEFAULT_TEMP_ALLOCATOR_SIZE))
	context.temp_allocator = mem.arena_allocator(&default_temp_allocator)
	context.temp_allocator.procedure = proc(
		allocator_data: rawptr,
		mode: runtime.Allocator_Mode,
		size, alignment: int,
		old_memory: rawptr,
		old_size: int,
		location: runtime.Source_Code_Location = #caller_location,
	) -> (
		[]byte,
		runtime.Allocator_Error,
	) {
		ptr, err := mem.arena_allocator_proc(allocator_data, mode, size, alignment, old_memory, old_size, location)
		if err == .Out_Of_Memory {
			panic("Temp allocator out of memory!")
		}
		return ptr, err
	}
	
	context.random_generator = runtime.Random_Generator {
		procedure = random_generator_proc,
	}
	
	context.assertion_failure_proc = proc(prefix, message: string, loc: runtime.Source_Code_Location) -> ! {
		log.panicf("%v %s: %s", loc, prefix, message)
	}

	log_buffer = make([dynamic]byte, LOG_BUFFER_SIZE, LOG_BUFFER_SIZE)
	context.logger = runtime.Logger{logger_proc, rawptr(log_proc), .Debug, nil}

	default_context = context
	#force_no_inline runtime._startup_runtime()
}

random_generator_proc :: proc(data: rawptr, mode: runtime.Random_Generator_Mode, p: []byte) {
	@(static) seed: int = 1
	M :: 2147483647

	#partial switch mode {
	case .Read:
		for &v in p {
			seed = (16807 * seed) % M
			r := f64(seed) / M
			v = byte(255 * r)
		}
	case .Query_Info:
		if len(p) != size_of(runtime.Random_Generator_Query_Info) {
			return
		}
		(^runtime.Random_Generator_Query_Info)(raw_data(p))^ = {}
	}
}

logger_proc :: proc(data: rawptr, level: runtime.Logger_Level, text: string, options: runtime.Logger_Options, location := #caller_location) {
	builder := strings.builder_from_bytes(log_buffer[:])

	switch level {
	case .Debug:
		strings.write_string(&builder, "[DEBUG] ")
	case .Info:
		strings.write_string(&builder, "[INFO] ")
	case .Warning:
		strings.write_string(&builder, "[WARNING] ")
	case .Error:
		strings.write_string(&builder, "[ERROR] ")
	case .Fatal:
		strings.write_string(&builder, "[FATAL] ")
	}
	
	strings.write_string(&builder, text)
	strings.write_byte(&builder, '\n')
	
	cstr, err := strings.to_cstring(&builder)
	assert(err == nil)
	
	log_proc_t(data)(cstr)
}
