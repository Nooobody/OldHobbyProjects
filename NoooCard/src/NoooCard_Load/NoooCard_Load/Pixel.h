struct Color {
	float R;
	float G;
	float B;
	Color(float r,float g,float b) {
		R = r;
		G = g;
		B = b;
	}
	Color() {
		R = 255;
		G = 255;
		B = 255;
	}
};

struct Velocity {
	double X;
	double Y;
	Velocity() {
		X = 0;
		Y = 0;
	}
	Velocity(double x,double y) {
		X = x;
		Y = y;
	}
};

class Pixel {
public:
	Wnd* m_pWnd;
	UINT Lifetime;
	UINT StartTime;
	double Alpha;
	UINT X;
	UINT Y;
	Color Col;
	Color EndCol;
	Velocity Vel;

	double HalfX;
	double HalfY;
	Pixel() {
		X = 0;
		Y = 0;
		Col = Color();
		EndCol = Color();
		Vel.X = 0;
		Vel.Y = 0;
		HalfX = 0;
		HalfY = 0;
		Lifetime = 0;
		StartTime = 0;
		m_pWnd = NULL;
		Alpha = 255;
	}

	Pixel(UINT x,UINT y,Color col,Color Endcol,Velocity vel,float lifetime,Wnd* wnd) {
		X = x;
		Y = y;
		Col = col;
		EndCol = Endcol;
		Vel = vel;
		Lifetime = lifetime * CLOCKS_PER_SEC;
		m_pWnd = wnd;
		HalfX = 0;
		HalfY = 0;
		StartTime = clock();
		Alpha = 255;
	}

	int HalfPixel(double,double*);
	void Tick();
	void Die();
	void InterpolateCol();
};