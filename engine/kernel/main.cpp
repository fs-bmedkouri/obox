#include "kernel.h"
#include <circle/startup.h>
#include <circle/memory.h>

extern "C" {
	void write_log(const char *str);
	void odin_startup_runtime(void *(*f_alloc)(size_t), void (*f_free)(void*), void (*f_log)(const char*));

	void *heap_alloc(size_t size) {
		return CMemorySystem::HeapAllocate(size, HEAP_DEFAULT_NEW);	
	}

	void heap_free(void *ptr) {
		CMemorySystem::HeapFree(ptr);
	}
}

int main(void) {
	CKernel Kernel;
	if (!Kernel.Initialize()) {
		halt();
		return EXIT_HALT;
	}

	odin_startup_runtime(&heap_alloc, &heap_free, &write_log);
	
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
