class Pixel {
public:
	UINT Pos[2];
	bool Alive;
	Wnd* m_pWnd;
	Pixel() {
		Pos[0] = -1;
		Pos[1] = -1;
		Alive = false;
		m_pWnd = 0;
	}
	UINT CheckNeighbors();
	bool FindBox(UINT,UINT);
	bool FindAliveBox(UINT,UINT);
	void Tick();
	bool AliveCheck();
	string Serialize();
};