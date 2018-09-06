#include "Maze.h"
#include "Wnd.h"

bool Maze::IsPoint(Vec2 P) {
	if (P.X < 0 || P.X >= pWnd->Width || P.Y < 0 || P.Y >= pWnd->Height) return true;
	for (UINT I = 0;I < Points.size();I++) {
		if (P == Points[I]->Pos) return true;
	}
	return false;
}

bool Maze::IsPathPoint(Vec2 P) {
	for (UINT I = 0;I < Points.size();I++) {
		if (P == Points[I]->Pos) return true;
	}
	return false;
}

bool Maze::IsOpenPoint(Vec2 P) {
	for (UINT I = 0;I < OpenNodes.size();I++) {
		if (OpenNodes[I]->Pos == P) return true;
	}
	return false;
}

bool Maze::IsBranchPoint(Vec2 P) {
	for (UINT I = 0;I < ClosedNodes.size();I++) {
		if (ClosedNodes[I]->Pos == P) return true;
	}
	return false;
}

unsigned short Maze::GetDist(Vec2 P1,Vec2 P2) {
	return sqrt(pow(P2.X - P1.X,2.0) + pow(P2.Y - P1.Y,2.0));
}

void Maze::Solve(Vec2 Target) {
	PathNode* Beg = new PathNode(Points[0]->Pos,Points[0]->Pos,0,GetDist(Points[0]->Pos,Target));
	OpenNodes.push_back(Beg);
	unsigned char I = 0;
	if (IsPathPoint(OpenNodes[0]->Pos + Vec2(POINTSIZE,0)) && !IsBranchPoint(OpenNodes[0]->Pos + Vec2(POINTSIZE,0)) && !IsOpenPoint(OpenNodes[0]->Pos + Vec2(POINTSIZE,0))) OpenNodes.push_back(new PathNode(OpenNodes[0]->Pos + Vec2(POINTSIZE,0),OpenNodes[0]->Pos,OpenNodes[0]->DistBeg + POINTSIZE,GetDist(OpenNodes[0]->Pos + Vec2(POINTSIZE,0),Target)));
	if (IsPathPoint(OpenNodes[0]->Pos + Vec2(0,POINTSIZE)) && !IsBranchPoint(OpenNodes[0]->Pos + Vec2(0,POINTSIZE)) && !IsOpenPoint(OpenNodes[0]->Pos + Vec2(0,POINTSIZE))) OpenNodes.push_back(new PathNode(OpenNodes[0]->Pos + Vec2(0,POINTSIZE),OpenNodes[0]->Pos,OpenNodes[0]->DistBeg + POINTSIZE,GetDist(OpenNodes[0]->Pos + Vec2(0,POINTSIZE),Target)));
	if (IsPathPoint(OpenNodes[0]->Pos + Vec2(-POINTSIZE,0)) && !IsBranchPoint(OpenNodes[0]->Pos + Vec2(-POINTSIZE,0)) && !IsOpenPoint(OpenNodes[0]->Pos + Vec2(-POINTSIZE,0))) OpenNodes.push_back(new PathNode(OpenNodes[0]->Pos + Vec2(-POINTSIZE,0),OpenNodes[0]->Pos,OpenNodes[0]->DistBeg + POINTSIZE,GetDist(OpenNodes[0]->Pos + Vec2(-POINTSIZE,0),Target)));
	if (IsPathPoint(OpenNodes[0]->Pos + Vec2(0,-POINTSIZE)) && !IsBranchPoint(OpenNodes[0]->Pos + Vec2(0,-POINTSIZE)) && !IsOpenPoint(OpenNodes[0]->Pos + Vec2(0,-POINTSIZE))) OpenNodes.push_back(new PathNode(OpenNodes[0]->Pos + Vec2(0,-POINTSIZE),OpenNodes[0]->Pos,OpenNodes[0]->DistBeg + POINTSIZE,GetDist(OpenNodes[0]->Pos + Vec2(0,-POINTSIZE),Target)));
	ClosedNodes.push_back(OpenNodes[0]);
	OpenNodes.erase(OpenNodes.begin());
	for (unsigned char A = 1;A < OpenNodes.size();A++) {
		if (OpenNodes[0]->DistBeg + OpenNodes[0]->DistTar > OpenNodes[A]->DistBeg + OpenNodes[A]->DistTar) {
			PathNode* Temp = OpenNodes[0];
			OpenNodes[0] = OpenNodes[A];
			OpenNodes[A] = Temp;
		}
	}
	bool Found = false;
	while (!Found) {
		if (OpenNodes.size() == 0) break;
		PathNode* Closest = OpenNodes[0];
		OpenNodes.erase(OpenNodes.begin());
		if (IsPathPoint(Closest->Pos + Vec2(POINTSIZE,0)) && !IsBranchPoint(Closest->Pos + Vec2(POINTSIZE,0))) {
			if (!IsOpenPoint(Closest->Pos + Vec2(POINTSIZE,0))) {
				OpenNodes.push_back(new PathNode(Closest->Pos + Vec2(POINTSIZE,0),Closest->Pos,Closest->DistBeg + POINTSIZE,GetDist(Closest->Pos + Vec2(POINTSIZE,0),Target)));
				bool PlaceFound = false;
				unsigned short Place = OpenNodes.size() - 1;
				while (!PlaceFound) {
					if (OpenNodes[Place]->DistBeg + OpenNodes[Place]->DistTar < OpenNodes[floor(Place / 2.0)]->DistBeg + OpenNodes[floor(Place / 2.0)]->DistTar) {
						PathNode* Temp = OpenNodes[Place];
						OpenNodes[Place] = OpenNodes[floor(Place / 2.0)];
						OpenNodes[floor(Place / 2.0)] = Temp;
					}
					else PlaceFound = true;
				}
			}
			else {
				for (UINT Y = 0;Y < OpenNodes.size();Y++) {
					if (OpenNodes[Y]->Pos == Closest->Pos + Vec2(POINTSIZE,0)) {
						if (OpenNodes[Y]->DistBeg > Closest->DistBeg) {
							OpenNodes[Y]->Parent = Closest->Pos;
							OpenNodes[Y]->DistBeg = Closest->DistBeg + POINTSIZE;
						}
						break;
					}
				}
			}
		}
		if (IsPathPoint(Closest->Pos + Vec2(0,POINTSIZE)) && !IsBranchPoint(Closest->Pos + Vec2(0,POINTSIZE))) {
			if (!IsOpenPoint(Closest->Pos + Vec2(0,POINTSIZE))) {
				OpenNodes.push_back(new PathNode(Closest->Pos + Vec2(0,POINTSIZE),Closest->Pos,Closest->DistBeg + POINTSIZE,GetDist(Closest->Pos + Vec2(0,POINTSIZE),Target)));
				bool PlaceFound = false;
				unsigned short Place = OpenNodes.size() - 1;
				while (!PlaceFound) {
					if (OpenNodes[Place]->DistBeg + OpenNodes[Place]->DistTar < OpenNodes[floor(Place / 2.0)]->DistBeg + OpenNodes[floor(Place / 2.0)]->DistTar) {
						PathNode* Temp = OpenNodes[Place];
						OpenNodes[Place] = OpenNodes[floor(Place / 2.0)];
						OpenNodes[floor(Place / 2.0)] = Temp;
					}
					else PlaceFound = true;
				}
			}
			else {
				for (UINT Y = 0;Y < OpenNodes.size();Y++) {
					if (OpenNodes[Y]->Pos == Closest->Pos + Vec2(0,POINTSIZE)) {
						if (OpenNodes[Y]->DistBeg > Closest->DistBeg) {
							OpenNodes[Y]->Parent = Closest->Pos;
							OpenNodes[Y]->DistBeg = Closest->DistBeg + POINTSIZE;
						}
						break;
					}
				}
			}
		}
		if (IsPathPoint(Closest->Pos + Vec2(-POINTSIZE,0)) && !IsBranchPoint(Closest->Pos + Vec2(-POINTSIZE,0))) {
			if (!IsOpenPoint(Closest->Pos + Vec2(-POINTSIZE,0))) {
				OpenNodes.push_back(new PathNode(Closest->Pos + Vec2(-POINTSIZE,0),Closest->Pos,Closest->DistBeg + POINTSIZE,GetDist(Closest->Pos + Vec2(-POINTSIZE,0),Target)));
				bool PlaceFound = false;
				unsigned short Place = OpenNodes.size() - 1;
				while (!PlaceFound) {
					if (OpenNodes[Place]->DistBeg + OpenNodes[Place]->DistTar < OpenNodes[floor(Place / 2.0)]->DistBeg + OpenNodes[floor(Place / 2.0)]->DistTar) {
						PathNode* Temp = OpenNodes[Place];
						OpenNodes[Place] = OpenNodes[floor(Place / 2.0)];
						OpenNodes[floor(Place / 2.0)] = Temp;
					}
					else PlaceFound = true;
				}
			}
			else {
				for (UINT Y = 0;Y < OpenNodes.size();Y++) {
					if (OpenNodes[Y]->Pos == Closest->Pos + Vec2(-POINTSIZE,0)) {
						if (OpenNodes[Y]->DistBeg > Closest->DistBeg) {
							OpenNodes[Y]->Parent = Closest->Pos;
							OpenNodes[Y]->DistBeg = Closest->DistBeg + POINTSIZE;
						}
						break;
					}
				}
			}
		}
		if (IsPathPoint(Closest->Pos + Vec2(0,-POINTSIZE)) && !IsBranchPoint(Closest->Pos + Vec2(0,-POINTSIZE))) {
			if (!IsOpenPoint(Closest->Pos + Vec2(0,-POINTSIZE))) {
				OpenNodes.push_back(new PathNode(Closest->Pos + Vec2(0,-POINTSIZE),Closest->Pos,Closest->DistBeg + POINTSIZE,GetDist(Closest->Pos + Vec2(0,-POINTSIZE),Target)));
				bool PlaceFound = false;
				unsigned short Place = OpenNodes.size() - 1;
				while (!PlaceFound) {
					if (OpenNodes[Place]->DistBeg + OpenNodes[Place]->DistTar < OpenNodes[floor(Place / 2.0)]->DistBeg + OpenNodes[floor(Place / 2.0)]->DistTar) {
						PathNode* Temp = OpenNodes[Place];
						OpenNodes[Place] = OpenNodes[floor(Place / 2.0)];
						OpenNodes[floor(Place / 2.0)] = Temp;
					}
					else PlaceFound = true;
				}
			}
			else {
				for (UINT Y = 0;Y < OpenNodes.size();Y++) {
					if (OpenNodes[Y]->Pos == Closest->Pos + Vec2(0,-POINTSIZE)) {
						if (OpenNodes[Y]->DistBeg > Closest->DistBeg) {
							OpenNodes[Y]->Parent = Closest->Pos;
							OpenNodes[Y]->DistBeg = Closest->DistBeg + POINTSIZE;
						}
						break;
					}
				}
			}
		}
		ClosedNodes.push_back(Closest);
		if (Closest->Pos == Target) Found = true;
		I++;
	}
	if (Found) {
		PathNode* Tar = ClosedNodes[ClosedNodes.size() - 1];
		Path.push_back(Tar->Pos);
		while (Path[Path.size() - 1] != Points[0]->Pos) {
			Path.push_back(Tar->Parent);
			for (UINT I = 0;I < ClosedNodes.size();I++) {
				if (ClosedNodes[I]->Pos == Tar->Parent) {
					Tar = ClosedNodes[I];
					break;
				}
			}
		}
	}
}

void Maze::Paint() {
	for (UINT I = 0;I < Points.size();I++) {
		pWnd->SetColor(GetCol(255,255,255));
		if (!Points[I]->Sides[UP]) {
			pWnd->m_pRT->DrawRectangle(GetRect(Points[I]->Pos - Vec2(POINTSIZE / 2,POINTSIZE / 2),Vec2(0,0)),pWnd->m_pBrush);
			pWnd->m_pRT->DrawLine(Point2F(Points[I]->Pos.X - POINTSIZE / 2,Points[I]->Pos.Y - POINTSIZE / 2),Point2F(Points[I]->Pos.X + POINTSIZE / 2,Points[I]->Pos.Y - POINTSIZE / 2),pWnd->m_pBrush);
		}
		if (!Points[I]->Sides[LEFT]) {
			pWnd->m_pRT->DrawRectangle(GetRect(Points[I]->Pos - Vec2(POINTSIZE / 2,POINTSIZE / 2),Vec2(0,0)),pWnd->m_pBrush);
			pWnd->m_pRT->DrawLine(Point2F(Points[I]->Pos.X - POINTSIZE / 2,Points[I]->Pos.Y - POINTSIZE / 2),Point2F(Points[I]->Pos.X - POINTSIZE / 2,Points[I]->Pos.Y + POINTSIZE / 2),pWnd->m_pBrush);
		}
		if (!Points[I]->Sides[RIGHT]) {
			pWnd->m_pRT->DrawLine(Point2F(Points[I]->Pos.X + POINTSIZE / 2,Points[I]->Pos.Y + POINTSIZE / 2),Point2F(Points[I]->Pos.X + POINTSIZE / 2,Points[I]->Pos.Y - POINTSIZE / 2),pWnd->m_pBrush);
		}
		if (!Points[I]->Sides[DOWN]) {
			pWnd->m_pRT->DrawLine(Point2F(Points[I]->Pos.X + POINTSIZE / 2,Points[I]->Pos.Y + POINTSIZE / 2),Point2F(Points[I]->Pos.X - POINTSIZE / 2,Points[I]->Pos.Y + POINTSIZE / 2),pWnd->m_pBrush);
		}
	}
	pWnd->SetColor(GetCol(255,0,0));
	for (UINT I = 1;I < Path.size();I++) {
		pWnd->m_pRT->DrawLine(Point2F(Path[I].X,Path[I].Y),Point2F(Path[I - 1].X,Path[I - 1].Y),pWnd->m_pBrush);
	}
	if (NodeToggle) {
		for (UINT I = 0;I < ClosedNodes.size();I++) {
			pWnd->m_pRT->DrawRectangle(GetRect(ClosedNodes[I]->Pos - Vec2(2,2),Vec2(4,4)),pWnd->m_pBrush);
		}
	}
}

void Maze::Generate() {
	vector<unsigned char> Removables;
	for (unsigned char X = 0;X < Branches.size();X++) {
		if (Branches[X]->Running) {
			Vec2 P = Branches[X]->Points[Branches[X]->Points.size() - 1]->Pos;
			bool Found = false;
			vector<unsigned char> Dirs;
			Dirs.push_back(UP);
			Dirs.push_back(RIGHT);
			Dirs.push_back(DOWN);
			Dirs.push_back(LEFT);
			while (!Found) {
				unsigned char R = rand() % Dirs.size();
				Vec2 RP;
				if (Dirs[R] == UP) RP = Vec2(0,-POINTSIZE);
				else if (Dirs[R] == RIGHT) RP = Vec2(POINTSIZE,0);
				else if (Dirs[R] == DOWN) RP = Vec2(0,POINTSIZE);
				else if (Dirs[R] == LEFT) RP = Vec2(-POINTSIZE,0);
				if (!IsPoint(P + RP)) {
					unsigned char Sides = 0;	
					if (IsPoint(P + RP + Vec2(0,POINTSIZE))) Sides++;
					if (IsPoint(P + RP + Vec2(POINTSIZE,0))) Sides++;
					if (IsPoint(P + RP + Vec2(-POINTSIZE,0))) Sides++;
					if (IsPoint(P + RP + Vec2(0,-POINTSIZE))) Sides++;
					if (Sides == 1) {
						Point* Poi = new Point(P + RP);
						Points.push_back(Poi);
						Branches[X]->Points.push_back(Poi);
						Found = true;
					}
					else {
						Dirs.erase(Dirs.begin() + R);
						if (Dirs.size() == 0) {
							Branches[X]->Running = false;
							Removables.push_back(X);
							break;
						}
					}
				}
				else {
					Dirs.erase(Dirs.begin() + R);
					if (Dirs.size() == 0) {
						Branches[X]->Running = false;
						Removables.push_back(X);
						break;
					}
				}
			}
			if (Branches[X]->Points.size() % 10 == 0) {
				vector<unsigned char> Dirs;
				Dirs.push_back(UP);
				Dirs.push_back(RIGHT);
				Dirs.push_back(DOWN);
				Dirs.push_back(LEFT);
				Found = false;
				while (!Found) {
					unsigned char R = rand() % Dirs.size();
					Vec2 RP;
					if (Dirs[R] == UP) RP = Vec2(0,-POINTSIZE);
					else if (Dirs[R] == RIGHT) RP = Vec2(POINTSIZE,0);
					else if (Dirs[R] == DOWN) RP = Vec2(0,POINTSIZE);
					else if (Dirs[R] == LEFT) RP = Vec2(-POINTSIZE,0);
					if (!IsPoint(P + RP)) {
						Point* Poi = new Point(P + RP);
						Points.push_back(Poi);
						Branches.push_back(new Branch(Poi));
						Found = true;
					}
					else {
						Dirs.erase(Dirs.begin() + R);
						if (Dirs.size() == 0) break;
					}
				}
			}
		}
	}
	if (Removables.size() > 0) {
		for (signed char I = Removables.size() - 1;I >= 0;I--) {
			Branches.erase(Branches.begin() + Removables[I]);
		}
	}
	for (UINT I = 0;I < Points.size();I++) {
		if (!Points[I]->Sides[UP] && IsPoint(Points[I]->Pos - Vec2(0,POINTSIZE))) Points[I]->Sides[UP] = true;
		if (!Points[I]->Sides[RIGHT] && IsPoint(Points[I]->Pos + Vec2(POINTSIZE,0))) Points[I]->Sides[RIGHT] = true;
		if (!Points[I]->Sides[DOWN] && IsPoint(Points[I]->Pos + Vec2(0,POINTSIZE))) Points[I]->Sides[DOWN] = true;
		if (!Points[I]->Sides[LEFT] && IsPoint(Points[I]->Pos - Vec2(POINTSIZE,0))) Points[I]->Sides[LEFT] = true;
	}
}