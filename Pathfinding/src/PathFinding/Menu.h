#pragma once
#include "Includes.h"

struct Button {
	Vec2 Pos;
	Vec2 Size;
	FuncMain* Func;
	wstring Str;
};

class Menu {
public:
	Vec2 Pos;
	Vec2 ArrowPos;
	Vec2 Size;
	bool ArrowDown;
	Wnd* pWnd;
	vector<Button*> pBtns;

	Menu(Vec2 P,Vec2 S,Wnd* pW) : Pos(P),Size(S),pWnd(pW) {
		Init();
	}
	void Init();
	void Paint();
	void UpdateArrow(bool);
	void Click(Vec2);
};