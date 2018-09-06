#include "Wnd.h"

void Wnd::Tick() {
	HRESULT Hr = CreateRes();

	if (Lines.size() == 0) {
		return;
	}

	if (Int < Lines.size() - 2) {
		UnSerialize();
		Int++;
	}

	for (UINT I = 0;I < Spawners.size();I++) {
		Spawners[I]->Spawn();
	}

	for (UINT I = 0;I < Pixels.size();I++) {
		Pixels[I]->Tick();
	}

	m_pRT->BeginDraw();
		m_pRT->Clear();
		for (UINT I = 0;I < Pixels.size();I++) {
			m_pBrush->SetColor(ColorF(Pixels[I]->Col.R / 255,Pixels[I]->Col.G / 255,Pixels[I]->Col.B / 255,Pixels[I]->Alpha));
			m_pRT->FillRectangle(RectF(Pixels[I]->X,Pixels[I]->Y,Pixels[I]->X + 1,Pixels[I]->Y + 1),m_pBrush);
		}
	Hr = m_pRT->EndDraw();
}

void Wnd::Load() {
	if (Spawners.size() > 0 || Int > 0) {
		Reset();
	}
	CComPtr<IFileOpenDialog> pfd;
	HRESULT Hr = CoCreateInstance(__uuidof(FileOpenDialog),0,CLSCTX_ALL,IID_PPV_ARGS(&pfd));
	if (SUCCEEDED(Hr)) {
		_COMDLG_FILTERSPEC Filter[] = {
			{L"Txt files (*.txt)",L"*.txt"},
			{L"All files",L"*"}
		};
		Hr = pfd->SetFileTypes(2,Filter);
		if (SUCCEEDED(Hr)) {
			Hr = pfd->SetDefaultExtension(L"txt");
			if (SUCCEEDED(Hr)) {
				Hr = pfd->Show(0);
				if (SUCCEEDED(Hr)) {
					CComPtr<IShellItem> psi;
					Hr = pfd->GetResult(&psi);
					if (SUCCEEDED(Hr)) {
						PWSTR pfp = 0;
						Hr = psi->GetDisplayName(SIGDN_FILESYSPATH,&pfp);
						if (SUCCEEDED(Hr)) {
							ifstream IS;
							IS.open(pfp);
							if (IS.is_open()) {
								while (IS.good()) {
									string Line;
									getline(IS,Line);
									Lines.push_back(Line);
								}
							}
							IS.close();
							CoTaskMemFree(pfp);
						}
					}
				}
			}
		}
	}
}

void Wnd::UnSerialize() {
	string Line = Lines[Int];
	UINT X;
	UINT Y;
	bool Rainb = false;
	bool Old = false;
	float Spd;
	float R = 0;
	float G = 0;
	float B = 0;
	if (Line.find("|") != Line.npos) {
		Rainb = true;
	}
	else {
		if (Line.find("&") == Line.npos) {
			Old = true;
		}
	}
	UINT I = Line.find(",",0);
	string sX = Line.substr(0,I);
	string sY;
	if (Rainb) {
		sY = Line.substr(I + 1,Line.find("|") - (I + 1));
	}
	else {
		sY = Line.substr(I + 1,Line.find("&") - (I + 1));
	}
	stringstream NumConvX(sX);
	stringstream NumConvY(sY);
	NumConvX >> X;
	NumConvY >> Y;
	if (!Old) {
		if (Rainb) {
			string sSpd = Line.substr(Line.find("|") + 1);
			stringstream NumConvSpd(sSpd);
			NumConvSpd >> Spd;
		}
		else {
			string sCol,sR,sG,sB;
			sCol = Line.substr(Line.find("&") + 1);
			sR = sCol.substr(0,sCol.find("/"));
			sCol = sCol.substr(sCol.find("/") + 1);
			sG = sCol.substr(0,sCol.find("/"));
			sB = sCol.substr(sCol.find("/") + 1);
			stringstream NCR(sR);
			stringstream NCG(sG);
			stringstream NCB(sB);
			NCR >> R;
			NCG >> G;
			NCB >> B;
		}
	}
	else {
		R = 255;
		G = 255;
		B = 255;
	}
	Spawner* pSpawn;
	if (Rainb) {
		pSpawn = new Spawner(X,Y,Spawners.size() + 10,Spd,this);
	}
	else {
		pSpawn = new Spawner(X,Y,Color(R,G,B),this);
	}
	Spawners.push_back(pSpawn);
}

void Wnd::Reset() {
	for (UINT I = 0;I < Spawners.size();I++) {
		delete Spawners[I];
	}
	Spawners.clear();
	Lines.clear();
	Int = 0;
}