
function LoadTib()
	if not file.Exists("Tiberium_Refinery.txt","DATA") then return end
	
	local Str = file.Read("Tiberium_Refinery.txt","DATA")
	local Tab = ReturnTableFromStr(Str)
	TIB_REF.RawTiberium = Tab.RawTiberium
	TIB_REF.Tiberium = Tab.Tiberium
	DB_UpdateRefinery()
	
	timer.Create("SA_TibRefinery",300,0,function()
		if tonumber(TIB_REF.RawTiberium) > 0 then
			local Val = math.random(1000,6000)
			TIB_REF.Tiberium = TIB_REF.Tiberium + math.min(Val,TIB_REF.RawTiberium)
			TIB_REF.RawTiberium = TIB_REF.RawTiberium - math.min(math.Round(Val * 1.5),TIB_REF.RawTiberium)
			DB_UpdateRefinery()
		end
	end)
end

function SaveTib()
	local Str = CreateStringFromTab(TIB_REF)
	file.Write("Tiberium_Refinery.txt",Str)
	DB_UpdateRefinery()
end

