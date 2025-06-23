#include "kernel.h"
#include <circle/timer.h>

CKernel::CKernel (void)
:	m_Screen (m_Options.GetWidth (), m_Options.GetHeight ())
{
}

CKernel::~CKernel (void)
{
}

boolean CKernel::Initialize (void)
{
	return m_Screen.Initialize ();
}

TShutdownMode CKernel::Run (void)
{
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
		m_ActLED.On ();
		CTimer::SimpleMsDelay (100);

		m_ActLED.Off ();
		CTimer::SimpleMsDelay (100);
	}

	return ShutdownHalt;
}
