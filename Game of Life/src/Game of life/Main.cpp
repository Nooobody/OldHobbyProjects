#include "Wnd.h"

int WINAPI WinMain(HINSTANCE hInstance,HINSTANCE hPrevInstance,LPSTR lpCmdLine,int nShowCmd) {
	if (SUCCEEDED(CoInitialize(0))) {
		Wnd Wnd;
		if (SUCCEEDED(Wnd.Create())) {
			Wnd.RunMsgLoop();
		}
		CoUninitialize();
	}
	return 0;
}

UINT Clamp(UINT Val,UINT Min,UINT Max) {
	if (Val < Min) {
		return Min;
	}
	else if (Val > Max) {
		return Max;
	}
	return Val;
}