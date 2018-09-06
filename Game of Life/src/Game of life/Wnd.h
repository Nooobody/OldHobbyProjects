#ifndef WND_INCLD
#define WND_INCLD
#include <Windows.h>
#include <WindowsX.h>
#include <stdlib.h>
#include <malloc.h>
#include <memory.h>
#include <Shobjidl.h>
#include <vector>
#include <sstream>
#include <fstream>
#endif

#include "resource.h"

#ifndef D2D_INCLD
#define D2D_INCLD
#include <d2d1.h>
#include <d2d1helper.h>
#include <atlbase.h>
#endif

using namespace std;
using namespace D2D1;

#ifndef HINST_THISCOMPONENT
EXTERN_C IMAGE_DOS_HEADER __ImageBase;
#define HINST_THISCOMPONENT ((HINSTANCE)&__ImageBase)
#endif

UINT Clamp(UINT,UINT,UINT);

struct Task {
	UINT X;
	UINT Y;
	bool Alive;
};

class Wnd;

#include "Pixel.h"

class Wnd {
protected:
	HRESULT CreateIndRes();
	HRESULT CreateRes();

public:
	Wnd() {
		m_HWnd = 0;
		m_pMenu = 0;
		Active = 0;
		Exit = false;
		Limiter = 0;
		Oldie = ID_SPEED_100;
		MBDown = false;
		NeighP[0][0] = -6; NeighP[0][1] = 6;	// UpLeft
		NeighP[1][0] = -6; NeighP[1][1] = 0;	// Left
		NeighP[2][0] = -6; NeighP[2][1] = -6;	// DownLeft
		NeighP[3][0] = 0; NeighP[3][1] = 6;		// Up
		NeighP[4][0] = 0; NeighP[4][1] = -6;	// Down
		NeighP[5][0] = 6; NeighP[5][1] = 6;		// UpRight
		NeighP[6][0] = 6; NeighP[6][1] = 0;		// Right
		NeighP[7][0] = 6; NeighP[7][1] = -6;	// DownRight
	}
	~Wnd() {
		Exit = true;
	}
	UINT Width;
	UINT Height;
	UINT Limiter;
	UINT Oldie;
	HWND m_HWnd;
	CComPtr<ID2D1Factory> m_pDirect2dFactory;
	CComPtr<ID2D1HwndRenderTarget> m_pRT;
	CComPtr<ID2D1SolidColorBrush> m_pBrush;
	HMENU m_pMenu;

	bool MBDown;
	bool MBDown_Alive;
	bool Active;
	Pixel** Pixels;
	vector<Pixel*> AlivePixels;
	vector<Pixel*> SavedPixels;
	vector<Pixel*> Copy(vector<Pixel*>,bool);
	int NeighP[8][2];

	vector<Task> Queue;
	void Save();
	void Load();
	void AddQueue(UINT,UINT,bool);
	void ExecuteQueue();
	void Tick();
	void RunMsgLoop();
	void UpdateGrid();
	void UnSerialize(string);
	void Resize();
	void DiscRes();
	vector<Pixel*> RemPixels(vector<Pixel*>);
	void RemPixels();
	HRESULT Create();
	bool SetDot(UINT,UINT);
	bool Exit;
	static LRESULT CALLBACK WndProc(HWND,UINT,WPARAM,LPARAM);
};