#include "Menu.h"
#include "Wnd.h"
#include "Mouse_Actions.h"

void Menu::Paint() {
	pWnd->SetColor(GetCol(120,120,120));
	pWnd->m_pRT->FillEllipse(Ellipse(Point2F(ArrowPos.X + 32,ArrowPos.Y + 32),32,32),pWnd->m_pBrush);
	if (ArrowDown) {
		pWnd->SetColor(GetCol(200,200,200));
		pWnd->m_pRT->DrawLine(Point2F(ArrowPos.X + 18,ArrowPos.Y + 18),Point2F(ArrowPos.X + 32,ArrowPos.Y + 8),pWnd->m_pBrush);
		pWnd->m_pRT->DrawLine(Point2F(ArrowPos.X + 46,ArrowPos.Y + 18),Point2F(ArrowPos.X + 32,ArrowPos.Y + 8),pWnd->m_pBrush);
		pWnd->m_pRT->DrawLine(Point2F(ArrowPos.X + 32,ArrowPos.Y + 8),Point2F(ArrowPos.X + 32,ArrowPos.Y + 32),pWnd->m_pBrush);
	}
	else {
		pWnd->SetColor(GetCol(200,200,200));
		pWnd->m_pRT->DrawLine(Point2F(ArrowPos.X + 18,ArrowPos.Y + 22),Point2F(ArrowPos.X + 32,ArrowPos.Y + 32),pWnd->m_pBrush);
		pWnd->m_pRT->DrawLine(Point2F(ArrowPos.X + 46,ArrowPos.Y + 22),Point2F(ArrowPos.X + 32,ArrowPos.Y + 32),pWnd->m_pBrush);
		pWnd->m_pRT->DrawLine(Point2F(ArrowPos.X + 32,ArrowPos.Y + 8),Point2F(ArrowPos.X + 32,ArrowPos.Y + 32),pWnd->m_pBrush);
	}
	pWnd->SetColor(GetCol(120,120,120));
	pWnd->m_pRT->FillRectangle(GetRect(Pos,Size),pWnd->m_pBrush);
	pWnd->SetColor(GetCol(255,255,255));
	pWnd->m_pRT->DrawRectangle(GetRect(Pos,Size),pWnd->m_pBrush);
	for (unsigned char I = 0;I < pBtns.size();I++) {
		pWnd->SetColor(GetCol(140,140,140));
		pWnd->m_pRT->FillRectangle(GetRect(Pos + pBtns[I]->Pos,pBtns[I]->Size - Vec2(0,pBtns[I]->Size.Y / 2)),pWnd->m_pBrush);
		pWnd->SetColor(GetCol(100,100,100));
		pWnd->m_pRT->FillRectangle(GetRect(Pos + pBtns[I]->Pos + Vec2(0,pBtns[I]->Size.Y / 2),pBtns[I]->Size - Vec2(0,pBtns[I]->Size.Y / 2)),pWnd->m_pBrush);
		pWnd->SetColor(GetCol(255,255,255));
		pWnd->m_pRT->DrawRectangle(GetRect(Pos + pBtns[I]->Pos,pBtns[I]->Size),pWnd->m_pBrush);
		Vec2 TextSize = pWnd->GetTextSize(pBtns[I]->Str,1);
		pWnd->DrawText(pBtns[I]->Str,Pos + pBtns[I]->Pos + Vec2(pBtns[I]->Size.X / 2 - TextSize.X / 2,pBtns[I]->Size.Y / 2 - 8),pBtns[I]->Size,1);
	}
}

void Menu::Init() {
	ArrowDown = false;
	ArrowPos = Pos + Vec2(Size.X / 2 - 32,-32);
	Button* B = new Button();
	B->Pos = Vec2(32,32);
	B->Size = Vec2(80,30);
	B->Str = L"Generate";
	B->Func = new Generate_Func(pWnd->pMaze);
	pBtns.push_back(B);
	B = new Button();
	B->Pos = Vec2(185,32);
	B->Size = Vec2(60,30);
	B->Str = L"Reset";
	B->Func = new Reset_Func(pWnd->pMaze);
	pBtns.push_back(B);
	B = new Button();
	B->Pos = Vec2(120,32);
	B->Size = Vec2(60,30);
	B->Str = L"Solve";
	B->Func = new Solve_Func(pWnd->pMaze);
	pBtns.push_back(B);
	B = new Button();
	B->Pos = Vec2(20,4);
	B->Size = Vec2(100,22);
	B->Str = L"Toggle Rects";
	B->Func = new Toggle_Func(pWnd->pMaze);
	pBtns.push_back(B);
	B = new Button();
	B->Pos = Vec2(250,32);
	B->Size = Vec2(60,30);
	B->Str = L"Exit";
	B->Func = new Exit_Func(pWnd);
	pBtns.push_back(B);
}

void Menu::Click(Vec2 MPos) {
	for (unsigned char I = 0;I < pBtns.size();I++) {
		if (pWnd->IsMouseInside(Pos + pBtns[I]->Pos,pBtns[I]->Size)) {
			(*pBtns[I]->Func)();
			return;
		}
	}
}

void Menu::UpdateArrow(bool bDown) {
	ArrowDown = bDown;
	if (bDown) {
		Pos = Pos + Vec2(0,Size.Y);
	}
	else {
		Pos = Pos - Vec2(0,Size.Y);
	}
	ArrowPos = Pos + Vec2(Size.X / 2 - 32,-32);
}