AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
   Desc: First function called. Use to set up your entity
---------------------------------------------------------*/
function ENT:Initialize()
	self.Entity:SetModel("models/combine_helicopter/helicopter_bomb01.mdl")
	self.Entity:SetCollisionGroup( COLLISION_GROUP_NONE )
	self.Entity:DrawShadow( false )
	self.Entity:SetMoveType( MOVETYPE_NONE )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_NONE )         -- Toolbox
	timer.Simple(0,function() self.Entity:SetModel(self.Mdl) end)
end

/*---------------------------------------------------------
   Name: Think
   Desc: Entity's think function. 
---------------------------------------------------------*/
function ENT:Think()
end