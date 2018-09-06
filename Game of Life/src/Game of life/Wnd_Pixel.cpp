#include "Wnd.h"

bool Wnd::SetDot(UINT X,UINT Y) {
	X = X - (X % 6);
	Y = Y - (Y % 6);
	UINT I = (Width / 6) * (Y / 6) + (X / 6);
	bool Made = false;
	if (Pixels[I] == 0) {
		Pixels[I] = new Pixel;
		Pixels[I]->Pos[0] = X;
		Pixels[I]->Pos[1] = Y;
		Pixels[I]->Alive = true;
		Pixels[I]->m_pWnd = this;
		AlivePixels.push_back(Pixels[I]);
		Made = true;
	}
	else {
		for (UINT i = 0;i < AlivePixels.size();i++) {
			if (AlivePixels[i] == Pixels[I]) {
				AlivePixels.erase(AlivePixels.begin() + i);
				break;
			}
		}
		Pixel* Pix = Pixels[I];
		Pixels[I] = 0;
		delete Pix;
	}
	UpdateGrid();
	return Made;
}

void Wnd::AddQueue(UINT X,UINT Y,bool Alive) {
	Task T = Task();
	T.X = X;
	T.Y = Y;
	T.Alive = Alive;
	Queue.push_back(T);
}

void Wnd::ExecuteQueue() {
	for (UINT I = 0;I < Queue.size();I++) {
		Task* pT = &Queue[I];
		UINT i = (Width / 6) * (pT->Y / 6) + (pT->X / 6);
		if (pT->Alive && Pixels[i] == 0) {
			Pixels[i] = new Pixel;
			Pixels[i]->Pos[0] = pT->X;
			Pixels[i]->Pos[1] = pT->Y;
			Pixels[i]->Alive = true;
			Pixels[i]->m_pWnd = this;
			AlivePixels.push_back(Pixels[i]);
		}
		else if (!pT->Alive) {
			for (UINT a = 0;a < AlivePixels.size();a++) {
				if (AlivePixels[a]->Pos[0] == pT->X && AlivePixels[a]->Pos[1] == pT->Y) {
					AlivePixels.erase(AlivePixels.begin() + a);
					break;
				}
			}
			Pixel* Pix = Pixels[i];
			Pixels[i] = 0;
			delete Pix;
		}
	}
	Queue.clear();
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
							ofstream OF;
							OF.open(pfp,ios::out);
							for (UINT I = 0;I < AlivePixels.size();I++) {
								OF << AlivePixels[I]->Serialize() << "\n";
							}
							OF.close();
							CoTaskMemFree(pfp);
						}
					}
				}
			}
		}
	}
}

void Wnd::Load() {
	if (AlivePixels.size() > 0) {
		AlivePixels = RemPixels(AlivePixels);
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
							ifstream IF;
							IF.open(pfp,ios::in);
							while (IF.good()) {
								string Str;
								getline(IF,Str);
								UnSerialize(Str);
							}
							IF.close();
							CoTaskMemFree(pfp);
						}
					}
				}
			}
		}
	}
	UpdateGrid();
}

void Wnd::UnSerialize(string Str) {
	for (UINT I = 0;I < Str.size();I++) {
		if (Str[I] == *",") {
			string sX = "";
			string sY = "";
			for (UINT i = 0;i < I;i++) {
				sX += Str[i];
			}
			for (UINT i = I + 1;i < Str.size();i++) {
				sY += Str[i];
			}
			UINT X;
			UINT Y;
			stringstream NumConvX(sX);
			stringstream NumConvY(sY);
			NumConvX >> X;
			NumConvY >> Y;
			UINT Int = (Width / 6) * (Y / 6) + (X / 6);
			Pixels[Int] = new Pixel;
			Pixels[Int]->Pos[0] = X;
			Pixels[Int]->Pos[1] = Y;
			Pixels[Int]->Alive = true;
			Pixels[Int]->m_pWnd = this;
			AlivePixels.push_back(Pixels[Int]);
		}
	}
}

vector<Pixel*> Wnd::Copy(vector<Pixel*> Pixs,bool Stopped) {
	vector<Pixel*> NewPixs;
	for (UINT I = 0;I < Pixs.size();I++) {
		Pixel* Pix = new Pixel;
		Pix->Pos[0] = Pixs[I]->Pos[0];
		Pix->Pos[1] = Pixs[I]->Pos[1];
		Pix->Alive = true;
		Pix->m_pWnd = this;
		NewPixs.push_back(Pix);
		if (Stopped) {
			UINT i = (Width / 6) * (Pix->Pos[1] / 6) + (Pix->Pos[0] / 6);
			Pixels[i] = Pix;
			Pixel* Pix = Pixs[I];
			Pixs[I] = 0;
			delete Pix;
		}
	}
	if (Stopped) {
		Pixs.clear();
	}
	return NewPixs;
}

vector<Pixel*> Wnd::RemPixels(vector<Pixel*> Pixs) {
	for (UINT I = 0;I < Pixs.size();I++) {
		UINT X = Pixs[I]->Pos[0];
		UINT Y = Pixs[I]->Pos[1];
		UINT i = (Width / 6) * (Y / 6) + (X / 6);
		if (Pixels[i] != 0) {
			Pixel* Pix = Pixels[i];
			Pixels[i] = 0;
			delete Pix;
		}
	}
	Pixs.clear();
	return Pixs;
}

void Wnd::RemPixels() {
	for (UINT I = 0;I < (Width / 6) * (Height / 6);I++) {
		if (Pixels[I] != 0) {
			Pixel* Pix = Pixels[I];
			Pixels[I] = 0;
			delete Pix;
		}
	}
}