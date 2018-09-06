#include "Wnd.h"

bool Wnd::IsMouseInside(Vec2 P,Vec2 S) {
	if (MouseX > P.X && MouseX < P.X + S.X && MouseY > P.Y && MouseY < P.Y + S.Y) {
		return true;
	}
	return false;
}

void Wnd::LBtnUp() {
	if (MazeMouseAction) {
		if (pMaze->IsPoint(Vec2(MouseX - MouseX % POINTSIZE,MouseY - MouseY % POINTSIZE))) {
			MazeMouseAction = false;
			pMaze->Solve(Vec2(MouseX - MouseX % POINTSIZE,MouseY - MouseY % POINTSIZE));
		}
	}
	if (IsMouseInside(MainMenu->Pos,MainMenu->Size)) {
		MainMenu->Click(Vec2(MouseX,MouseY));
	}
	if (IsMouseInside(MainMenu->ArrowPos,Vec2(64,64))) {
		MainMenu->UpdateArrow(!MainMenu->ArrowDown);
	}
}

void Wnd::LBtnDown() {

}

void Wnd::RBtnDown() {

}

void Wnd::RBtnUp() {

}