#pragma once
#include "Includes.h"

struct Point {
	Vec2 Pos;
	bool Sides[5];
	Point(Vec2 P) {
		Pos = P;
		Sides[UP] = false;
		Sides[RIGHT] = false;
		Sides[DOWN] = false;
		Sides[LEFT] = false;
	}
	~Point() {
		delete this;
	}
};

struct PathNode {
	Vec2 Pos;
	Vec2 Parent;
	unsigned short DistBeg;
	unsigned short DistTar;
	PathNode(Vec2 P,Vec2 Par,unsigned short DBeg,unsigned short DTar) : Pos(P),Parent(Par),DistBeg(DBeg),DistTar(DTar) {}
};

struct Branch {
	vector<Point*> Points;
	bool Running;
	Branch(Vec2 P) {
		Running = true;
		Points.push_back(new Point(P));
	}
	Branch(Point* P) {
		Running = true;
		Points.push_back(P);
	}
};

class Maze {
public:
	Maze(Wnd* pW) : pWnd(pW) {
		Point* Poi = new Point(Vec2(20 - 20 % POINTSIZE,20 - 20 % POINTSIZE));
		Branches.push_back(new Branch(Poi));
		Points.push_back(Poi);
		NodeToggle = true;
	}
	Wnd* pWnd;
	vector<Branch*> Branches;
	vector<Point*> Points;
	vector<Vec2> Path;
	vector<PathNode*> OpenNodes;
	vector<PathNode*> ClosedNodes;
	bool NodeToggle;
	
	unsigned short GetDist(Vec2,Vec2);
	bool IsPoint(Vec2);
	bool IsPathPoint(Vec2);
	bool IsOpenPoint(Vec2);
	bool IsBranchPoint(Vec2);
	void Solve(Vec2);
	void Paint();
	void Generate();
};