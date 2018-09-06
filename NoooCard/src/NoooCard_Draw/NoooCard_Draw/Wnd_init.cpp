#include "Wnd.h"

void Wnd::CheckItem(UINT New,UINT Old) {
	CheckMenuItem(m_pMenu,Old,MF_UNCHECKED);
	CheckMenuItem(m_pMenu,New,MF_CHECKED);
}

INT_PTR CALLBACK DlgProc(HWND HWnd,UINT Msg,WPARAM WParam,LPARAM LParam) {
	switch (Msg) {
		case WM_NOTIFY:
			{
				LPNMHDR Nmh = (LPNMHDR) LParam;
				if (Nmh->idFrom == IDC_SYSLINK1) {
					if (Nmh->code == NM_CLICK || Nmh->code == NM_RETURN) {
						PNMLINK Link = (PNMLINK) LParam;
						ShellExecute(0,L"open",Link->item.szUrl,0,0,SW_SHOWNORMAL);
					}
				}
			}
			break;
		case WM_COMMAND:
			switch (LOWORD(WParam)) {
				case IDOK:
					EndDialog(HWnd,WParam);
					return 1;
					break;
			}
	}
	return 0;
}

LRESULT CALLBACK Wnd::WndProc(HWND HWnd,UINT Msg,WPARAM WParam,LPARAM LParam) {
	LRESULT Res = 0;

	if (Msg == WM_CREATE) {
		LPCREATESTRUCT Pcs = (LPCREATESTRUCT)LParam;
		Wnd *pWnd = (Wnd*)Pcs->lpCreateParams;

		SetWindowLongPtrW(HWnd,GWLP_USERDATA,PtrToUlong(pWnd));
		pWnd->m_pMenu = GetMenu(HWnd);
		srand(clock());
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
						DestroyWindow(HWnd);
						pWnd->Exit = true;
					}
					Res = 1;
					WasHndled = true;
					break;
				case WM_MOUSEWHEEL:
					{ 
						int Delta = GET_WHEEL_DELTA_WPARAM(WParam);
						if (Delta > 0) {
							pWnd->Amnt = Clamp(--pWnd->Amnt,4,20);
						}
						else {
							pWnd->Amnt = Clamp(++pWnd->Amnt,4,20);
						}
					}
					Res = 1;
					WasHndled = true;
					break;
				case WM_MOUSEMOVE:
					pWnd->MouseX = GET_X_LPARAM(LParam);
					pWnd->MouseY = GET_Y_LPARAM(LParam);
					if (pWnd->Style == 0) {
						if (pWnd->Toggled) {
							Spawner* pSpawn;
							if (pWnd->Rainbow) {
								pSpawn = new Spawner(pWnd->MouseX,pWnd->MouseY,pWnd->Spawners.size() + 10,pWnd->RbSpeed,pWnd);
							}
							else {
								pSpawn = new Spawner(pWnd->MouseX,pWnd->MouseY,pWnd->UColor,pWnd);
							}
							pWnd->Spawners.push_back(pSpawn);
						}
					}
					Res = 1;
					WasHndled = true;
					break;
				case WM_LBUTTONDOWN:
					if (pWnd->Style == 0) {
						Spawner* pSpawn;
						if (pWnd->Rainbow) {
							pSpawn = new Spawner(pWnd->MouseX,pWnd->MouseY,pWnd->Spawners.size() + 10,pWnd->RbSpeed,pWnd);
						}
						else {
							pSpawn = new Spawner(pWnd->MouseX,pWnd->MouseY,pWnd->UColor,pWnd);
						}
						pWnd->Spawners.push_back(pSpawn);
						pWnd->Toggled = true;
					}
					else if (pWnd->Style == 1) {
						if (pWnd->State == 0) {
							pWnd->StartX = pWnd->MouseX;
							pWnd->StartY = pWnd->MouseY;
							pWnd->State++;
						}
						else if (pWnd->State == 1) {
							float Len = sqrt(pow(abs(int(pWnd->MouseX - pWnd->StartX)),2.0) + pow(abs(int(pWnd->MouseY - pWnd->StartY)),2.0));
							for (UINT I = 0;I < Len / pWnd->Amnt;I++) {
								int ValX = pWnd->MouseX - pWnd->StartX;
								int ValY = pWnd->MouseY - pWnd->StartY;
								float X = pWnd->StartX + (float(ValX) / Len) * I * pWnd->Amnt;
								float Y = pWnd->StartY + (float(ValY) / Len) * I * pWnd->Amnt;
								if (X > 0 && X < pWnd->Width && Y > 0 && Y < pWnd->Height) {
									Spawner* pSpawn;
									if (pWnd->Rainbow) {
										pSpawn = new Spawner(X,Y,pWnd->Spawners.size() + 10,pWnd->RbSpeed,pWnd);
									}
									else {
										pSpawn = new Spawner(X,Y,pWnd->UColor,pWnd);
									}
									pWnd->Spawners.push_back(pSpawn);
								}
							}
							pWnd->State = 0;
							pWnd->StartX = 0;
							pWnd->StartY = 0;
						}
					}
					else if (pWnd->Style == 2) {
						if (pWnd->State == 0) {
							pWnd->StartX = pWnd->MouseX;
							pWnd->StartY = pWnd->MouseY;
							pWnd->State++;
						}
						else if (pWnd->State == 1) {
							float Len = sqrt(pow(abs(int(pWnd->MouseX - pWnd->StartX)),2.0) + pow(abs(int(pWnd->MouseY - pWnd->StartY)),2.0));
							float Rad = Len * 2 * PI;
							for (UINT I = 0;I < Rad / pWnd->Amnt;I++) {
								float X = pWnd->StartX + sin(I * (180 / PI)) * Len;
								float Y = pWnd->StartY + cos(I * (180 / PI)) * Len;
								if (X > 0 && X < pWnd->Width && Y > 0 && Y < pWnd->Height) {
									Spawner* pSpawn;
									if (pWnd->Rainbow) {
										pSpawn = new Spawner(X,Y,pWnd->Spawners.size() + 10,pWnd->RbSpeed,pWnd);
									}
									else {
										pSpawn = new Spawner(X,Y,pWnd->UColor,pWnd);
									}
									pWnd->Spawners.push_back(pSpawn);
								}
							}
							pWnd->State = 0;
							pWnd->StartX = 0;
							pWnd->StartY = 0;
						}
					}
					Res = 1;
					WasHndled = true;
					break;
				case WM_RBUTTONUP:
					if (pWnd->Style != 0 && pWnd->State != 0) {
						pWnd->State = 0;
					}
				case WM_LBUTTONUP:
					pWnd->Toggled = false;
					Res = 1;
					WasHndled = true;
					break;
				case WM_COMMAND:
					switch(WParam) {
						case ID_ACTIONS_SAVE:
							pWnd->Save();
							Res = 1;
							WasHndled = true;
							break;
						case ID_ACTIONS_NEW:
							pWnd->Reset();
							Res = 1;
							WasHndled = true;
							break;
						case ID_ACTIONS_EXIT:
							pWnd->Exit = true;
							Res = 1;
							WasHndled = true;
							break;
						case ID_COLOR_WHITE:
							pWnd->CheckItem(ID_COLOR_WHITE,pWnd->Oldie_Col);
							pWnd->Oldie_Col = ID_COLOR_WHITE;
							if (pWnd->Rainbow) {
								pWnd->Rainbow = false;
							}
							pWnd->UColor = Color(255,255,255);
							Res = 1;
							WasHndled = true;
							break;
						case ID_COLOR_GREEN:
							pWnd->CheckItem(ID_COLOR_GREEN,pWnd->Oldie_Col);
							pWnd->Oldie_Col = ID_COLOR_GREEN;
							if (pWnd->Rainbow) {
								pWnd->Rainbow = false;
							}
							pWnd->UColor = Color(0,255,0);
							Res = 1;
							WasHndled = true;
							break;
						case ID_COLOR_RED:
							pWnd->CheckItem(ID_COLOR_RED,pWnd->Oldie_Col);
							pWnd->Oldie_Col = ID_COLOR_RED;
							if (pWnd->Rainbow) {
								pWnd->Rainbow = false;
							}
							pWnd->UColor = Color(255,0,0);
							Res = 1;
							WasHndled = true;
							break;
						case ID_COLOR_BLUE:
							pWnd->CheckItem(ID_COLOR_BLUE,pWnd->Oldie_Col);
							pWnd->Oldie_Col = ID_COLOR_BLUE;
							if (pWnd->Rainbow) {
								pWnd->Rainbow = false;
							}
							pWnd->UColor = Color(0,0,255);
							Res = 1;
							WasHndled = true;
							break;
						case ID_COLOR_YELLOW:
							pWnd->CheckItem(ID_COLOR_YELLOW,pWnd->Oldie_Col);
							pWnd->Oldie_Col = ID_COLOR_YELLOW;
							if (pWnd->Rainbow) {
								pWnd->Rainbow = false;
							}
							pWnd->UColor = Color(255,255,0);
							Res = 1;
							WasHndled = true;
							break;
						case ID_COLOR_TEAL:
							pWnd->CheckItem(ID_COLOR_TEAL,pWnd->Oldie_Col);
							pWnd->Oldie_Col = ID_COLOR_TEAL;
							if (pWnd->Rainbow) {
								pWnd->Rainbow = false;
							}
							pWnd->UColor = Color(0,255,255);
							Res = 1;
							WasHndled = true;
							break;
						case ID_COLOR_PURPLE:
							pWnd->CheckItem(ID_COLOR_PURPLE,pWnd->Oldie_Col);
							pWnd->Oldie_Col = ID_COLOR_PURPLE;
							if (pWnd->Rainbow) {
								pWnd->Rainbow = false;
							}
							pWnd->UColor = Color(255,0,255);
							Res = 1;
							WasHndled = true;
							break;
						case ID_COLOR_RAINBOW:
							pWnd->CheckItem(ID_COLOR_RAINBOW,pWnd->Oldie_Col);
							pWnd->Oldie_Col = ID_COLOR_RAINBOW;
							pWnd->Rainbow = true;
							Res = 1;
							WasHndled = true;
							break;
						case ID_RAINBOWSPEED_12X:
							pWnd->CheckItem(ID_RAINBOWSPEED_12X,pWnd->Oldie_Spd);
							pWnd->Oldie_Spd = ID_RAINBOWSPEED_12X;
							pWnd->RbSpeed = 0.5;
							Res = 1;
							WasHndled = true;
							break;
						case ID_RAINBOWSPEED_1X:
							pWnd->CheckItem(ID_RAINBOWSPEED_1X,pWnd->Oldie_Spd);
							pWnd->Oldie_Spd = ID_RAINBOWSPEED_1X;
							pWnd->RbSpeed = 1;
							Res = 1;
							WasHndled = true;
							break;
						case ID_RAINBOWSPEED_2X:
							pWnd->CheckItem(ID_RAINBOWSPEED_2X,pWnd->Oldie_Spd);
							pWnd->Oldie_Spd = ID_RAINBOWSPEED_2X;
							pWnd->RbSpeed = 2;
							Res = 1;
							WasHndled = true;
							break;
						case ID_RAINBOWSPEED_4X:
							pWnd->CheckItem(ID_RAINBOWSPEED_4X,pWnd->Oldie_Spd);
							pWnd->Oldie_Spd = ID_RAINBOWSPEED_4X;
							pWnd->RbSpeed = 4;
							Res = 1;
							WasHndled = true;
							break;
						case ID_STYLE_NORMAL:
							pWnd->CheckItem(ID_STYLE_NORMAL,pWnd->Oldie_Stl);
							pWnd->Oldie_Stl = ID_STYLE_NORMAL;
							pWnd->Style = 0;
							pWnd->State = 0;
							Res = 1;
							WasHndled = true;
							break;
						case ID_STYLE_LINE:
							pWnd->CheckItem(ID_STYLE_LINE,pWnd->Oldie_Stl);
							pWnd->Oldie_Stl = ID_STYLE_LINE;
							pWnd->Style = 1;
							pWnd->State = 0;
							Res = 1;
							WasHndled = true;
							break;
						case ID_STYLE_CIRCLE:
							pWnd->CheckItem(ID_STYLE_CIRCLE,pWnd->Oldie_Stl);
							pWnd->Oldie_Stl = ID_STYLE_CIRCLE;
							pWnd->Style = 2;
							pWnd->State = 0;
							Res = 1;
							WasHndled = true;
							break;
						case ID_CREDITS:
							DialogBox(HINST_THISCOMPONENT,MAKEINTRESOURCE(IDD_DIALOG1),HWnd,(DLGPROC)DlgProc);
							Res = 1;
							WasHndled = true;
							break;
						case ID_SCREENSHOT:
							pWnd->SaveScreenshot();
							Res = 1;
							WasHndled = true;
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
		Tick();
	}
	for (UINT I = 0;I < Pixels.size();I++) {
		delete Pixels[I];
	}
	for (UINT I = 0;I < Spawners.size();I++) {
		delete Spawners[I];
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
		WndEx.lpszMenuName  = MAKEINTRESOURCE(IDR_MENU1);
		WndEx.hCursor       = LoadCursor(0, IDI_APPLICATION);
		WndEx.lpszClassName = L"MyWndClass";
		WndEx.hIcon			= LoadIcon(WndEx.hInstance,IDI_APPLICATION);
		WndEx.hIconSm		= LoadIcon(WndEx.hInstance,IDI_APPLICATION);
		
		RegisterClassEx(&WndEx);

		m_HWnd = CreateWindowEx(0,
			L"MyWndClass",
			L"NoooCard_Draw",
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