#include "Wnd.h"


HRESULT Wnd::CreateIndRes() {
	HRESULT Hr = D2D1CreateFactory(D2D1_FACTORY_TYPE_SINGLE_THREADED,&m_pDirect2dFactory);
	return Hr;
}

HRESULT Wnd::CreateRes() {
	HRESULT Hr = S_OK;
	if (!m_pRT) {
		RECT Rc;
		GetClientRect(m_HWnd,&Rc);
		D2D1_SIZE_U Size = SizeU(Rc.right - Rc.left,Rc.bottom - Rc.top);
		
		D2D1_RENDER_TARGET_PROPERTIES RTPro = RenderTargetProperties();
		RTPro.type = D2D1_RENDER_TARGET_TYPE_HARDWARE;
		Hr = m_pDirect2dFactory->CreateHwndRenderTarget(&RTPro,&HwndRenderTargetProperties(m_HWnd,Size),&m_pRT);

		D2D1_SIZE_F FSize = m_pRT->GetSize();
		Width = static_cast<UINT>(FSize.width);
		Height = static_cast<UINT>(FSize.height);
		Pixels = new Pixel *[(Width / 6) * (Height / 6)](); 

		if (SUCCEEDED(Hr)) {
			m_pRT->SetAntialiasMode(D2D1_ANTIALIAS_MODE_ALIASED);
			Hr = m_pRT->CreateSolidColorBrush(ColorF(ColorF::Green),&m_pBrush);
		}
	}
	return Hr;
}

void Wnd::UpdateGrid() {
	HRESULT Hr = S_OK;
	CreateRes();
	m_pRT->BeginDraw();
		m_pRT->Clear(&ColorF(ColorF::Black));
		if (AlivePixels.size() > 0) {
			for (UINT I = 0;I < AlivePixels.size();I++) {
				m_pRT->FillRectangle(RectF(AlivePixels[I]->Pos[0],AlivePixels[I]->Pos[1],AlivePixels[I]->Pos[0] + 6,AlivePixels[I]->Pos[1] + 6),m_pBrush);
			}
		}
	Hr = m_pRT->EndDraw();
	if (Hr == D2DERR_RECREATE_TARGET) {
        Hr = S_OK;
        DiscRes();
    }
}

void Wnd::Tick() {
	CreateRes();
	for (UINT I = 0;I < AlivePixels.size();I++) {
		AlivePixels[I]->Tick();
	}

	if (Queue.size() > 0) {
		ExecuteQueue();
	}

	m_pRT->BeginDraw();
		m_pRT->Clear(&ColorF(ColorF::Black));
		for (UINT I = 0;I < AlivePixels.size();I++) {
			m_pRT->FillRectangle(RectF(AlivePixels[I]->Pos[0],AlivePixels[I]->Pos[1],AlivePixels[I]->Pos[0] + 6,AlivePixels[I]->Pos[1] + 6),m_pBrush);
		}
	HRESULT Hr = m_pRT->EndDraw();
	if (Hr == D2DERR_RECREATE_TARGET) {
        Hr = S_OK;
        DiscRes();
    }
}

void Wnd::DiscRes() {
	m_pRT.Release();
	m_pBrush.Release();
}

void Wnd::Resize() {
	DiscRes();
	UpdateGrid();
}