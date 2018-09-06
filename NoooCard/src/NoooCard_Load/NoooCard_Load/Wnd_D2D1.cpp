#include "Wnd.h"


HRESULT Wnd::CreateIndRes() {
	HRESULT Hr = D2D1CreateFactory(D2D1_FACTORY_TYPE_SINGLE_THREADED,&m_pDirect2dFactory);
	return Hr;
}

HRESULT Wnd::CreateRes() {
	HRESULT Hr = S_OK;
	if (!m_pRT) {
		StartTime = clock();
		RECT Rc;
		GetClientRect(m_HWnd,&Rc);
		D2D1_SIZE_U Size = SizeU(Rc.right - Rc.left,Rc.bottom - Rc.top);
		
		D2D1_RENDER_TARGET_PROPERTIES RTPro = RenderTargetProperties();
		RTPro.pixelFormat = PixelFormat(DXGI_FORMAT_B8G8R8A8_UNORM,D2D1_ALPHA_MODE_PREMULTIPLIED);
		RTPro.type = D2D1_RENDER_TARGET_TYPE_HARDWARE;
		Hr = m_pDirect2dFactory->CreateHwndRenderTarget(&RTPro,&HwndRenderTargetProperties(m_HWnd,Size),&m_pRT);

		D2D1_SIZE_F FSize = m_pRT->GetSize();
		Width = static_cast<UINT>(FSize.width);
		Height = static_cast<UINT>(FSize.height);

		if (SUCCEEDED(Hr)) {
			m_pRT->SetAntialiasMode(D2D1_ANTIALIAS_MODE_ALIASED);
			Hr = m_pRT->CreateSolidColorBrush(ColorF(ColorF::Green),&m_pBrush);
		}
	}
	return Hr;
}

void Wnd::SaveScreenshot() {
	CComPtr<IWICImagingFactory> pWICFactory;
	CComPtr<IWICBitmapEncoder> pEnc;
	CComPtr<IWICBitmapFrameEncode> pFrame;
	CComPtr<IWICBitmap> pBit;
	CComPtr<IWICStream> pStream;
	CComPtr<ID2D1RenderTarget> pRT;
	CComPtr<ID2D1SolidColorBrush> pBrush;
	WICPixelFormatGUID Frmt = GUID_WICPixelFormat32bppPBGRA;

	CoCreateInstance(
		CLSID_WICImagingFactory,
		NULL,
		CLSCTX_INPROC_SERVER,
		IID_IWICImagingFactory,
		(LPVOID*)&pWICFactory
	);

	pWICFactory->CreateBitmap(Width,Height,Frmt,WICBitmapCacheOnLoad,&pBit);
	m_pDirect2dFactory->CreateWicBitmapRenderTarget(pBit,RenderTargetProperties(),&pRT);

	pRT->CreateSolidColorBrush(ColorF(0,0,0),&pBrush);

	pRT->BeginDraw();
		pRT->FillRectangle(RectF(0,0,Width,Height),pBrush);
		for (UINT I = 0;I < Pixels.size();I++) {
			pBrush->SetColor(ColorF(Pixels[I]->Col.R / 255,Pixels[I]->Col.G / 255,Pixels[I]->Col.B / 255,Pixels[I]->Alpha));
			pRT->FillRectangle(RectF(Pixels[I]->X,Pixels[I]->Y,Pixels[I]->X + 1,Pixels[I]->Y + 1),pBrush);
		}
	pRT->EndDraw();

	pWICFactory->CreateStream(&pStream);

	CComPtr<IFileSaveDialog> pfd;
	HRESULT Hr = CoCreateInstance(__uuidof(FileSaveDialog),0,CLSCTX_ALL,IID_PPV_ARGS(&pfd));
	if (SUCCEEDED(Hr)) {
		_COMDLG_FILTERSPEC Filter[] = {
			{L"Png files (*.png)",L"*.png"},
			{L"All files",L"*"}
		};
		Hr = pfd->SetFileTypes(2,Filter);
		if (SUCCEEDED(Hr)) {
			Hr = pfd->SetDefaultExtension(L"png");
			if (SUCCEEDED(Hr)) {
				Hr = pfd->Show(0);
				if (SUCCEEDED(Hr)) {
					CComPtr<IShellItem> psi;
					Hr = pfd->GetResult(&psi);
					if (SUCCEEDED(Hr)) {
						PWSTR pfp = 0;
						Hr = psi->GetDisplayName(SIGDN_FILESYSPATH,&pfp);
						if (SUCCEEDED(Hr)) {
							pStream->InitializeFromFilename(pfp,GENERIC_WRITE);
							pWICFactory->CreateEncoder(GUID_ContainerFormatPng,NULL,&pEnc);
							pEnc->Initialize(pStream,WICBitmapEncoderNoCache);
							pEnc->CreateNewFrame(&pFrame,NULL);
							pFrame->Initialize(0);
							pFrame->SetSize(Width,Height);
							pFrame->SetPixelFormat(&Frmt);
							pFrame->WriteSource(pBit,0);
							pFrame->Commit();
							pEnc->Commit();
							CoTaskMemFree(pfp);
						}
					}
				}
			}
		}
	}
}