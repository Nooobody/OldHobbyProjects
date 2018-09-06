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

int Clamp(int Val,int Min,int Max) {
	if (Val > Max) return Max;
	else if (Val < Min) return Min;
	return Val;
}

float Clamp(float Val,float Min,float Max) {
	if (Val > Max) return Max;
	else if (Val < Min) return Min;
	return Val;
}