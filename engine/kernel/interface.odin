package kernel

import "core:time"
import "core:c"
import "base:runtime"

default_context: runtime.Context

DEFAULT_TEMP_ALLOCATOR_SIZE :: 1024 * 1024 * 64 // 64MB

sleep :: proc(d: time.Duration) {
	kernel_sleep_ms(c.int64_t(d) / 1000000)
}

halt :: proc() {
	kernel_halt()
}
