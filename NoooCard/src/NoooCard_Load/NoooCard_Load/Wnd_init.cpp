#include "Wnd.h"

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
				case WM_COMMAND:
					switch (WParam) {
						case ID_ACTIONS_LOAD:
							pWnd->Load();
							Res = 1;
							WasHndled = true;
							break;
						case ID_ACTIONS_EXIT:
							pWnd->Exit = true;
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
			L"NoooCard_Load",
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