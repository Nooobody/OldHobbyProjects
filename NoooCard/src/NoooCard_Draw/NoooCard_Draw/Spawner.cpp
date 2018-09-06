#include "Wnd.h"

void Spawner::Spawn() {
	if (Int > 10) {
		Int = 0;
		Color C = Col;
		if (Rainbow) {
			C = GetColor();
		}
		if (X > 0 && X < pWnd->Width && Y > 0 && Y < pWnd->Height) {
			Pixel* Pix = new Pixel(X,Y,C,C,Velocity(sin((rand() % 360) * (180 / PI)),cos((rand() % 360) * (180 / PI))),0.3,pWnd);
			pWnd->Pixels.push_back(Pix);
		}
	}
	Hue += Spd;
	if (Hue >= 360) {
		Hue = 0;
	}
	Int++;
}

string Spawner::Serialize() {
	stringstream Str;
	Str << X << "," << Y;
	if (Rainbow) {
		Str << "|" << Spd;
	}
	else {
		Str << "&" << Col.R << "/" << Col.G << "/" << Col.B;
	}
	Str << "\n";
	return Str.str();
}

Color Spawner::GetColor() {
	float R,G,B;
	if (Hue >= 0 && Hue < 60) {
		R = 255;
		G = 255 * (Hue / 60.0);
		B = 0;
	}
	else if (Hue >= 60 && Hue < 120) {
		R = 255 * (1 - (fmod(Hue,60) / 60.0));
		G = 255;
		B = 0;
	}
	else if (Hue >= 120 && Hue < 180) {
		R = 0;
		G = 255;
		B = 255 * (fmod(Hue,60) / 60.0);
	}
	else if (Hue >= 180 && Hue < 240)  {
		R = 0;
		G = 255 * (1 - (fmod(Hue,60) / 60.0));
		B = 255;
	}
	else if (Hue >= 240 && Hue < 300) {
		R = 255 * (fmod(Hue,60) / 60.0);
		G = 0;
		B = 255;
	}
	else if (Hue >= 300 && Hue < 360) {
		R = 255;
		G = 0;
		B = 255 * (1 - (fmod(Hue,60) / 60.0));
	}
	return Color(R,G,B);
}