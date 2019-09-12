local ReplicatedStorage = game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" )

local Core = require( game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "Core" ) )

local PoseUtil = require( game:GetService( "Players" ).LocalPlayer:WaitForChild( "PlayerScripts" ):WaitForChild( "S2" ):WaitForChild( "PoseUtil" ) )

local KeybindUtil = require( game:GetService( "Players" ).LocalPlayer:WaitForChild( "PlayerScripts" ):WaitForChild( "S2" ):WaitForChild( "KeybindUtil" ) )
	
return function ( Main, ModFolder, VH_Events )
	
	Core.Config.AllowSprinting = ReplicatedStorage:WaitForChild( "Sprint" ).Value
	
	Core.Config.AllowCrouching = ReplicatedStorage:WaitForChild( "Crouch" ).Value
	
	Core.Config.AllowAtEase = ReplicatedStorage:WaitForChild( "AtEase" ).Value
	
	Core.Config.AllowSalute = ReplicatedStorage:WaitForChild( "Salute" ).Value
	
	Core.Config.AllowCharacterRotation = ReplicatedStorage:WaitForChild( "CharacterRotation" ).Value
	
	Core.Config.AllowSurrender = ReplicatedStorage:WaitForChild( "Surrender" ).Value
	
	Core.Config.AllowTeamKill = ReplicatedStorage:WaitForChild( "TeamKill" ).Value
	
	Main.Events[ #Main.Events + 1 ] = ReplicatedStorage.Sprint.Changed:Connect( function( Value )
		
		Core.Config.AllowSprinting = Value
		
		if not Value then
			
			PoseUtil.SetPose( "Sprinting", false )
			
		end
		
	end )
	
	Main.Events[ #Main.Events + 1 ] = ReplicatedStorage.Crouch.Changed:Connect( function( Value )
		
		Core.Config.AllowCrouching = Value
		
		if not Value then
			
			PoseUtil.SetPose( "Crouching", false )
			
		end
		
	end )
	
	Main.Events[ #Main.Events + 1 ] = ReplicatedStorage.AtEase.Changed:Connect( function( Value )
		
		Core.Config.AllowAtEase = Value
		
		if not Value then
			
			KeybindUtil.SetToggle( "At_ease", false )
			
		end
		
	end )
	
	Main.Events[ #Main.Events + 1 ] = ReplicatedStorage.Surrender.Changed:Connect( function( Value )
		
		Core.Config.AllowSurrender = Value
		
		if not Value then
			
			KeybindUtil.SetToggle( "Surrender", false )
			
		end
		
	end )
	
	Main.Events[ #Main.Events + 1 ] = ReplicatedStorage.TeamKill.Changed:Connect( function( Value )
		
		Core.Config.AllowTeamKill = Value
		
	end )
	
	Main.Events[ #Main.Events + 1 ] = ReplicatedStorage.CharacterRotation.Changed:Connect( function( Value )
		
		Core.Config.AllowCharacterRotation = Value
		
	end )
	
	Main.Events[ #Main.Events + 1 ] = ReplicatedStorage.Salute.Changed:Connect( function( Value )
		
		Core.Config.AllowSalute = Value
		
		if not Value then
			
			KeybindUtil.SetToggle( "Salute", false )
			
		end
		
	end )

end