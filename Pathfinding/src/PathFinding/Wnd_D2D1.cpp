#include "Wnd.h"

HRESULT Wnd::CreateIndRes() {
	HRESULT Hr = D2D1CreateFactory(D2D1_FACTORY_TYPE_SINGLE_THREADED,&m_pDirect2dFactory);

	if (SUCCEEDED(Hr)) {
		Hr = CoCreateInstance(
				CLSID_WICImagingFactory,
				NULL,
				CLSCTX_INPROC_SERVER,
				IID_IWICImagingFactory,
				(LPVOID*)&m_pWICFactory
				);
	}

	if (SUCCEEDED(Hr)) {
		Hr = DWriteCreateFactory(DWRITE_FACTORY_TYPE_SHARED,__uuidof(m_pWrite),reinterpret_cast<IUnknown **>(&m_pWrite));
	}

	if (SUCCEEDED(Hr)) {
		Hr = m_pWrite->CreateTextFormat(
				L"Arial",
				NULL,
				DWRITE_FONT_WEIGHT_NORMAL,
				DWRITE_FONT_STYLE_NORMAL,
				DWRITE_FONT_STRETCH_NORMAL,
				8,
				L"",
				&m_pSmallTextFormat
				);
		Hr = m_pWrite->CreateTextFormat(
				L"Arial",
				NULL,
				DWRITE_FONT_WEIGHT_NORMAL,
				DWRITE_FONT_STYLE_NORMAL,
				DWRITE_FONT_STRETCH_NORMAL,
				16,
				L"",
				&m_pMediumTextFormat
				);
		Hr = m_pWrite->CreateTextFormat(
				L"Arial",
				NULL,
				DWRITE_FONT_WEIGHT_NORMAL,
				DWRITE_FONT_STYLE_NORMAL,
				DWRITE_FONT_STRETCH_NORMAL,
				24,
				L"",
				&m_pLargeTextFormat
				);
		if (SUCCEEDED(Hr)) {
			m_pSmallTextFormat->SetWordWrapping(DWRITE_WORD_WRAPPING_NO_WRAP);
			m_pMediumTextFormat->SetWordWrapping(DWRITE_WORD_WRAPPING_NO_WRAP);
			m_pLargeTextFormat->SetWordWrapping(DWRITE_WORD_WRAPPING_NO_WRAP);
		}
	}
	return Hr;
}

HRESULT Wnd::CreateRes() {
	HRESULT Hr = S_OK;
	if (!m_pRT) {
		RECT Rc;
		GetClientRect(m_HWnd,&Rc);
		D2D1_SIZE_U Size = SizeU(Rc.right - Rc.left,Rc.bottom - Rc.top);
		
		D2D1_RENDER_TARGET_PROPERTIES RTPro = RenderTargetProperties();
		RTPro.pixelFormat = PixelFormat(DXGI_FORMAT_B8G8R8A8_UNORM,D2D1_ALPHA_MODE_PREMULTIPLIED);
		RTPro.type = D2D1_RENDER_TARGET_TYPE_SOFTWARE;
		Hr = m_pDirect2dFactory->CreateHwndRenderTarget(&RTPro,&HwndRenderTargetProperties(m_HWnd,Size),&m_pRT);

		D2D1_SIZE_F FSize = m_pRT->GetSize();
		Width = static_cast<UINT>(FSize.width);
		Height = static_cast<UINT>(FSize.height);

		if (SUCCEEDED(Hr)) {
			m_pRT->SetAntialiasMode(D2D1_ANTIALIAS_MODE_ALIASED);
			Hr = m_pRT->CreateSolidColorBrush(ColorF(ColorF::White),&m_pBrush);
		}
	}
	return Hr;
}

void Wnd::SetColor(ColorF Col) {m_pBrush->SetColor(Col);}

void Wnd::LoadPng(LPCWSTR Name,ID2D1Bitmap** pBit) {
	CComPtr<IWICBitmapDecoder> pDecoder;
	CComPtr<IWICBitmapFrameDecode> pFrame;
	CComPtr<IWICFormatConverter> pConv;
	HRESULT Hr;

	Hr = m_pWICFactory->CreateDecoderFromFilename(Name,NULL,GENERIC_READ,WICDecodeMetadataCacheOnDemand,&pDecoder);

	if (SUCCEEDED(Hr)) {
		Hr = pDecoder->GetFrame(0,&pFrame);
	}
	
	if (SUCCEEDED(Hr)) {
		Hr = pFrame->GetSize(&W,&H);
	}

	if (SUCCEEDED(Hr)) {
		Hr = m_pWICFactory->CreateFormatConverter(&pConv);
	}

	if (SUCCEEDED(Hr)) {
		Hr = pConv->Initialize(pFrame,GUID_WICPixelFormat32bppPBGRA,WICBitmapDitherTypeNone,0,0.f,WICBitmapPaletteTypeCustom);
	}
	
	if (SUCCEEDED(Hr)) {
		Hr = m_pRT->CreateBitmapFromWicBitmap(pConv,0,pBit);
	}
}

Vec2 Wnd::GetTextSize(wstring Str,unsigned char TSize) {
	CComPtr<IDWriteTextLayout> Layout;
	if (TSize == 0) m_pWrite->CreateTextLayout(Str.c_str(),Str.length(),m_pSmallTextFormat,800,40,&Layout);
	else if (TSize == 1) m_pWrite->CreateTextLayout(Str.c_str(),Str.length(),m_pMediumTextFormat,800,40,&Layout);
	else if (TSize == 2) m_pWrite->CreateTextLayout(Str.c_str(),Str.length(),m_pLargeTextFormat,800,40,&Layout);

	DWRITE_TEXT_METRICS TM;
	Layout->GetMetrics(&TM);

	return Vec2(TM.width,TM.height);
}

void Wnd::DrawText(wstring Str,Vec2 P,Vec2 S,unsigned char TSize) {
	CComPtr<IDWriteTextLayout> Layout;
	if (TSize == 0) m_pWrite->CreateTextLayout(Str.c_str(),Str.length(),m_pSmallTextFormat,S.X,S.Y,&Layout);
	else if (TSize == 1) m_pWrite->CreateTextLayout(Str.c_str(),Str.length(),m_pMediumTextFormat,S.X,S.Y,&Layout);
	else if (TSize == 2) m_pWrite->CreateTextLayout(Str.c_str(),Str.length(),m_pLargeTextFormat,S.X,S.Y,&Layout);

	m_pRT->DrawTextLayout(Point2F(P.X,P.Y),Layout,m_pBrush);
}