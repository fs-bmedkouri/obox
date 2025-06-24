#ifndef _KERNEL_H_
#define _KERNEL_H_

#include <circle/actled.h>
#include <circle/koptions.h>
#include <circle/devicenameservice.h>
#include <circle/screen.h>
#include <circle/types.h>
#include <circle/usb/usbhcidevice.h>
#include <circle/interrupt.h>
#include <SDCard/emmc.h>

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

private:
	CKernelOptions		m_Options;
	CDeviceNameService	m_DeviceNameService;
	CInterruptSystem	m_Interrupt;
	CTimer				m_Timer;
	CUSBHCIDevice		m_USBHCI;
	CEMMCDevice			m_EMMC;

	CBcmFrameBuffer 	*m_pFrameBuffer;
};

#endif
