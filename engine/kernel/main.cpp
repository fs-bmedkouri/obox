#include "kernel.h"
#include <circle/startup.h>
#include <circle/memory.h>

#define ODIN_HEAP_SIZE (1024 * 1024 * 32)
extern "C" {
	void odin_startup_runtime(void *(*f_alloc)(size_t), void (*f_free)(void*));

	void *heap_alloc(size_t size) {
		return CMemorySystem::HeapAllocate(size, HEAP_DEFAULT_NEW);	
	}

	void heap_free(void *ptr) {
		CMemorySystem::HeapFree(ptr);
	}
}

int main(void) {
	odin_startup_runtime(&heap_alloc, &heap_free);

	CKernel Kernel;
	if (!Kernel.Initialize()) {
		halt();
		return EXIT_HALT;
	}
	
	TShutdownMode ShutdownMode = Kernel.Run();
	switch (ShutdownMode) {
		case ShutdownReboot:
			reboot();
			return EXIT_REBOOT;
		case ShutdownHalt:
		default:
			halt();
			return EXIT_HALT;
	}
}
