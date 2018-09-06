#include "Wnd.h"

LRESULT CALLBACK Wnd::WndProc(HWND HWnd,UINT Msg,WPARAM WParam,LPARAM LParam) {
	LRESULT Res = 0;

	if (Msg == WM_CREATE) {
		LPCREATESTRUCT Pcs = (LPCREATESTRUCT)LParam;
		Wnd *pWnd = (Wnd*)Pcs->lpCreateParams;

		SetWindowLongPtrW(HWnd,GWLP_USERDATA,PtrToUlong(pWnd));
		Res = 0;
	}
	else {
		Wnd *pWnd = reinterpret_cast<Wnd *>(static_cast<LONG_PTR>(GetWindowLongPtrW(HWnd,GWLP_USERDATA)));
		bool WasHndled = false;

		if (pWnd) {
			switch (Msg) {
				case WM_DISPLAYCHANGE:
					{
						InvalidateRect(HWnd,0,FALSE);
					}
					Res = 0;
					WasHndled = true;
					break;
				case WM_DESTROY:
					{
						PostQuitMessage(0);
						DestroyWindow(HWnd);
						pWnd->Exit = true;
					}
					Res = 1;
					WasHndled = true;
					break;
				case WM_MOUSEMOVE:
					pWnd->MouseX = GET_X_LPARAM(LParam);
					pWnd->MouseY = GET_Y_LPARAM(LParam);
					Res = 0;
					WasHndled = true;
					break;
				case WM_LBUTTONDOWN:
					pWnd->LBtnHold = true;
					pWnd->LBtnDown();
					Res = 0;
					WasHndled = true;
					break;
				case WM_LBUTTONUP:
					pWnd->LBtnHold = false;
					pWnd->LBtnUp();
					Res = 0;
					WasHndled = true;
					break;
				case WM_RBUTTONDOWN:
					pWnd->RBtnHold = true;
					pWnd->RBtnDown();
					Res = 0;
					WasHndled = true;
					break;
				case WM_RBUTTONUP:
					pWnd->RBtnHold = false;
					pWnd->RBtnUp();
					Res = 0;
					WasHndled = true;
					break;
				case WM_KEYUP:
					for (UINT I = 0;I < pWnd->m_pKeyMap.size();I++) {
						if (WParam == pWnd->m_pKeyMap[I].Code) {
							pWnd->KeyUp(pWnd->m_pKeyMap[I].Key);
							break;
						}
					}
					Res = 0;
					WasHndled = true;
					break;
				case WM_KEYDOWN:
					for (UINT I = 0;I < pWnd->m_pKeyMap.size();I++) {
						if (WParam == pWnd->m_pKeyMap[I].Code) {
							pWnd->KeyDown(pWnd->m_pKeyMap[I].Key);
							break;
						}
					}
					Res = 0;
					WasHndled = true;
					break;
			}
			if (WasHndled) {
				Res = 0;
			}
		}

		if (!WasHndled) {
			Res = DefWindowProc(HWnd,Msg,WParam,LParam);
		}
	}

	return Res;
};

void Wnd::RunMsgLoop() {
	CreateRes();
	InitFunc();
	MSG Msg;
	memset(&Msg,0,28);
	while (!Exit) {
		while (PeekMessage(&Msg,0,0,0,PM_REMOVE)) {
			TranslateMessage(&Msg);
			DispatchMessage(&Msg);
		}
		Tick();
		Sleep(10);
	}
	m_pWICFactory.Release();
};

HRESULT Wnd::Create() {
	HRESULT Hr = S_OK;

	Hr = CreateIndRes();

	if (SUCCEEDED(Hr)) {
		WNDCLASSEX WndEx = {sizeof(WNDCLASSEX)};
		WndEx.style         = CS_HREDRAW | CS_VREDRAW;
		WndEx.lpfnWndProc   = Wnd::WndProc;
		WndEx.cbClsExtra    = 0;
		WndEx.cbWndExtra    = sizeof(LONG_PTR);
		WndEx.hInstance     = HINST_THISCOMPONENT;
		WndEx.hbrBackground = (HBRUSH)GetStockObject(BLACK_BRUSH);
		WndEx.lpszMenuName  = 0;
		WndEx.hCursor       = LoadCursor(0, IDI_APPLICATION);
		WndEx.lpszClassName = L"MyWndClass";
		WndEx.hIcon			= LoadIcon(WndEx.hInstance,IDI_APPLICATION);
		WndEx.hIconSm		= LoadIcon(WndEx.hInstance,IDI_APPLICATION);
		
		RegisterClassEx(&WndEx);

		m_HWnd = CreateWindowEx(0,
			L"MyWndClass",
			L"My Wnd",
			WS_OVERLAPPEDWINDOW,
			20,
			20,
			860,
			640,
			0,
			0,
			HINST_THISCOMPONENT,
			this
			);
		Hr = m_HWnd ? S_OK : E_FAIL;
		if (SUCCEEDED(Hr)) {
			ShowWindow(m_HWnd,SW_SHOWNORMAL);
			UpdateWindow(m_HWnd);
		}
	}

	m_pKeyMap.push_back(KeyMapping(8,L"BP"));
	m_pKeyMap.push_back(KeyMapping(9,L"TAB"));
	m_pKeyMap.push_back(KeyMapping(13,L"ENT"));
	m_pKeyMap.push_back(KeyMapping(27,L"ESC"));
	m_pKeyMap.push_back(KeyMapping(16,L"SHIFT"));
	m_pKeyMap.push_back(KeyMapping(17,L"CTRL"));
	m_pKeyMap.push_back(KeyMapping(18,L"ALT"));
	m_pKeyMap.push_back(KeyMapping(32,L" "));
	m_pKeyMap.push_back(KeyMapping(37,L"LEFT"));
	m_pKeyMap.push_back(KeyMapping(38,L"UP"));
	m_pKeyMap.push_back(KeyMapping(39,L"RIGHT"));
	m_pKeyMap.push_back(KeyMapping(40,L"DOWN"));
	m_pKeyMap.push_back(KeyMapping(48,L"0"));
	m_pKeyMap.push_back(KeyMapping(49,L"1"));
	m_pKeyMap.push_back(KeyMapping(50,L"2"));
	m_pKeyMap.push_back(KeyMapping(51,L"3"));
	m_pKeyMap.push_back(KeyMapping(52,L"4"));
	m_pKeyMap.push_back(KeyMapping(53,L"5"));
	m_pKeyMap.push_back(KeyMapping(54,L"6"));
	m_pKeyMap.push_back(KeyMapping(55,L"7"));
	m_pKeyMap.push_back(KeyMapping(56,L"8"));
	m_pKeyMap.push_back(KeyMapping(57,L"9"));
	m_pKeyMap.push_back(KeyMapping(65,L"a"));
	m_pKeyMap.push_back(KeyMapping(66,L"b"));
	m_pKeyMap.push_back(KeyMapping(67,L"c"));
	m_pKeyMap.push_back(KeyMapping(68,L"d"));
	m_pKeyMap.push_back(KeyMapping(69,L"e"));
	m_pKeyMap.push_back(KeyMapping(70,L"f"));
	m_pKeyMap.push_back(KeyMapping(71,L"g"));
	m_pKeyMap.push_back(KeyMapping(72,L"h"));
	m_pKeyMap.push_back(KeyMapping(73,L"i"));
	m_pKeyMap.push_back(KeyMapping(74,L"j"));
	m_pKeyMap.push_back(KeyMapping(75,L"k"));
	m_pKeyMap.push_back(KeyMapping(76,L"l"));
	m_pKeyMap.push_back(KeyMapping(77,L"m"));
	m_pKeyMap.push_back(KeyMapping(78,L"n"));
	m_pKeyMap.push_back(KeyMapping(79,L"o"));
	m_pKeyMap.push_back(KeyMapping(80,L"p"));
	m_pKeyMap.push_back(KeyMapping(81,L"q"));
	m_pKeyMap.push_back(KeyMapping(82,L"r"));
	m_pKeyMap.push_back(KeyMapping(83,L"s"));
	m_pKeyMap.push_back(KeyMapping(84,L"t"));
	m_pKeyMap.push_back(KeyMapping(85,L"u"));
	m_pKeyMap.push_back(KeyMapping(86,L"v"));
	m_pKeyMap.push_back(KeyMapping(87,L"w"));
	m_pKeyMap.push_back(KeyMapping(88,L"x"));
	m_pKeyMap.push_back(KeyMapping(89,L"y"));
	return Hr;
}

void Wnd::KeyDown(wstring Key) {
	for (UINT I = 0;I < m_pKeysDown.size();I++) {
		if (m_pKeysDown[I].compare(Key) == 0) {
			return;
		}
	}
	m_pKeysDown.push_back(Key);
}

void Wnd::KeyUp(wstring Key) {
	if (m_pKeysDown.size() == 0) return;
	unsigned char Int = 0;
	for (unsigned char I = 0;I < m_pKeysDown.size();I++) {
		if (m_pKeysDown[Int].compare(Key) == 0) {
			Int = I;
			break;
		}
	}
	m_pKeysDown.erase(m_pKeysDown.begin() + Int);
	if (Key.compare(L"1") == 0 || Key.compare(L"2") == 0 || Key.compare(L"3") == 0 || Key.compare(L"4") == 0 || Key.compare(L"5") == 0) {
		if (Key.compare(L"1") == 0) {
			(*MainMenu->pBtns[0]->Func)();
		}
		else if (Key.compare(L"2") == 0) {
			(*MainMenu->pBtns[2]->Func)();
			MazeMouseAction = false;
			pMaze->Solve(pMaze->Points[pMaze->Points.size() - (1 + rand() % 10)]->Pos);
		}
		else if (Key.compare(L"3") == 0) {
			(*MainMenu->pBtns[1]->Func)();
		}
		else if (Key.compare(L"4") == 0) {
			(*MainMenu->pBtns[3]->Func)();
		}
		else if (Key.compare(L"5") == 0) {
			(*MainMenu->pBtns[4]->Func)();
		}
	}
}

bool Wnd::IsKeyDown(wstring Key) {
	for (unsigned char I = 0;I < m_pKeysDown.size();I++) {
		if (m_pKeysDown[I].compare(Key) == 0) {
			return true;
		}
	}
	return false;
}