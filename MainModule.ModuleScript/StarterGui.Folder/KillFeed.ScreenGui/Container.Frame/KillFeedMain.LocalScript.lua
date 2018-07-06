local Players, TweenService = game:GetService( "Players" ), game:GetService("TweenService" )

local function Scale( Feed )
	
	Feed.Killer.Size = UDim2.new( 10, 0, 1, 0 )
	
	Feed.Killer.Size = UDim2.new( ( ( Feed.Killer.KillerName.TextBounds.X ~= 0 and Feed.Killer.KillerName.TextBounds.X + 10 or 0 ) + ( Feed.Killer:FindFirstChild( "KillerPct" ) and Feed.Killer.KillerPct.TextBounds.X + 5 or 0 ) ) / Feed.AbsoluteSize.X, 0, 1, 0 )
	
	if Feed.Killer:FindFirstChild( "Assister" ) then
		
		Feed.Killer.Assister.Size = UDim2.new( 10, 0, 0.5, 0 )
		
		Feed.Killer.Assister.Size = UDim2.new( ( ( Feed.Killer.Assister.AssisterName.TextBounds.X ~= 0 and Feed.Killer.Assister.AssisterName.TextBounds.X + 10 or 0 ) + ( Feed.Killer.Assister.AssisterPct.TextBounds.X ~= 0 and Feed.Killer.Assister.AssisterPct.TextBounds.X + 5 or 0 ) ) / Feed.Killer.AbsoluteSize.X, 0, 0.5, 0 )
		
		if Feed.Killer.AbsoluteSize.X < Feed.Killer.Assister.AbsoluteSize.X then
		
			Feed.Killer.Assister.Frame.Size = UDim2.new( Feed.Killer.AbsoluteSize.X / Feed.Killer.Assister.AbsoluteSize.X, 0, 1.5, 0 )
			
		else
			
			Feed.Killer.Assister.Frame.Size = UDim2.new( 1, 0, 1.5, 0 )
			
		end
		
	end
	
	local Max = 0
	
	local Kids = Feed:GetChildren( )
	
	for a = 1, #Kids do
		
		if Kids[ a ].Name:sub( 1, 6 ) == "Victim" then
	
			Kids[ a ].Size = UDim2.new( 10, 0, 1, 0 )
			
			Max = math.max( Max, ( Kids[ a ].VictimName.TextBounds.X ~= 0 and Kids[ a ].VictimName.TextBounds.X + 10 or 0 ) + ( Kids[ a ]:FindFirstChild( "VictimType" ) and Kids[ a ].VictimType.AbsoluteSize.X + 5 or 0 ) )
			
		end
		
	end
	
	for a = 1, #Kids do
		
		if Kids[ a ].Name:sub( 1, 6 ) == "Victim" then
			
			Kids[ a ].Size = UDim2.new( Max / Feed.AbsoluteSize.X, 0, 1, 0 )
			
		end
		
	end
	
end

workspace.CurrentCamera:GetPropertyChangedSignal( "ViewportSize" ):Connect( function ( )
	
	wait( )
	
	local Feeds = script.Parent:GetChildren( )
	
	for a = 1, #Feeds do
		
		if Feeds[ a ]:IsA( "Frame" ) then
			
			Scale( Feeds[ a ] )
			
		end
		
	end
	
end )

local function PctStr( Num, Decimals )
	-- Needs percentage as a value between 0 - 100 ( multiply the decimal by 100 )
	Decimals = Decimals or 0
	local Min = 0.1 ^ Decimals
	return string.format( "%." .. Decimals .. "f", Num > 0 and Num < Min and Min or Num > 100 - Min and Num < 100 and 100 - Min or Num )
end

local function ApplyTextStroke( Obj )
	
	local _, _, V = Color3.toHSV( Obj.TextColor3 )
	
	if V > 0.85 then
		
		Obj.TextStrokeColor3 = Color3.fromRGB( 77, 77, 77 )
		
	end
	
end


local VictimTypes = { Head = "rbxassetid://1693819171" }
-- Need suicide dmgtype
local DmgTypes = { Kinetic = "rbxassetid://1693831893", Explosive = "rbxassetid://1693825708" }

local Neutral = Color3.fromRGB( 77, 77, 77 )

local Zero = UDim2.new( 0, 0, 0, 0 )

game:GetService( "ReplicatedStorage" ):WaitForChild( "RemoteKilled" ).OnClientEvent:Connect( function ( DeathInfo )
	
	local NewFeed = script.Feed:Clone( )
	
	NewFeed.Type.Image = DmgTypes[ DeathInfo.Type ] or DmgTypes[ "Kinetic" ]
	
	local NumVictims = 0
	
	for a = 1, #DeathInfo.VictimInfos do
		
		if not DeathInfo.VictimInfos[ a ].NoFeed then
			
			NumVictims = NumVictims + 1
			
			local Victim = script.Victim:Clone( )
			
			Victim.VictimName.Text = DeathInfo.VictimInfos[ a ].User.Name
			
			Victim.VictimName.TextColor3 = DeathInfo.VictimInfos[ a ].User.TeamColor and DeathInfo.VictimInfos[ a ].User.TeamColor.Color or Neutral
			
			ApplyTextStroke( Victim.VictimName )
			
			Victim.Name = "Victim" .. NumVictims
			
			local Type = VictimTypes[ DeathInfo.VictimInfos[ a ].Hit ]
			
			if Type then
				
				local VictimType = script.VictimType:Clone( )
				
				VictimType.Image = Type
				
				VictimType.Parent = Victim
				
			end
			
			Victim.Position = UDim2.new( 1, 0, 1 * ( NumVictims - 1 ), 0 )
			
			if NumVictims > 1 then
				
				script.VictimFrame:Clone( ).Parent = Victim
				
			end
			
			Victim.Parent = NewFeed
			
		end
		
	end
	
	if NumVictims == 0 then return end
	
	NewFeed.Killer.KillerName.Text = DeathInfo.Killer and DeathInfo.Killer.Name or NewFeed[ "Victim1" ].VictimName.Text
	
	NewFeed.Killer.KillerName.TextColor3 = DeathInfo.Killer and DeathInfo.Killer.TeamColor and DeathInfo.Killer.TeamColor.Color or NewFeed[ "Victim1" ].VictimName.TextColor3
	
	ApplyTextStroke( NewFeed.Killer.KillerName )
	
	if DeathInfo.Assister then
		
		local Assister = script.Assister:Clone( )
		
		Assister.AssisterName.Text = DeathInfo.Assister.Name
		
		Assister.AssisterName.TextColor3 = DeathInfo.Assister.TeamColor and DeathInfo.Assister.TeamColor.Color or Neutral
		
		ApplyTextStroke( Assister.AssisterName )
		
		Assister.AssisterPct.Text = PctStr( DeathInfo.AssisterDamage / DeathInfo.TotalDamage * 100, 0 ) .. "%"
		
		Assister.Parent = NewFeed.Killer
		
		local KillPct = script.KillerPct:Clone( )
		
		KillPct.Text = PctStr( DeathInfo.KillerDamage / DeathInfo.TotalDamage * 100, 0 ) .. "%"
		
		KillPct.Parent = NewFeed.Killer
		
	end
	
	local Feeds = script.Parent:GetChildren( )
	
	for a = 1, #Feeds do
		
		if Feeds[ a ]:IsA( "Frame" ) then
			
			Feeds[ a ].ActualPos.Value = Feeds[ a ].ActualPos.Value + 0.035 + math.max( 0.035 * ( NumVictims - 1 ), DeathInfo.Assister and 0.015 or 0 )
			
			TweenService:Create( Feeds[ a ], TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Position = UDim2.new( 0.5, 0, Feeds[ a ].ActualPos.Value, 0  ) } ):Play( )
			
			if Feeds[ a ].ActualPos.Value > 0.175 and Feeds[ a ].Name ~= "Destroying" then
				
				local Feed = Feeds[ a ]
				
				Feed.Name = "Destroying"
				
				local Tween = TweenService:Create( Feed, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Size = Zero } )
				
				Tween.Completed:Connect( function ( State )
					
					Feed:Destroy( )
					
				end )
				
				Tween:Play( )
				
			end
			
		end
		
	end
	
	Feeds = NewFeed:GetDescendants( )
	
	for a = 1, #Feeds do
		
		if Feeds[ a ]:IsA( "TextLabel" ) then
			
			local Obj = Feeds[ a ]
			
			Obj:GetPropertyChangedSignal( "AbsoluteSize" ):Connect( function ( )
				
				if Obj.AbsoluteSize.X < 1 then
					
					Obj.Visible = false
					
				else
					
					Obj.Visible = true
					
				end
				
			end )
			
		end
		
	end
	
	NewFeed.Parent = script.Parent
	
	Scale( NewFeed )
	
	NewFeed.Size = Zero
	
	TweenService:Create( NewFeed, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Size = UDim2.new( 0.03, 0, 0.03, 0 ) } ):Play( )
	
	wait( 0.25 )
	
	TweenService:Create( NewFeed.Type, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Size = UDim2.new( 1, 0, 1, 0 ), ImageTransparency = 0 } ):Play( )
	
	wait( 5 )
	
	if NewFeed.Parent and NewFeed.Name ~= "Destroying" then
		
		NewFeed.Name = "Destroying"
		
		local Tween = TweenService:Create( NewFeed, TweenInfo.new( 0.25, Enum.EasingStyle.Quad ), { Size = Zero } )
		
		Tween.Completed:Connect( function ( State )
			
			NewFeed:Destroy( )
			
		end )
		
		Tween:Play( )
		
	end
	
end )