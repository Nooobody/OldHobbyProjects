#pragma once
#include <Windows.h>
#include <WindowsX.h>
#include <stdlib.h>
#include <malloc.h>
#include <memory.h>
#include <vector>
#include <math.h>
#include <random>
#include <time.h>

#include <d2d1.h>
#include <d2d1helper.h>
#include <dwrite.h>
#include <wincodec.h>
#include <atlbase.h>

#include "Functionoid.h"

using namespace std;
using namespace D2D1;

#define PI 3.14159265
#define WIDTH 860
#define HEIGHT 640

#define POINTSIZE 4

#define UP 1
#define RIGHT 2
#define DOWN 3
#define LEFT 4

class Wnd;

struct Vec2 {
	int X;
	int Y;

	Vec2(int x,int y) : X(x),Y(y) {}
	Vec2() : X(0),Y(0) {}
	Vec2 operator+ (Vec2 &A) {
		return Vec2(this->X + A.X,this->Y + A.Y);
	}

	Vec2 operator- (Vec2 &A) {
		return Vec2(this->X - A.X,this->Y - A.Y);
	}

	bool operator== (Vec2 &A) {
		return A.X == this->X && A.Y == this->Y;
	}

	bool operator!= (Vec2 &A) {
		return !(A == *this);
	}
};

struct Vec2F {
	float X;
	float Y;

	Vec2F(float x,float y) : X(x),Y(y) {}
	Vec2F() : X(0),Y(0) {}
	Vec2F operator+ (Vec2 &A) {
		return Vec2F(this->X + A.X,this->Y + A.Y);
	}

	Vec2F operator- (Vec2 &A) {
		return Vec2F(this->X - A.X,this->Y - A.Y);
	}
};

struct KeyMapping {
	UINT Code;
	wstring Key;
	KeyMapping(UINT code,wstring key) : Code(code),Key(key) {}
};

int Clamp(int Val,int Min,int Max);
float Clamp(float Val,float Min,float Max);

#ifndef HINST_THISCOMPONENT
EXTERN_C IMAGE_DOS_HEADER __ImageBase;
#define HINST_THISCOMPONENT ((HINSTANCE)&__ImageBase)
#endif

inline D2D1_RECT_F GetRect(Vec2 &P,Vec2 &S) {return RectF(P.X,P.Y,P.X + S.X,P.Y + S.Y);}
inline ColorF GetCol(unsigned char R,unsigned char G,unsigned char B) {return ColorF(R / 255.0,G / 255.0,B / 255.0);}