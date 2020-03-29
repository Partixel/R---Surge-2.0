local Plr = game:GetService( "Players" ).LocalPlayer

local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local KBU = require( Plr:WaitForChild( "PlayerScripts" ):WaitForChild( "S2" ):WaitForChild( "KeybindUtil" ) )

local PU = require( Plr:WaitForChild( "PlayerScripts" ):WaitForChild( "S2" ):WaitForChild( "PoseUtil" ) )

local TweenService = game:GetService( "TweenService" )

local FOVMod

local ActSprint

function UpdateCamera(Sprinting)
	if Core.ActualSprinting ~= Sprinting then
		local MySprint = {}
		ActSprint = MySprint
		
--		Core.PreventReload.Sprinting = Sprinting
--		if Sprinting then
--			local Weapon = Core.Selected[Plr] and next(Core.Selected[Plr])
--			if Weapon and Weapon.Reloading then
--				KBU.SetToggle("Sprint", false)
--				
--				return
--				
--				Weapon.Reloading = false
--			end
--		end
		
		Core.PreventCharacterRotation.Sprinting = Sprinting
		Core.ActualSprinting = Sprinting
		
		if not FOVMod or not FOVMod.Parent then
			FOVMod = Instance.new("NumberValue")
			FOVMod.Name = "FieldOfViewModifier"
			FOVMod.Value = 1
		end
		
		FOVMod.Parent = workspace.CurrentCamera
		
		if not Sprinting then
			wait(0.1)
			if MySprint ~= ActSprint then
				return
			end
		end
		
		TweenService:Create(FOVMod, TweenInfo.new(0.1), {Value = Sprinting and 80/75 or 1}):Play()
	end
end

function HandleChar( Char )
	
	local Hum = Char:WaitForChild( "Humanoid" )
	
	Hum:GetPropertyChangedSignal( "Sit" ):Connect( function ( )
		
		if Hum.Sit then
			
			UpdateCamera( )
		
		elseif PU.GetPose( "Sprinting" ) and Hum.MoveDirection.magnitude ~= 0 then
			
			UpdateCamera( true )
			
		else
			
			UpdateCamera( )
			
		end
		
	end )
	
	Hum:GetPropertyChangedSignal( "MoveDirection" ):Connect( function ( )
		
		if Hum.MoveDirection.magnitude == 0 then
			
			UpdateCamera( )
			
		elseif PU.GetPose( "Sprinting" ) and not Hum.Sit and Hum:GetState( ) ~= Enum.HumanoidStateType.Dead then
			
			UpdateCamera( true )
			
		else
			
			UpdateCamera( )
			
		end
		
	end )
	
end

HandleChar( Plr.Character or Plr.CharacterAdded:Wait( ) )

Plr.CharacterAdded:Connect( HandleChar )

local WSMod

PU.Watch( "Sprinting", "Sprint", function ( NPlr, State, Offset )
	
	if NPlr == Plr then
		
		local Hum = NPlr.Character and NPlr.Character:FindFirstChildOfClass( "Humanoid" )
		
		if Hum then
			
			if WSMod then WSMod:Destroy( ) end
			
			if State then
				
				WSMod = Instance.new( "NumberValue" )
				
				WSMod.Name = "WalkSpeedModifier"
				
				WSMod.Value = Core.Config.SprintSpeedMultiplier or 1.35
				
				WSMod.Parent = Hum
				
				if not Hum.Sit and Hum.MoveDirection.magnitude ~= 0 and Hum:GetState( ) ~= Enum.HumanoidStateType.Dead then
					
					UpdateCamera( true )
					
				else
					
					UpdateCamera( )
					
				end
				
			else
				
				WSMod = nil
				
				UpdateCamera( )
				
			end
			
		end
		
	end
	
end )

Core.PreventSprint = { }

local Debounce, Last

KBU.AddBind{ Name = "Sprint", Category = "Surge 2.0", Callback = function ( Began, Died )
	
	if Died then return end
	
	if Began and Debounce then return Last end
	
	Last = Began
	
	if Began then
		
		if next( Core.PreventSprint ) then return false end
		
		if Plr.Character and Plr.Character:FindFirstChildOfClass( "Humanoid" ) and Plr.Character:FindFirstChildOfClass( "Humanoid" ):GetState( ) ~= Enum.HumanoidStateType.Dead then
			
			local Weapon = Core.Selected[ Plr ] and next( Core.Selected[ Plr ] )
			
			if Core.Config.AllowSprinting == false and ( not Weapon or Weapon.PreventSprint ~= false ) then return false end
			
--			if Weapon and ( Weapon.PreventSprint or Weapon.Reloading ) then return false end
			
			if Weapon and Weapon.PreventSprint then return false end
			
			PU.SetPose( "Sprinting", true )
			
			PU.SetPose( "Crouching", false )
			
			PU.SetPose( "Scoping", false )
			
			Debounce = true
			
			wait( )
			
			Debounce = false
			
		end
		
	else
		
		Core.PreventCrouch.Sprinting = nil
		
		PU.SetPose( "Sprinting", false )
		
		Debounce = true
		
		wait( )
		
		Debounce = false
		
	end
	
end, Key = Enum.KeyCode.F, PadKey = Enum.KeyCode.ButtonL3, ToggleState = false, CanToggle = true, OffOnDeath = true, NoHandled = true }

--Core.Events.AntiSprintReload = Core.ReloadStart.Event:Connect( function ( StatObj )
--	
--	if Core.ActualSprinting then KBU.SetToggle( "Sprint", false ) end
--	
--end )

Core.Events.AntiSprintShoot = Core.WeaponTypes.RaycastGun.AttackEvent.Event:Connect( function ( _, User )
	
	if User == Plr and Core.ActualSprinting then KBU.SetToggle( "Sprint", false ) end
	
end )

Core.WeaponSelected.Event:Connect( function ( StatObj )
	
	if not StatObj then return end
	
	local WeaponStats = Core.GetWeaponStats( StatObj )
	
	if WeaponStats.PreventSprint or (Core.Config.AllowSprinting == false and WeaponStats.PreventSprint ~= false) then KBU.SetToggle( "Sprint", false ) end
	
end )

Core.WeaponDeselected.Event:Connect( function ( StatObj )
	
	if Core.Config.AllowSprinting == false then KBU.SetToggle( "Sprint", false ) end
	
end )