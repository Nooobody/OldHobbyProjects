#pragma once
#include "Includes.h"
#include "Menu.h"
#include "Maze.h"

class Wnd {
public:
	HRESULT CreateIndRes();
	HRESULT CreateRes();
	void LoadPng(LPCWSTR,ID2D1Bitmap**);
	Wnd() {
		m_HWnd = 0;
		Exit = false;
		GenerateToggle = false;
		MazeMouseAction = false;
	}
	bool GenerateToggle;
	bool MazeMouseAction;
	unsigned short Width;
	unsigned short Height;
	UINT W;
	UINT H;
	HWND m_HWnd;
	CComPtr<ID2D1Factory> m_pDirect2dFactory;
	CComPtr<ID2D1HwndRenderTarget> m_pRT;
	CComPtr<ID2D1SolidColorBrush> m_pBrush;
	CComPtr<IWICImagingFactory> m_pWICFactory;
	CComPtr<IDWriteFactory> m_pWrite;
	CComPtr<IDWriteTextFormat> m_pSmallTextFormat;
	CComPtr<IDWriteTextFormat> m_pMediumTextFormat;
	CComPtr<IDWriteTextFormat> m_pLargeTextFormat;
	vector<KeyMapping> m_pKeyMap;
	vector<wstring> m_pKeysDown;
	Menu* MainMenu;
	Maze* pMaze;
	bool LBtnHold;
	bool RBtnHold;
	unsigned short MouseX;
	unsigned short MouseY;

	void DrawText(wstring,Vec2,Vec2,unsigned char);
	Vec2 GetTextSize(wstring,unsigned char);

	bool IsMouseInside(Vec2,Vec2);
	void RBtnDown();
	void RBtnUp();
	void LBtnDown();
	void LBtnUp();
	void SetColor(ColorF);
	void InitFunc();
	bool IsKeyDown(wstring);
	void KeyUp(wstring);
	void KeyDown(wstring);
	void RunMsgLoop();
	void Tick();
	HRESULT Create();
	bool bRestart;
	bool Exit;
	static LRESULT CALLBACK WndProc(HWND,UINT,WPARAM,LPARAM);
};