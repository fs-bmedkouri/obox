#ifndef _KERNEL_H_
#define _KERNEL_H_

#include <circle/koptions.h>
#include <circle/devicenameservice.h>
#include <circle/bcmframebuffer.h>
#include <circle/types.h>
#include <circle/usb/usbhcidevice.h>
#include <circle/usb/usbgamepad.h>
#include <circle/interrupt.h>
#include <SDCard/emmc.h>

#define MAX_GAMEPADS 2
#define DRIVE "SD:"
#define LOGFILE "log.txt"

enum TShutdownMode
{
	ShutdownNone,
	ShutdownHalt,
	ShutdownReboot
};

class CKernel
{
public:
	CKernel (void);
	~CKernel (void);

	boolean Initialize (void);

	TShutdownMode Run (void);

	static CBcmFrameBuffer *s_pFrameBuffer;

private:
	static void GamePadStatusHandler (unsigned nDeviceIndex, const TGamePadState *pState);
	static void GamePadRemovedHandler (CDevice *pDevice, void *pContext);

	CKernelOptions		m_Options;
	CDeviceNameService	m_DeviceNameService;
	CInterruptSystem	m_Interrupt;
	CTimer				m_Timer;
	CUSBHCIDevice		m_USBHCI;
	CEMMCDevice			m_EMMC;

	CUSBGamePadDevice *volatile m_pGamePad[MAX_GAMEPADS];
};

#endif
