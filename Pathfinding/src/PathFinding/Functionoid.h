#pragma once

class FuncMain {
public:
	virtual void operator() () = 0;
	virtual ~FuncMain() = 0;
};

inline FuncMain::~FuncMain() {};