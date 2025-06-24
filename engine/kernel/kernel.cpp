#include "kernel.h"
#include <circle/timer.h>
#include <circle/string.h>
#include <circle/memory.h>
#include <fatfs/ff.h>

#define DRIVE "SD:"
#define LOGFILE "log.txt"

FIL log_file = {0};
bool running = true;

struct fb_definition {
	void *ptr;
	int width;
	int height;
	int pitch;
};

struct fb_definition framebuffer = {0};

extern "C" {
	void game_startup(void);
	void game_update(int64_t);
	void game_render(void);
	void game_shutdown(void);
}

extern "C" {
	void kernel_write_log(const char *str) {
		f_write(&log_file, str, CString(str).GetLength(), 0);
		f_sync(&log_file);
	}

	void kernel_halt() {
		running = false;
	}

	void *kernel_alloc(size_t size) {
		return CMemorySystem::HeapAllocate(size, HEAP_DEFAULT_NEW);	
	}

	void kernel_dealloc(void *ptr) {
		CMemorySystem::HeapFree(ptr);
	}

	void kernel_sleep_ms(int64_t ms) {
		CTimer::SimpleMsDelay(ms);
	}

	struct fb_definition *kernel_fb_definition(void) {
		return &framebuffer;
	}
}

CKernel::CKernel (void)
:	m_Timer(&m_Interrupt),
	m_USBHCI(&m_Interrupt, &m_Timer, TRUE),
	m_EMMC(&m_Interrupt, &m_Timer, 0)
{
	m_pFrameBuffer = new CBcmFrameBuffer(m_Options.GetWidth(), m_Options.GetHeight(), 32);
	if (!m_pFrameBuffer->Initialize()) {
		delete m_pFrameBuffer;
		m_pFrameBuffer = 0;
	}
}

CKernel::~CKernel (void)
{
	if (m_pFrameBuffer)
		delete m_pFrameBuffer;
}

boolean CKernel::Initialize (void)
{
	boolean bOK = TRUE;
	if (bOK)
		bOK = m_Interrupt.Initialize();

	if (bOK)
		bOK = m_USBHCI.Initialize();
		
	if (bOK)
		bOK = m_EMMC.Initialize();

	return bOK;
}

TShutdownMode CKernel::Run (void)
{
	u64 update_ticks;
	u64 render_ticks;
	FATFS emmc_fs;
	
	if (f_mount(&emmc_fs, DRIVE, 1) != FR_OK)
		goto shutdown;

	if (f_open(&log_file, LOGFILE, FA_WRITE|FA_CREATE_ALWAYS) != FR_OK)
		goto shutdown;

	kernel_write_log("Logging initialize!\n");

	if (!m_pFrameBuffer) {
		kernel_write_log("Could not initialize framebuffer!\n");
		goto shutdown;
	} else if (m_pFrameBuffer->GetDepth() != 32) {
		kernel_write_log("Invalid framebuffer format!\n");
		goto shutdown;
	} else {	
		framebuffer.ptr = (void*)(u64)m_pFrameBuffer->GetBuffer();
		framebuffer.pitch = m_pFrameBuffer->GetPitch();
		framebuffer.width = m_pFrameBuffer->GetWidth();
		framebuffer.height = m_pFrameBuffer->GetHeight();
	}

	update_ticks = render_ticks = CTimer::GetClockTicks64();

	game_startup();
	while (running)
	{
		u64 now = CTimer::GetClockTicks64();
		int64_t dt = (int64_t)(((double)(now - update_ticks) / (double)CLOCKHZ) * 1000000.0) * 1000;
		if (dt <= 0)
			continue;
		update_ticks = now;
		
		game_update(dt);
		
		// TODO: Lets move this to another CPU core at some point.
		if ((now - render_ticks) >= (CLOCKHZ / 60)) { 
			render_ticks = now;
			game_render();
		}
	}
	game_shutdown();

shutdown:

	f_close(&log_file);
	f_unmount(DRIVE);
	
	return ShutdownHalt;
}
