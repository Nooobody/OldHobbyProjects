#include "Wnd.h"

void Wnd::Tick() {
	HRESULT Hr = CreateRes();

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
		if (Style == 0) {
			m_pBrush->SetColor(ColorF(UColor.R / 255,UColor.G / 255,UColor.B / 255,1));
			m_pRT->FillRectangle(RectF(MouseX,MouseY,MouseX + 1,MouseY + 1),m_pBrush);
			DoSparkles(MouseX,MouseY);
		}
		else if (Style == 1) {
			m_pBrush->SetColor(ColorF(UColor.R / 255,UColor.G / 255,UColor.B / 255,0.4));
			m_pRT->FillEllipse(Ellipse(Point2F(MouseX,MouseY),10,10),m_pBrush);
			if (State == 1) {
				m_pRT->FillEllipse(Ellipse(Point2F(StartX,StartY),10,10),m_pBrush);
				float Len = sqrt(pow(abs(int(MouseX - StartX)),2.0) + pow(abs(int(MouseY - StartY)),2.0));
				for (UINT I = 0;I < Len;I += Amnt) {
					int ValX = MouseX - StartX;
					int ValY = MouseY - StartY;
					D2D1_POINT_2F Point = Point2F(StartX + (float(ValX) / Len) * I,StartY + (float(ValY) / Len) * I);
					m_pRT->FillEllipse(Ellipse(Point,10,10),m_pBrush);
				}
			}
		}
		else if (Style == 2) {
			if (State == 1) {
				m_pBrush->SetColor(ColorF(UColor.R / 255,UColor.G / 255,UColor.B / 255,0.4));
				float Len = sqrt(pow(abs(int(MouseX - StartX)),2.0) + pow(abs(int(MouseY - StartY)),2.0));
				float Rad = Len * 2 * PI;
				for (UINT I = 0;I < Rad / Amnt;I++) {
					float X = sin(I * (180 / PI)) * Len;
					float Y = cos(I * (180 / PI)) * Len;
					m_pRT->FillEllipse(Ellipse(Point2F(StartX + X,StartY + Y),10,10),m_pBrush);
				}
			}
		}
	Hr = m_pRT->EndDraw();
}

void Wnd::DoSparkles(UINT X,UINT Y) {
	Pixel* Pix = new Pixel(X,Y,UColor,UColor,Velocity(sin((rand() % 360) * (180 / PI)),cos((rand() % 360) * (180 / PI))),0.4,this);
	Pixels.push_back(Pix);
}

void Wnd::Save() {
	CComPtr<IFileSaveDialog> pfd;
	HRESULT Hr = CoCreateInstance(__uuidof(FileSaveDialog),0,CLSCTX_ALL,IID_PPV_ARGS(&pfd));
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
							string Str;
							for (UINT I = 0;I < Spawners.size();I++) {
								Str += Spawners[I]->Serialize();
							}
							ofstream FS;
							FS.open(pfp);
							if (FS.is_open()) {
								FS << Str;
							}
							FS.close();
							CoTaskMemFree(pfp);
						}
					}
				}
			}
		}
	}
}

void Wnd::Reset() {
	for (UINT I = 0;I < Spawners.size();I++) {
		delete Spawners[I];
	}
	Spawners.clear();
}