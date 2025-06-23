#include "kernel.h"
#include <circle/timer.h>
#include <circle/string.h>
#include <fatfs/ff.h>

#define DRIVE "SD:"
#define LOGFILE "log.txt"

FIL log_file = {0};

extern "C" {
	void game_update(double);
	void game_render(void);

	void write_log(const char *str) {
		f_write(&log_file, str, CString(str).GetLength(), 0);
		f_sync(&log_file);
	}
}

CKernel::CKernel (void)
:	m_Screen (m_Options.GetWidth (), m_Options.GetHeight ()),
	m_Timer(&m_Interrupt),
	m_USBHCI(&m_Interrupt, &m_Timer, TRUE),
	m_EMMC(&m_Interrupt, &m_Timer, 0)
{
}

CKernel::~CKernel (void)
{
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

	if (bOK)
		bOK = m_Screen.Initialize();

	return bOK;
}

TShutdownMode CKernel::Run (void)
{
	FATFS emmc_fs;
	if (f_mount(&emmc_fs, DRIVE, 1) != FR_OK)
		return ShutdownHalt;

	if (f_open(&log_file, LOGFILE, FA_WRITE|FA_CREATE_ALWAYS) != FR_OK)
		return ShutdownHalt;

	write_log("Enter main loop!\n");

	// draw rectangle on screen
	for (unsigned nPosX = 0; nPosX < m_Screen.GetWidth (); nPosX++)
	{
		m_Screen.SetPixel (nPosX, 0, NORMAL_COLOR);
		m_Screen.SetPixel (nPosX, m_Screen.GetHeight ()-1, NORMAL_COLOR);
	}
	for (unsigned nPosY = 0; nPosY < m_Screen.GetHeight (); nPosY++)
	{
		m_Screen.SetPixel (0, nPosY, NORMAL_COLOR);
		m_Screen.SetPixel (m_Screen.GetWidth ()-1, nPosY, NORMAL_COLOR);
	}

	// draw cross on screen
	for (unsigned nPosX = 0; nPosX < m_Screen.GetWidth (); nPosX++)
	{
		unsigned nPosY = nPosX * m_Screen.GetHeight () / m_Screen.GetWidth ();

		m_Screen.SetPixel (nPosX, nPosY, NORMAL_COLOR);
		m_Screen.SetPixel (m_Screen.GetWidth ()-nPosX-1, nPosY, NORMAL_COLOR);
	}

	while (1)
	{
		game_update(0.0);
		game_render();
	}

	f_close(&log_file);
	f_unmount(DRIVE);

	return ShutdownHalt;
}
