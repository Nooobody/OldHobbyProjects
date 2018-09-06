
function draw.DrawTransBox(x,y,w,h,col1)
	col1 = col1 or Color(0,255,0)
	
	surface.SetDrawColor(col1)
	surface.DrawOutlinedRect(x,y,w,h)
	surface.DrawOutlinedRect(x + 1,y + 1,w - 2,h - 2)
	surface.DrawOutlinedRect(x + 2,y + 2,w - 4,h - 4)
end

function draw.DrawBox(x,y,w,h,col1,col2)
	col1 = col1 or Color(0,255,0)
	col2 = col2 or Color(0,0,0)
	
	surface.SetDrawColor(col1)
	surface.DrawRect(x,y,w,h)
	surface.SetDrawColor(col2)
	surface.DrawRect(x + 3,y + 3,w - 6,h - 6)
end

function draw.DrawBoxTitle(x,y,w,h,str,col1,col2)
	draw.DrawBox(x,y,w,h,col1,col2)
	draw.DrawText(str,"Futuristic",w / 2,40,col1,TEXT_ALIGN_CENTER)
end

function draw.DrawCross(x,y,w,h,Col)
	Col = Col or Color(255,255,255)
	
	surface.SetDrawColor(Col)
	surface.DrawLine(x,y,x + w,y + h)
	surface.DrawLine(x,y + h - 1,x + w,y - 1)
	surface.DrawLine(x - 1,y,x + w - 1,y + h)
	surface.DrawLine(x - 1,y + h - 1,x + w - 1,y - 1)
	surface.DrawLine(x + 1,y,x + w + 1,y + h)
	surface.DrawLine(x + 1,y + h - 1,x + w + 1,y - 1)
end