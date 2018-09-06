#pragma once
#include "Wnd.h"

class Null_Func : public FuncMain {
public:
	Null_Func() {}
	void operator() () {}
};

class Exit_Func : public FuncMain {
private:
	Wnd* pWnd;
public:
	Exit_Func(Wnd* pW) : pWnd(pW) {}
	void operator() () {
		pWnd->Exit = true;
	}
};

class Generate_Func : public FuncMain {
private:
	Maze* pMaze;
public:
	Generate_Func(Maze* pM) : pMaze(pM) {}
	void operator() () {
		pMaze->pWnd->GenerateToggle = !pMaze->pWnd->GenerateToggle;
	}
};

class Solve_Func : public FuncMain {
private:
	Maze* pMaze;
public:
	Solve_Func(Maze* pM) : pMaze(pM) {}
	void operator() () {
		if (pMaze->Points.size() > 1) {
			pMaze->Path.clear();
			pMaze->OpenNodes.clear();
			pMaze->ClosedNodes.clear();
			pMaze->pWnd->MazeMouseAction = true;
		}
	}
};

class Reset_Func : public FuncMain {
private:
	Maze* pMaze;
public:
	Reset_Func(Maze* pM) : pMaze(pM) {}
	void operator() () {
		pMaze->pWnd->GenerateToggle = false;
		for (UINT I = 0;I < pMaze->Branches.size();I++) {
			pMaze->Branches[I]->Points.clear();
		}
		pMaze->OpenNodes.clear();
		pMaze->ClosedNodes.clear();
		pMaze->Branches.clear();
		pMaze->Points.clear();
		Point* Poi = new Point(Vec2(20 - 20 % POINTSIZE,20 - 20 % POINTSIZE));
		pMaze->Branches.push_back(new Branch(Poi));
		pMaze->Points.push_back(Poi);
		pMaze->Path.clear();
	}
};

class Toggle_Func : public FuncMain {
private:
	Maze* pMaze;
public:
	Toggle_Func(Maze* pM) : pMaze(pM) {}
	void operator() () {
		pMaze->NodeToggle = !pMaze->NodeToggle;
	}
};