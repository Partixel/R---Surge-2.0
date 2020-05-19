local CollectionService = game:GetService("CollectionService")

local ThemeUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("ThemeUtil"):WaitForChild("ThemeUtil"))

local DirectionNames = {
	[0] = "N",
	[22.5] = "NNE",
	[45] = "NE",
	[67.5] = "ENE",
	[90] = "E",
	[112.5] = "ESE",
	[135] = "SE",
	[157.5] = "SSE",
	[180] = "S",
	[202.5] = "SSW",
	[225] = "SW",
	[247.5] = "WSW",
	[270] = "W",
	[292.5] = "WNW",
	[315] = "NW",
	[337.5] = "NNW",
}
local Degrees = 5.625
local AngleToShow = 25

ThemeUtil.BindUpdate({script.Parent.CompassFrame.TopArrow, script.Parent.CompassFrame.BottomArrow}, {TextColor3 = "Primary_BackgroundColor", TextStrokeColor3 = "Inverted_BackgroundColor"})
ThemeUtil.BindUpdate(script.Parent.CompassFrame.Bar, {ImageColor3 = "Primary_BackgroundColor"})
ThemeUtil.BindUpdate(script.Parent.CompassFrame.BackBar, {ImageColor3 = "Inverted_BackgroundColor"})

function GetAngle(CFrameA, VectorB)
	local Projected = (CFrameA * CFrame.Angles(0, math.rad(90), 0)):PointToObjectSpace(VectorB)
	local Angle = math.deg(math.atan2(Projected.Z, Projected.X))
	if Angle < 0 then
		return 360 + Angle
	else
		return Angle
	end
end

local Angles = {}
for i = 0, 360 - Degrees, Degrees do
	local Angle = i == 0 and 0 or 360 - i
	
	local Point = script.Point:Clone()
	Point.Name = Angle
	Point.Degrees.Text = math.floor(Angle + 0.5)
	Point.DirectionName.Text = DirectionNames[Angle] or ".."
	
	ThemeUtil.BindUpdate({Point.Degrees, Point.DirectionName}, {TextColor3 = "Primary_TextColor", TextStrokeColor3 = "Inverted_TextColor"})
	
	Point.Parent = script.Parent.CompassFrame
		
	Angles[(CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(0, math.rad(i), 0) * CFrame.new(0, 0, 1)).p] = Point
end

local POI = {}
local function AddPOI(Part)
	local ObjPoint = script.ObjPoint:Clone()
	ObjPoint.Name = Part.Name
	ObjPoint.TextColor3 = Part.Color
	ObjPoint.Parent = script.Parent.CompassFrame
	
	ThemeUtil.BindUpdate(ObjPoint, {TextStrokeColor3 = "Inverted_BackgroundColor"})
	
	POI[Part] = ObjPoint
end

CollectionService:GetInstanceAddedSignal("S2_POI"):Connect(AddPOI)
for _, Part in ipairs(CollectionService:GetTagged("S2_POI")) do
	AddPOI(Part)
end
CollectionService:GetInstanceRemovedSignal("S2_POI"):Connect(function(Part)
	POI[Part] = POI[Part]:Destroy()
end)

while game["Run Service"].Heartbeat:Wait() do
	local CameraLookVector = workspace.CurrentCamera.CFrame.LookVector * Vector3.new(1, 0, 1)
	
	for Angle, Point in pairs(Angles) do
		Angle = GetAngle(CFrame.new(Vector3.new(), CameraLookVector), Angle)
		script.Parent.PositionalFrame.Rotation = Angle
		Point.Visible = Angle <= AngleToShow or Angle >= 360 - AngleToShow - 1
		if Point.Visible then
			Point.Position = UDim2.new(0, script.Parent.PositionalFrame.TextLabel.AbsolutePosition.X - (workspace.CurrentCamera.ViewportSize.X - script.Parent.CompassFrame.AbsoluteSize.X) / 2, 0.5, 0)
			local Pct = (Angle <= AngleToShow and Angle / AngleToShow or (360 - Angle) / AngleToShow)
			Point.Degrees.TextStrokeTransparency = 0.05 + Pct * 0.95
			Point.Degrees.TextTransparency = Pct
			Point.DirectionName.TextStrokeTransparency = 0.05 + Pct * 0.95
			Point.DirectionName.TextTransparency = Pct
		end
	end
	
	for Part, ObjPoint in pairs(POI) do
		local Angle = GetAngle(CFrame.new(workspace.CurrentCamera.Focus.p, workspace.CurrentCamera.Focus.p + CameraLookVector), Part.Position)
		script.Parent.PositionalFrame.Rotation = Angle
		ObjPoint.Visible = Angle <= AngleToShow or Angle >= 360 - AngleToShow - 1
		if ObjPoint.Visible then
			ObjPoint.Position = UDim2.new(0, script.Parent.PositionalFrame.TextLabel.AbsolutePosition.X - (workspace.CurrentCamera.ViewportSize.X - script.Parent.CompassFrame.AbsoluteSize.X) / 2, 0.485, 0)
			local Pct = (Angle <= AngleToShow and Angle / AngleToShow or (360 - Angle) / AngleToShow)
			ObjPoint.TextStrokeTransparency = 0.35 + Pct * 0.65
			ObjPoint.TextTransparency = Pct
		end
	end
end