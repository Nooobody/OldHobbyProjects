
hook.Add("InitPostEntity","Hoverdrive_Changes",function()
	local HovDrive = scripted_ents.Get("gmod_wire_hoverdrivecontroler")
	baseclass.Set("gmod_wire_hoverdrivecontroler",baseclass.Get("base_sa_object"))
	HovDrive.Base = "base_sa_object"
	HovDrive.BaseClass = scripted_ents.Get("base_sa_object")

	function HovDrive:Setup(UseSounds, UseEffects)
		self.UseSounds = UseSounds
		self.UseEffects = UseEffects
		self:ShowOutput()
		if self:GetPlayer():GetResearch("Teleportation") == 0 then
			self:GetPlayer():SendLua("notification.AddLegacy('You do not have the technology required for that!',NOTIFY_ERROR,5)")
			self:Remove()
			return
		end
		self.LastJump = CurTime()
	end
	
	function HovDrive:Initialize()
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )

		local phys = self:GetPhysicsObject()

		self.Cooldown = 5
		self.Jumping = false
		self.TargetPos = self:GetPos()
		self.TargetAng = self:GetAngles()
		self.Entities = {}
		self.LocalPos = {}
		self.LocalAng = {}
		self.LocalVel = {}
		self.UseSounds = true
		self.UseEffects = true
		self.LastJump = CurTime()

		self.ClassSpecificActions = {
			gmod_wire_hoverball = function( ent, oldpos, newpos ) ent:SetTargetZ( newpos.z ) end,
			gmod_toggleablehoverball = function( ent, oldpos, newpos ) ent:SetTargetZ( newpos.z ) end,
			gmod_hoverball = function( ent, oldpos, newpos ) ent.dt.TargetZ = newpos.z end,
		}

		self:ShowOutput()
		
		self:Int()
		self.Class = "Wire"
		self.SubClass = "Hoverdrive"
		self.RInputs.Energy = math.pow(2,8)
		
		self.Inputs = Wire_CreateInputs( self, { "Jump", "TargetPos [VECTOR]", "X", "Y", "Z", "TargetAngle [ANGLE]", "Sound" })
	end

	function HovDrive:Int()
		self.BaseClass.Int(self)
	end
	
	function HovDrive:Use()
	end
	
	function HovDrive:Think()
		self.BaseClass.Think(self)
	end
	
	function HovDrive:CheckForInput()
		return self.BaseClass.CheckForInput(self)
	end
	
	function HovDrive:On()
		self.BaseClass.On(self)
	end
	
	function HovDrive:Off()
		self.BaseClass.Off(self)
	end
	
	function HovDrive:Link(Ent)
		self.BaseClass.Link(self,Ent)
	end
	
	function HovDrive:Unlink(Ent)
		self.BaseClass.Unlink(self,Ent)
	end
	
	function HovDrive:OnRemove()
		self.BaseClass.OnRemove(self)
	end
	
	function HovDrive:Jump( withangles )
		--------------------------------------------------------------------
		-- Check for errors
		--------------------------------------------------------------------

		-- Is already teleporting
		if (self.Jumping) then
			return
		end

		-- The target position is outside the world
		if (!util.IsInWorld( self.TargetPos )) then
			self:EmitSound("buttons/button8.wav")
			return
		end

		-- The position or angle hasn't changed
		if (self:GetPos() == self.TargetPos and self:GetAngles() == self.TargetAng) then
			self:EmitSound("buttons/button8.wav")
			return
		end
		
		if self:GetNWEntity("Owner"):GetNWBool("AFK") then
			if not self.JustOnce then
				self.JustOnce = true
			else return false end
		elseif self.JustOnce then self.JustOnce = nil end
		
		--------------------------------------------------------------------
		-- Find other entities
		--------------------------------------------------------------------

		-- Get the localized positions
		local ents = constraint.GetAllConstrainedEntities( self )

		-- Check world
		self.Entities = {}
		self.OtherEntities = {}
		for _, ent in pairs( ents ) do

			-- Calculate the position after teleport, without actually moving the entity
			local pos = self:WorldToLocal( ent:GetPos() )
			pos:Rotate( self.TargetAng )
			pos = pos + self.TargetPos

			local b = util.IsInWorld( pos )
			if not b then -- If an entity will be outside the world after teleporting..
				self:EmitSound("buttons/button8.wav")
				return
			elseif ent ~= self then -- if the entity is not equal to self
				if self:CheckAllowed( ent ) then -- If the entity can be teleported
					self.Entities[#self.Entities+1] = ent
				else -- If the entity can't be teleported
					self.OtherEntities[#self.OtherEntities+1] = ent
				end


			end
		end

		if CurTime() < self.LastJump + self.Cooldown then return end
		/*
		local Ents = constraint.GetAllConstrainedEntities(self)
		for I,P in pairs(Ents) do
			if P:GetClass() == "sa_port" and P.Terminal then
				constraint.RemoveAll(P)
				ChatIt("Your hoverdrive was attached to a critical object, the constrain has been removed. Try jumping again.",self:GetNWEntity("Owner"))
				return
			end
		end*/
		
		local Dist = self:GetPos():Distance(self.TargetPos)
		self.RInputs.Energy = math.pow(2,8) + math.Round(math.pow(2,8) * (Dist / 1000))
		if not self:CheckForInput() then 
			self:EmitSound("buttons/button8.wav")
			return 
		end
		
		self:On()
		self:Think()
		self:Off()
		
		-- All error checking passed
		self.Jumping = true
		self.LastJump = CurTime()
		
		--------------------------------------------------------------------
		-- Sound and visual effects
		--------------------------------------------------------------------
		if self.UseSounds then self:EmitSound("ambient/levels/citadel/weapon_disintegrate2.wav") end -- Starting sound

		if self.UseEffects then
			-- Effect out
			local effectdata = EffectData()
			effectdata:SetEntity( self )
			local Dir = (self.TargetPos - self:GetPos())
			Dir:Normalize()
			effectdata:SetOrigin( self:GetPos() + Dir * math.Clamp( self:BoundingRadius() * 5, 180, 4092 ) )
			util.Effect( "jump_out", effectdata, true, true )

			DoPropSpawnedEffect( self )

			for _, ent in pairs( ents ) do
				-- Effect out
				local effectdata = EffectData()
				effectdata:SetEntity( ent )
				effectdata:SetOrigin( self:GetPos() + Dir * math.Clamp( ent:BoundingRadius() * 5, 180, 4092 ) )
				util.Effect( "jump_out", effectdata, true, true )
			end
		end

		-- Call the next stage after a short time. This small delay is necessary for sounds and effects to work properly.
		timer.Simple( 0.05, function() self:Jump_Part2( withangles ) end )
	end
	
	scripted_ents.Register(HovDrive,"gmod_wire_hoverdrivecontroler")
end)