#include "Wnd.h"

int Pixel::HalfPixel(double Vel,double *WhichHalf) {
	*WhichHalf += Vel;
	if (*WhichHalf > 1) {
		*WhichHalf -= 1;
		return 1;
	}
	else if (*WhichHalf < -1) {
		*WhichHalf += 1;
		return -1;
	}
	return 0;
}

void Pixel::InterpolateCol() {
	Col.R += (EndCol.R - Col.R) / (Lifetime / 50);
	Col.G += (EndCol.G - Col.G) / (Lifetime / 50);
	Col.B += (EndCol.B - Col.B) / (Lifetime / 50);
}

void Pixel::Tick() {
	if (Vel.X != 0 || Vel.Y != 0) {
		double F,I;
		F = modf(Vel.X,&I);
		if (F != 0) {
			I += HalfPixel(F,&HalfX);
		}
		X = Clamp(X + I,0,m_pWnd->Width);
		F = modf(Vel.Y,&I);
		if (F != 0) {
			I += HalfPixel(F,&HalfY);
		}
		Y = Clamp(Y + I,0,m_pWnd->Height);
	}
	if (EndCol.R != Col.R || EndCol.G != Col.G || EndCol.B != Col.B) {
		InterpolateCol();
	}

	if (StartTime + Lifetime < clock()) {
		Die();
	}
	else {
		Alpha = ((float(StartTime + Lifetime) - float(clock())) / float(Lifetime));
	}
}

void Pixel::Die() {
	for (UINT I = 0;I < m_pWnd->Pixels.size();I++) {
		if (m_pWnd->Pixels[I] == this) {
			m_pWnd->Pixels.erase(m_pWnd->Pixels.begin() + I);
			break;
		}
	}
	delete this;
}