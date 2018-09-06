#include "Wnd.h"

void Wnd::Tick() {
	if (GenerateToggle) pMaze->Generate();
	m_pRT->BeginDraw();
		m_pRT->Clear();
		pMaze->Paint();
		MainMenu->Paint();
	m_pRT->EndDraw();
}

void Wnd::InitFunc() {
	srand(time(0));
	pMaze = new Maze(this);
	MainMenu = new Menu(Vec2(Width / 2 - 160,Height - 80),Vec2(320,80),this);
}