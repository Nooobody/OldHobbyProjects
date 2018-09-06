#include "Wnd.h"

void Pixel::Tick() {
	AliveCheck();
	for (UINT I = 0;I < 8;I++) {
		int X = Clamp(Pos[0] + m_pWnd->NeighP[I][0],6,m_pWnd->Width - 6);
		int Y = Clamp(Pos[1] + m_pWnd->NeighP[I][1],6,m_pWnd->Height - 6);
		if (!FindBox(X,Y)) {
			UINT i = ((m_pWnd->Width / 6) * (Y / 6) + (X / 6));
			auto_ptr<Pixel> Pix(new Pixel);
			Pix->Pos[0] = X;
			Pix->Pos[1] = Y;
			Pix->m_pWnd = m_pWnd;
			if (Pix->AliveCheck()) {
				m_pWnd->AddQueue(X,Y,true);
			}
		}
	}
}

bool Pixel::AliveCheck() {
	UINT Neighbors = CheckNeighbors();
	if (Alive) {
		if (Neighbors < 2 || Neighbors > 3) {
			m_pWnd->AddQueue(Pos[0],Pos[1],false);
			return false;
		}
	}
	else {
		if (Neighbors < 3 || Neighbors > 3) {
			return false;
		}
	}
	return true;
}

UINT Pixel::CheckNeighbors() {
	UINT Count = 0;
	for (UINT I = 0;I < 8;I++) {
		UINT X = Clamp(Pos[0] + m_pWnd->NeighP[I][0],6,m_pWnd->Width - 12);
		UINT Y = Clamp(Pos[1] + m_pWnd->NeighP[I][1],6,m_pWnd->Height - 12);
		if (FindAliveBox(X,Y)) {
			Count++;
		}
	}
	return Count;
}

bool Pixel::FindAliveBox(UINT X,UINT Y) {
	UINT I = ((m_pWnd->Width / 6) * (Y / 6) + (X / 6));
	if (m_pWnd->Pixels[I] == 0 || !m_pWnd->Pixels[I]->Alive) {
		return false;
	}
	else {
		return true;
	}
}

bool Pixel::FindBox(UINT X,UINT Y) {
	UINT I = ((m_pWnd->Width / 6) * (Y / 6) + (X / 6));
	if (m_pWnd->Pixels[I] == 0) {
		return false;
	}
	else {
		return true;
	}
}

string Pixel::Serialize() {
	stringstream SS;
	SS << Pos[0] << "," << Pos[1];
	return SS.str();
}