#+private

package gamepad

import "core:c"

foreign {
	kernel_read_pad :: proc "c" (index: c.int) -> c.uint ---
}
