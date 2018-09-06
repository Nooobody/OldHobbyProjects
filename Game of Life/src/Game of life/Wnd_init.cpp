#include "Wnd.h"

LRESULT CALLBACK Wnd::WndProc(HWND HWnd,UINT Msg,WPARAM WParam,LPARAM LParam) {
	LRESULT Res = 0;

	if (Msg == WM_CREATE) {
		LPCREATESTRUCT Pcs = (LPCREATESTRUCT)LParam;
		Wnd *pWnd = (Wnd*)Pcs->lpCreateParams;

		SetWindowLongPtrW(HWnd,GWLP_USERDATA,PtrToUlong(pWnd));
		pWnd->m_pMenu = GetMenu(HWnd);
		Res = 1;
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
						pWnd->Exit = true;
					}
					Res = 1;
					WasHndled = true;
					break;
				case WM_LBUTTONDOWN:
					if (!pWnd->Active) {
						pWnd->CreateRes();
						pWnd->MBDown_Alive = pWnd->SetDot(Clamp(GET_X_LPARAM(LParam),6,pWnd->Width - 6),
														  Clamp(GET_Y_LPARAM(LParam),6,pWnd->Height - 6));
						pWnd->MBDown = true;
					}
					Res = 0;
					WasHndled = true;
					break;
				case WM_LBUTTONUP:
					pWnd->MBDown = false;
					Res = 0;
					WasHndled = true;
					break;
				case WM_MOUSEMOVE:
					if (pWnd->MBDown) {
						UINT X = GET_X_LPARAM(LParam);
						UINT Y = GET_Y_LPARAM(LParam);
						UINT I = (pWnd->Width /6) * (Y / 6) + (X / 6);
						if ((pWnd->Pixels[I] == 0 && pWnd->MBDown_Alive) || (pWnd->Pixels[I] != 0 && !pWnd->MBDown_Alive)) {
							pWnd->SetDot(X,Y);
						}
					}
					Res = 0;
					WasHndled = true;
					break;
				case WM_SIZE:
					pWnd->Resize();
					Res = 0;
					WasHndled = true;
					break;
				case WM_COMMAND:
					switch (LOWORD(WParam)) {
						case ID_ACTION_START:
							if (pWnd->AlivePixels.size() > 0) {
								pWnd->Active = true;
								pWnd->SavedPixels = pWnd->Copy(pWnd->AlivePixels,false);
								EnableMenuItem(pWnd->m_pMenu,ID_ACTION_PAUSE,MF_ENABLED);
								EnableMenuItem(pWnd->m_pMenu,ID_ACTION_STOP,MF_ENABLED);
								EnableMenuItem(pWnd->m_pMenu,ID_ACTION_START,MF_GRAYED);
							}
							break;
						case ID_ACTION_RESUME:
							if (pWnd->AlivePixels.size() > 0) {
								pWnd->Active = true;
								EnableMenuItem(pWnd->m_pMenu,ID_ACTION_RESUME,MF_GRAYED);
								EnableMenuItem(pWnd->m_pMenu,ID_ACTION_PAUSE,MF_ENABLED);
							}
							break;
						case ID_ACTION_PAUSE:
							pWnd->Active = false;
							EnableMenuItem(pWnd->m_pMenu,ID_ACTION_RESUME,MF_ENABLED);
							EnableMenuItem(pWnd->m_pMenu,ID_ACTION_PAUSE,MF_GRAYED);
							break;
						case ID_ACTION_STOP:
							pWnd->Active = false;
							pWnd->AlivePixels = pWnd->RemPixels(pWnd->AlivePixels);
							pWnd->AlivePixels = pWnd->Copy(pWnd->SavedPixels,true);
							pWnd->UpdateGrid();
							EnableMenuItem(pWnd->m_pMenu,ID_ACTION_PAUSE,MF_GRAYED);
							EnableMenuItem(pWnd->m_pMenu,ID_ACTION_RESUME,MF_GRAYED);
							EnableMenuItem(pWnd->m_pMenu,ID_ACTION_STOP,MF_GRAYED);
							EnableMenuItem(pWnd->m_pMenu,ID_ACTION_START,MF_ENABLED);
							break;
						case ID_ACTION_EXIT:
							PostQuitMessage(0);
							DestroyWindow(HWnd);
							pWnd->Exit = true;
							break;
						case ID_SPEED_10:
							pWnd->Limiter = 360;
							CheckMenuItem(pWnd->m_pMenu,pWnd->Oldie,MF_UNCHECKED);
							CheckMenuItem(pWnd->m_pMenu,ID_SPEED_10,MF_CHECKED);
							pWnd->Oldie = ID_SPEED_10;
							break;
						case ID_SPEED_20:
							pWnd->Limiter = 320;
							CheckMenuItem(pWnd->m_pMenu,pWnd->Oldie,MF_UNCHECKED);
							CheckMenuItem(pWnd->m_pMenu,ID_SPEED_20,MF_CHECKED);
							pWnd->Oldie = ID_SPEED_20;
							break;
						case ID_SPEED_30:
							pWnd->Limiter = 280;
							CheckMenuItem(pWnd->m_pMenu,pWnd->Oldie,MF_UNCHECKED);
							CheckMenuItem(pWnd->m_pMenu,ID_SPEED_30,MF_CHECKED);
							pWnd->Oldie = ID_SPEED_30;
							break;
						case ID_SPEED_40:
							pWnd->Limiter = 240;
							CheckMenuItem(pWnd->m_pMenu,pWnd->Oldie,MF_UNCHECKED);
							CheckMenuItem(pWnd->m_pMenu,ID_SPEED_40,MF_CHECKED);
							pWnd->Oldie = ID_SPEED_40;
							break;
						case ID_SPEED_50:
							pWnd->Limiter = 200;
							CheckMenuItem(pWnd->m_pMenu,pWnd->Oldie,MF_UNCHECKED);
							CheckMenuItem(pWnd->m_pMenu,ID_SPEED_50,MF_CHECKED);
							pWnd->Oldie = ID_SPEED_50;
							break;
						case ID_SPEED_60:
							pWnd->Limiter = 160;
							CheckMenuItem(pWnd->m_pMenu,pWnd->Oldie,MF_UNCHECKED);
							CheckMenuItem(pWnd->m_pMenu,ID_SPEED_60,MF_CHECKED);
							pWnd->Oldie = ID_SPEED_60;
							break;
						case ID_SPEED_70:
							pWnd->Limiter = 120;
							CheckMenuItem(pWnd->m_pMenu,pWnd->Oldie,MF_UNCHECKED);
							CheckMenuItem(pWnd->m_pMenu,ID_SPEED_70,MF_CHECKED);
							pWnd->Oldie = ID_SPEED_70;
							break;
						case ID_SPEED_80:
							pWnd->Limiter = 80;
							CheckMenuItem(pWnd->m_pMenu,pWnd->Oldie,MF_UNCHECKED);
							CheckMenuItem(pWnd->m_pMenu,ID_SPEED_80,MF_CHECKED);
							pWnd->Oldie = ID_SPEED_80;
							break;
						case ID_SPEED_90:
							pWnd->Limiter = 40;
							CheckMenuItem(pWnd->m_pMenu,pWnd->Oldie,MF_UNCHECKED);
							CheckMenuItem(pWnd->m_pMenu,ID_SPEED_90,MF_CHECKED);
							pWnd->Oldie = ID_SPEED_90;
							break;
						case ID_SPEED_100:
							pWnd->Limiter = 0;
							CheckMenuItem(pWnd->m_pMenu,pWnd->Oldie,MF_UNCHECKED);
							CheckMenuItem(pWnd->m_pMenu,ID_SPEED_100,MF_CHECKED);
							pWnd->Oldie = ID_SPEED_100;
							break;
						case ID_SAVE:
							pWnd->Save();
							break;
						case ID_LOAD:
							pWnd->Active = false;
							pWnd->CreateRes();
							pWnd->Load();
							break;
						case ID_ACTION_NEW:
							pWnd->Active = false;
							if (pWnd->AlivePixels.size() > 0) {
								pWnd->AlivePixels = pWnd->RemPixels(pWnd->AlivePixels);
								pWnd->SavedPixels.clear();
								pWnd->UpdateGrid();
							}
							EnableMenuItem(pWnd->m_pMenu,ID_ACTION_PAUSE,MF_GRAYED);
							EnableMenuItem(pWnd->m_pMenu,ID_ACTION_RESUME,MF_GRAYED);
							EnableMenuItem(pWnd->m_pMenu,ID_ACTION_STOP,MF_GRAYED);
							EnableMenuItem(pWnd->m_pMenu,ID_ACTION_START,MF_ENABLED);
							break;
						case ID_CREDITS:
							MessageBox(HWnd,L"This program was created by Nooobody, you may distribute it at will. :)",L"Credits",MB_OK);
							break;
					}
			}
			if (WasHndled) {
				Res = 1;
			}
		}

		if (!WasHndled) {
			Res = DefWindowProc(HWnd,Msg,WParam,LParam);
		}
	}

	return Res;
};

void Wnd::RunMsgLoop() {
	MSG Msg;
	memset(&Msg,0,28);
	while (!Exit) {
		while (PeekMessage(&Msg,0,0,0,PM_REMOVE)) {
			TranslateMessage(&Msg);
			DispatchMessage(&Msg);
		}
		if (Active) {
			Sleep(Limiter);
			Tick();
		}
		else {
			Sleep(50);
		}
	}
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
		WndEx.lpszMenuName  = MAKEINTRESOURCE(IDR_MENU);
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
	return Hr;
}