class Spawner {
public:
	UINT X;
	UINT Y;
	Wnd* pWnd;
	UINT Int;
	Color Col;
	float Hue;
	bool Rainbow;
	float Spd;
	void Spawn();
	string Serialize();
	Color GetColor();
	Spawner(UINT x,UINT y,Color col,Wnd* pwnd) {
		X = x;
		Y = y;
		Col = col;
		pWnd = pwnd;
		Int = 0;
		Rainbow = false;
		Hue = 0;
		Spd = 0;
	}
	Spawner(UINT x,UINT y,UINT I,float spd,Wnd* pwnd) {
		X = x;
		Y = y;
		Col = Color();
		pWnd = pwnd;
		Int = 0;
		Rainbow = true;
		Hue = I;
		Spd = spd;
	}
};