#+private

package assets

import "core:c"

foreign {
	kernel_load_asset :: proc "c" (cstring) -> rawptr ---
	kernel_load_asset_len :: proc "c" () -> c.int ---
}
