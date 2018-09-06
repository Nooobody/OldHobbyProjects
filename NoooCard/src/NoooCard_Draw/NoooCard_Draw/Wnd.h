#pragma comment(linker,"/manifestdependency:\"type='win32' name='Microsoft.Windows.Common-Controls' "\
	"version='6.0.0.0' processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")

#ifndef WND_INCLD
#define WND_INCLD
#include <Windows.h>
#include <WindowsX.h>
#include <CommCtrl.h>
#include <stdlib.h>
#include <malloc.h>
#include <memory.h>
#include <vector>
#include <time.h>
#include <math.h>
#include <cmath>
#include <random>
#include <sstream>
#include <fstream>
#include <Shobjidl.h>
#endif

#ifndef D2D_INCLD
#define D2D_INCLD
#include <d2d1.h>
#include <d2d1helper.h>
#include <atlbase.h>
#include <wincodec.h>
#endif

#include "resource.h"

#define PI 3.14159265

using namespace std;
using namespace D2D1;

#ifndef HINST_THISCOMPONENT
EXTERN_C IMAGE_DOS_HEADER __ImageBase;
#define HINST_THISCOMPONENT ((HINSTANCE)&__ImageBase)
#endif

class Wnd;

UINT Clamp(UINT,UINT,UINT);
#include "Pixel.h"
#include "Spawner.h"

class Wnd {
protected:
	HRESULT CreateIndRes();
	HRESULT CreateRes();

public:
	Wnd() {
		m_HWnd = 0;
		Exit = false;
		Toggled = false;
		StartTime = 0;
		Int = 90;
		Oldie_Col = ID_COLOR_WHITE;
		Oldie_Spd = ID_RAINBOWSPEED_1X;
		Oldie_Stl = ID_STYLE_NORMAL;
		Rainbow = false;
		RbSpeed = 1;
		State = 0;
		Style = 0;
		Amnt = 10;
		UColor = Color(255,255,255);
	}
	~Wnd() {
		Exit = true;
	}
	float RbSpeed;
	UINT MouseX;
	UINT MouseY;
	UINT StartX;
	UINT StartY;
	UINT Int;
	UINT StartTime;
	UINT Width;
	UINT Height;
	UINT Oldie_Col;
	UINT Oldie_Spd;
	UINT Oldie_Stl;
	UINT Style;
	UINT State;
	UINT Amnt;
	HWND m_HWnd;
	HWND m_ToolBar;
	HMENU m_pMenu;
	CComPtr<ID2D1Factory> m_pDirect2dFactory;
	CComPtr<ID2D1HwndRenderTarget> m_pRT;
	CComPtr<ID2D1SolidColorBrush> m_pBrush;
	vector<Pixel*> Pixels;
	vector<Spawner*> Spawners;

	void SaveScreenshot();
	void CheckItem(UINT,UINT);
	void Reset();
	void Save();
	void DoSparkles(UINT X,UINT Y);
	void RunMsgLoop();
	void Tick();
	HRESULT Create();
	Color UColor;
	bool Rainbow;
	bool Toggled;
	bool Exit;
	static LRESULT CALLBACK WndProc(HWND,UINT,WPARAM,LPARAM);
};