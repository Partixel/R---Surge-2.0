local Plr = game.Players.LocalPlayer

local TweenService = game:GetService( "TweenService" )

local Root, Neck, R6

Plr.CharacterAdded:Connect( function ( Char )
	
	Root, Neck = Char:WaitForChild( "HumanoidRootPart" ), Char:FindFirstChild( "Neck", true )
	
	while not Neck do
		
		wait( )
		
		Neck = Char:FindFirstChild( "Neck", true )
		
	end
	
	while not Char:FindFirstChildOfClass( "Humanoid" ) do
		
		wait( )
		
	end
	
	R6 = Char:FindFirstChildOfClass( "Humanoid" ).RigType == Enum.HumanoidRigType.R6
	
end )

local HeadRotRemote = game:GetService( "ReplicatedStorage" ):WaitForChild( "S2" ):WaitForChild( "HeadRot" )

HeadRotRemote.OnClientEvent:Connect( function ( Rotations )
	
	for _, Rot in ipairs( Rotations ) do
		
		local Neck = Rot[ 1 ].Character and Rot[ 1 ].Character:FindFirstChild( "Neck", true )
		
		if Neck then
			
			TweenService:Create( Neck, TweenInfo.new( 1/20, Enum.EasingStyle.Linear ), { C0 = Rot[ 2 ] } ):Play( )
			
		end
		
	end
	
end )

local Players = game:GetService( "Players" )

game:GetService("RunService").Stepped:Connect( function ( )
	
	if Root and Neck and workspace.CurrentCamera.CameraSubject and workspace.CurrentCamera.CameraSubject:IsA( "Humanoid" ) and workspace.CurrentCamera.CameraSubject.Parent == Plr.Character then
		
		local CameraDirection = Root.CFrame:toObjectSpace( workspace.CurrentCamera.CFrame ).lookVector.unit
		
		if R6 then
			
			Neck.C0 = CFrame.new(Neck.C0.p) * CFrame.Angles(0, -math.asin(CameraDirection.x), 0) * CFrame.Angles(-math.pi/2 + math.asin(CameraDirection.y), 0, math.pi)
			
		else
			
			Neck.C0 = CFrame.new(Neck.C0.p) * CFrame.Angles(math.asin(CameraDirection.y), -math.asin(CameraDirection.x), 0)
			
		end
		
	end
	
	for _, Plr in ipairs( Players:GetPlayers( ) ) do
		
		if Plr.Character and Plr.Character:FindFirstChild( "Head" ) then
			
			local Humanoid = Plr.Character:FindFirstChildOfClass( "Humanoid" )
			
			if Humanoid and Humanoid.Health ~= 0 then
				
				Plr.Character.Head.CanCollide = false
				
			end
			
		end
		
	end

end )

local Last

while wait( 1/20 ) do
	
	if Neck and Last ~= Neck.C0 then
		
		HeadRotRemote:FireServer( Neck.C0 )
		
		Last = Neck.C0
		
	end
	
end