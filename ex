local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local ANIM_ENABLED = true

local Spring = {}
Spring.__index = Spring

function Spring.new(stiffness, damping, mass)
	local self = setmetatable({}, Spring)
	self.Pos = 0
	self.Vel = 0
	self.Target = 0
	self.K = stiffness or 220
	self.D = damping or 22
	self.M = mass or 1
	return self
end

function Spring:Update(dt)
	dt = math.min(dt, 0.033)
	local steps = math.ceil(dt / 0.016)
	local subDt = dt / steps
	for _ = 1, steps do
		local x = self.Pos - self.Target
		local springForce = -self.K * x
		local dampForce = -self.D * self.Vel
		local accel = (springForce + dampForce) / self.M
		self.Vel = self.Vel + accel * subDt
		self.Pos = self.Pos + self.Vel * subDt
	end
	return self.Pos
end

function Spring:Impulse(force)
	self.Vel = self.Vel + force
end

function Spring:SetTarget(t)
	self.Target = t
end

function Spring:Done(threshold)
	threshold = threshold or 0.001
	return math.abs(self.Pos - self.Target) < threshold and math.abs(self.Vel) < threshold
end
local Pool = {}
local _poolConn = nil
local _poolId = 0

local function poolAdd(fn)
	_poolId = _poolId + 1
	local id = _poolId
	Pool[id] = fn
	if not _poolConn then
		_poolConn = RunService.Heartbeat:Connect(function(dt)
			for k, v in pairs(Pool) do
				if v(dt) == false then
					Pool[k] = nil
				end
			end
			if not next(Pool) and _poolConn then
				_poolConn:Disconnect()
				_poolConn = nil
			end
		end)
	end
	return id
end

local function poolRemove(id)
	if id then Pool[id] = nil end
end

local function poolRemove(id)
	if id then Pool[id] = nil end
end

local C = {
	GradA = Color3.fromRGB(18, 18, 24),
	GradB = Color3.fromRGB(22, 22, 30),
	GradC = Color3.fromRGB(16, 16, 22),
	GradD = Color3.fromRGB(12, 12, 18),
	Wave1 = Color3.fromRGB(25, 25, 35),
	Wave2 = Color3.fromRGB(20, 20, 28),
	Wave3 = Color3.fromRGB(22, 22, 30),
	BG = Color3.fromRGB(14, 14, 20),
	BGAlt = Color3.fromRGB(18, 18, 26),
	Surface = Color3.fromRGB(24, 24, 32),
	SurfaceAlt = Color3.fromRGB(28, 28, 38),
	Border = Color3.fromRGB(42, 42, 55),
	BorderLit = Color3.fromRGB(58, 58, 75),
	Text = Color3.fromRGB(225, 225, 235),
	Sub = Color3.fromRGB(145, 145, 165),
	Dim = Color3.fromRGB(85, 85, 105),
	Accent = Color3.fromRGB(180, 180, 195),
	AccentLit = Color3.fromRGB(200, 200, 215),
	AccentSub = Color3.fromRGB(32, 32, 44),
	AccentDark = Color3.fromRGB(140, 140, 160),
	Purple = Color3.fromRGB(120, 105, 180),
	PurpleLit = Color3.fromRGB(145, 130, 200),
	PurpleSub = Color3.fromRGB(28, 26, 40),
	PurpleDeep = Color3.fromRGB(100, 85, 160),
	Peach = Color3.fromRGB(160, 130, 115),
	PeachLit = Color3.fromRGB(180, 155, 140),
	PeachSub = Color3.fromRGB(30, 26, 24),
	PeachDeep = Color3.fromRGB(140, 110, 95),
	Watermelon = Color3.fromRGB(180, 80, 85),
	ElecBlue = Color3.fromRGB(80, 130, 210),
	Mint = Color3.fromRGB(85, 180, 130),
	Lilac = Color3.fromRGB(140, 115, 200),
	SoftOrange = Color3.fromRGB(200, 140, 70),
	HotPink = Color3.fromRGB(190, 85, 130),
	Coral = Color3.fromRGB(195, 105, 105),
	SkyBlue = Color3.fromRGB(95, 155, 215),
	Lavender = Color3.fromRGB(150, 130, 210),
	Ok = Color3.fromRGB(75, 190, 130),
	Warn = Color3.fromRGB(210, 170, 60),
	Err = Color3.fromRGB(210, 75, 75),
	Info = Color3.fromRGB(80, 145, 220),
	TrackOff = Color3.fromRGB(38, 38, 50),
	SidebarBG = Color3.fromRGB(16, 16, 22),
	SidebarHover = Color3.fromRGB(28, 28, 38),
	SidebarActive = Color3.fromRGB(32, 32, 44),
	TopbarBG = Color3.fromRGB(16, 16, 22),
	SubTabBG = Color3.fromRGB(18, 18, 26),
	SubTabActive = Color3.fromRGB(28, 28, 38),
	NotifBG = Color3.fromRGB(22, 22, 30),
	ActivePanelBG = Color3.fromRGB(18, 18, 26),
	ActiveItemBG = Color3.fromRGB(28, 28, 38),
	ActiveItemGlow = Color3.fromRGB(45, 45, 60),
	ClayHighlight = Color3.fromRGB(55, 55, 70),
	ClayShadow = Color3.fromRGB(6, 6, 10),
	ClayShadowDeep = Color3.fromRGB(3, 3, 6),
	FooterBG = Color3.fromRGB(14, 14, 20),
}

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function lerpColor(a, b, t)
	return Color3.new(lerp(a.R, b.R, t), lerp(a.G, b.G, t), lerp(a.B, b.B, t))
end

local function tw(obj, dur, props, style, dir)
	if not obj or not obj.Parent then return nil end
	if not ANIM_ENABLED then
		for k, v in pairs(props) do
			pcall(function() obj[k] = v end)
		end
		return nil
	end
	local info = TweenInfo.new(dur, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 16)
	c.Parent = parent
	return c
end

local function pad(parent, top, bot, left, right)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, top or 0)
	p.PaddingBottom = UDim.new(0, bot or 0)
	p.PaddingLeft = UDim.new(0, left or 0)
	p.PaddingRight = UDim.new(0, right or 0)
	p.Parent = parent
	return p
end

local function uiList(parent, gap, dir, hAlign, vAlign)
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, gap or 6)
	l.FillDirection = dir or Enum.FillDirection.Vertical
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left
	l.VerticalAlignment = vAlign or Enum.VerticalAlignment.Top
	l.Parent = parent
	return l
end

local function uiGrid(parent, cellSizeX, cellSizeY, gap, fillDir)
	local g = Instance.new("UIGridLayout")
	g.CellSize = UDim2.new(0, cellSizeX or 200, 0, cellSizeY or 80)
	g.CellPadding = UDim2.new(0, gap or 8, 0, gap or 8)
	g.FillDirection = fillDir or Enum.FillDirection.Horizontal
	g.SortOrder = Enum.SortOrder.LayoutOrder
	g.FillDirectionMaxCells = 2
	g.Parent = parent
	return g
end

local function strokeInst(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or C.Border
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0.2
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function tweenIconColor(icon, dur, color, style)
	if not icon or not icon.Parent then return end
	if icon:IsA("ImageLabel") or icon:IsA("ImageButton") then
		tw(icon, dur, {ImageColor3 = color}, style)
	else
		tw(icon, dur, {TextColor3 = color}, style)
	end
end

local function noHit(frame)
	frame.Active = false
	pcall(function() frame.Selectable = false end)
	return frame
end

local function getScale()
	local vp = Camera.ViewportSize
	return math.clamp(math.min(vp.X, vp.Y * 1.6) / 1080, 0.65, 1.15)
end

local SC = getScale()

local FONT_TITLE = math.floor(19 * SC)
local FONT_ICON_SIDEBAR = math.floor(20 * SC)
local FONT_SIDEBAR_LABEL = math.floor(13 * SC)
local FONT_SUBTAB = math.floor(13 * SC)
local FONT_ELEM_NAME = math.floor(15 * SC)
local FONT_ELEM_VALUE = math.floor(12 * SC)
local FONT_SMALL = math.floor(11 * SC)
local FONT_SECTION = math.floor(14 * SC)
local FONT_SECTION_ICON = math.floor(15 * SC)
local FONT_VERSION = math.floor(10 * SC)
local FONT_FOOTER = math.floor(12 * SC)
local FONT_ACTIVE_PANEL = math.floor(12 * SC)

local TextIcons = {
	circle      = "\xE2\x97\x8F",
	ring        = "\xE2\x97\x8B",
	dot         = "\xE2\x80\xA2",
	check       = "\xE2\x9C\x93",
	x           = "\xE2\x9C\x95",
	star        = "\xE2\x98\x85",
	heart       = "\xE2\x99\xA5",
	arrow_r     = "\xE2\x86\x92",
	arrow_l     = "\xE2\x86\x90",
	arrow_u     = "\xE2\x86\x91",
	arrow_d     = "\xE2\x86\x93",
	expand      = "\xE2\x96\xBC",
	collapse    = "\xE2\x96\xB2",
	sparkle     = "\xE2\x9C\xA6",
	diamond     = "\xE2\x97\x86",
	dash        = "\xE2\x80\x94",
	play        = "\xE2\x96\xB6",
	pause       = "\xE2\x8F\xB8",
}

local IconAssets = {
	["10k"] = "rbxassetid://6026643035",
	["10mp"] = "rbxassetid://6031328149",
	["11mp"] = "rbxassetid://6031328141",
	["12mp"] = "rbxassetid://6031328140",
	["13mp"] = "rbxassetid://6031328137",
	["14mp"] = "rbxassetid://6031328161",
	["15mp"] = "rbxassetid://6031328158",
	["16mp"] = "rbxassetid://6031328168",
	["17mp"] = "rbxassetid://6031339055",
	["18mp"] = "rbxassetid://6031339064",
	["19mp"] = "rbxassetid://6031339054",
	["1k"] = "rbxassetid://6026643002",
	["1k_plus"] = "rbxassetid://6026681580",
	["20mp"] = "rbxassetid://6031488940",
	["21mp"] = "rbxassetid://6031339065",
	["22mp"] = "rbxassetid://6031360353",
	["23mp"] = "rbxassetid://6031339045",
	["24mp"] = "rbxassetid://6031360352",
	["2k"] = "rbxassetid://6026643032",
	["2k_plus"] = "rbxassetid://6026681588",
	["2mp"] = "rbxassetid://6031328138",
	["360"] = "rbxassetid://6034767608",
	["3d_rotation"] = "rbxassetid://6022668893",
	["3k"] = "rbxassetid://6026681574",
	["3k_plus"] = "rbxassetid://6026681598",
	["3mp"] = "rbxassetid://6031328136",
	["4k"] = "rbxassetid://6026643017",
	["4k_plus"] = "rbxassetid://6026643005",
	["4mp"] = "rbxassetid://6031328152",
	["5g"] = "rbxassetid://6026643007",
	["5k"] = "rbxassetid://6026681575",
	["5k_plus"] = "rbxassetid://6026643028",
	["5mp"] = "rbxassetid://6031328144",
	["6k"] = "rbxassetid://6026681579",
	["6k_plus"] = "rbxassetid://6026643019",
	["6mp"] = "rbxassetid://6031328131",
	["7k"] = "rbxassetid://6026681584",
	["7k_plus"] = "rbxassetid://6026643012",
	["7mp"] = "rbxassetid://6031328139",
	["8k"] = "rbxassetid://6026643014",
	["8k_plus"] = "rbxassetid://6026643003",
	["8mp"] = "rbxassetid://6031328133",
	["9k"] = "rbxassetid://6026643013",
	["9k_plus"] = "rbxassetid://6026681585",
	["9mp"] = "rbxassetid://6031328146",
	["_add_alert"] = "rbxassetid://6031071067",
	["_auto_delete"] = "rbxassetid://6031071068",
	["_error"] = "rbxassetid://6031071057",
	["_error_outline"] = "rbxassetid://6031071050",
	["_notification_important"] = "rbxassetid://6031071056",
	["_warning"] = "rbxassetid://6031071053",
	["ac_unit"] = "rbxassetid://6035107929",
	["access_alarm"] = "rbxassetid://6034983844",
	["access_alarms"] = "rbxassetid://6034983853",
	["access_time"] = "rbxassetid://6034983856",
	["accessibility"] = "rbxassetid://6022668887",
	["accessibility_new"] = "rbxassetid://6022668945",
	["accessible"] = "rbxassetid://6022668902",
	["accessible_forward"] = "rbxassetid://6022668906",
	["account_balance"] = "rbxassetid://6022668900",
	["account_balance_wallet"] = "rbxassetid://6022668892",
	["account_box"] = "rbxassetid://6023426915",
	["account_circle"] = "rbxassetid://6022668898",
	["account_tree"] = "rbxassetid://6034418507",
	["ad_units"] = "rbxassetid://6034983845",
	["adb"] = "rbxassetid://6034418515",
	["add"] = "rbxassetid://6035047377",
	["add_a_photo"] = "rbxassetid://6031339049",
	["add_alarm"] = "rbxassetid://6034983850",
	["add_box"] = "rbxassetid://6035047375",
	["add_business"] = "rbxassetid://6034483666",
	["add_call"] = "rbxassetid://6034418524",
	["add_chart"] = "rbxassetid://6034898093",
	["add_circle"] = "rbxassetid://6035047380",
	["add_circle_outline"] = "rbxassetid://6035047391",
	["add_comment"] = "rbxassetid://6034898128",
	["add_ic_call"] = "rbxassetid://6035173839",
	["add_link"] = "rbxassetid://6035047374",
	["add_location"] = "rbxassetid://6034483672",
	["add_location_alt"] = "rbxassetid://6034483678",
	["add_moderator"] = "rbxassetid://6034295699",
	["add_photo_alternate"] = "rbxassetid://6031471484",
	["add_road"] = "rbxassetid://6034483677",
	["add_shopping_cart"] = "rbxassetid://6022668875",
	["add_task"] = "rbxassetid://6022668912",
	["add_to_drive"] = "rbxassetid://6022860335",
	["add_to_home_screen"] = "rbxassetid://6034983858",
	["add_to_photos"] = "rbxassetid://6031371075",
	["add_to_queue"] = "rbxassetid://6026647903",
	["addchart"] = "rbxassetid://6023426905",
	["adjust"] = "rbxassetid://6031339048",
	["admin_panel_settings"] = "rbxassetid://6022668961",
	["agriculture"] = "rbxassetid://6034483674",
	["airline_seat_flat"] = "rbxassetid://6034418511",
	["airline_seat_flat_angled"] = "rbxassetid://6034418513",
	["airline_seat_individual_suite"] = "rbxassetid://6034418514",
	["airline_seat_legroom_extra"] = "rbxassetid://6034418508",
	["airline_seat_legroom_normal"] = "rbxassetid://6034418532",
	["airline_seat_legroom_reduced"] = "rbxassetid://6034418520",
	["airline_seat_recline_extra"] = "rbxassetid://6034418528",
	["airline_seat_recline_normal"] = "rbxassetid://6034418512",
	["airplanemode_active"] = "rbxassetid://6034983864",
	["airplanemode_inactive"] = "rbxassetid://6034983848",
	["airplay"] = "rbxassetid://6026647929",
	["airport_shuttle"] = "rbxassetid://6035107921",
	["alarm"] = "rbxassetid://6023426910",
	["alarm_add"] = "rbxassetid://6023426898",
	["alarm_off"] = "rbxassetid://6023426901",
	["alarm_on"] = "rbxassetid://6023426920",
	["album"] = "rbxassetid://6026647905",
	["all_inbox"] = "rbxassetid://6022668909",
	["all_inclusive"] = "rbxassetid://6035107920",
	["all_out"] = "rbxassetid://6022668876",
	["alt_route"] = "rbxassetid://6034483670",
	["alternate_email"] = "rbxassetid://6035173865",
	["amp_stories"] = "rbxassetid://6035047382",
	["analytics"] = "rbxassetid://6022668884",
	["anchor"] = "rbxassetid://6023426906",
	["android"] = "rbxassetid://6022668966",
	["animation"] = "rbxassetid://6031625150",
	["announcement"] = "rbxassetid://6022668946",
	["apartment"] = "rbxassetid://6035107922",
	["api"] = "rbxassetid://6022668911",
	["app_blocking"] = "rbxassetid://6022668952",
	["app_registration"] = "rbxassetid://6035173870",
	["app_settings_alt"] = "rbxassetid://6031090998",
	["approval"] = "rbxassetid://6031302928",
	["apps"] = "rbxassetid://6031090999",
	["architecture"] = "rbxassetid://6034275730",
	["archive"] = "rbxassetid://6035047379",
	["arrow_back"] = "rbxassetid://6031091000",
	["arrow_back_ios"] = "rbxassetid://6031091003",
	["arrow_circle_down"] = "rbxassetid://6022668877",
	["arrow_circle_up"] = "rbxassetid://6022668934",
	["arrow_downward"] = "rbxassetid://6031090991",
	["arrow_drop_down"] = "rbxassetid://6031091004",
	["arrow_drop_down_circle"] = "rbxassetid://6031091001",
	["arrow_drop_up"] = "rbxassetid://6031090990",
	["arrow_forward"] = "rbxassetid://6031090995",
	["arrow_forward_ios"] = "rbxassetid://6031091008",
	["arrow_left"] = "rbxassetid://6031091002",
	["arrow_right"] = "rbxassetid://6031090994",
	["arrow_right_alt"] = "rbxassetid://6022668890",
	["arrow_upward"] = "rbxassetid://6031090997",
	["art_track"] = "rbxassetid://6026647908",
	["article"] = "rbxassetid://6022668907",
	["aspect_ratio"] = "rbxassetid://6022668895",
	["assessment"] = "rbxassetid://6022668897",
	["assignment"] = "rbxassetid://6022668882",
	["assignment_ind"] = "rbxassetid://6022668935",
	["assignment_late"] = "rbxassetid://6022668880",
	["assignment_return"] = "rbxassetid://6023426931",
	["assignment_returned"] = "rbxassetid://6023426899",
	["assignment_turned_in"] = "rbxassetid://6023426904",
	["assistant"] = "rbxassetid://6031360356",
	["assistant_direction"] = "rbxassetid://6031091005",
	["assistant_navigation"] = "rbxassetid://6031091006",
	["assistant_photo"] = "rbxassetid://6031339052",
	["atm"] = "rbxassetid://6034767614",
	["attach_email"] = "rbxassetid://6031302935",
	["attach_file"] = "rbxassetid://6034898102",
	["attach_money"] = "rbxassetid://6034898098",
	["attachment"] = "rbxassetid://6031302921",
	["attractions"] = "rbxassetid://6034767620",
	["audiotrack"] = "rbxassetid://6031471489",
	["auto_awesome"] = "rbxassetid://6031360365",
	["auto_awesome_mosaic"] = "rbxassetid://6031371053",
	["auto_awesome_motion"] = "rbxassetid://6031360370",
	["auto_fix_high"] = "rbxassetid://6031360355",
	["auto_fix_normal"] = "rbxassetid://6031371074",
	["auto_fix_off"] = "rbxassetid://6031360381",
	["auto_stories"] = "rbxassetid://6031360360",
	["autorenew"] = "rbxassetid://6023565901",
	["av_timer"] = "rbxassetid://6026647934",
	["baby_changing_station"] = "rbxassetid://6035107930",
	["backpack"] = "rbxassetid://6035107928",
	["backspace"] = "rbxassetid://6035047397",
	["backup"] = "rbxassetid://6023426911",
	["backup_table"] = "rbxassetid://6022860338",
	["badge"] = "rbxassetid://6034767607",
	["bakery_dining"] = "rbxassetid://6034767610",
	["ballot"] = "rbxassetid://6035047386",
	["bar_chart"] = "rbxassetid://6034898096",
	["batch_prediction"] = "rbxassetid://6022860334",
	["bathtub"] = "rbxassetid://6035107939",
	["battery_alert"] = "rbxassetid://6034983843",
	["battery_charging_full"] = "rbxassetid://6034983849",
	["battery_full"] = "rbxassetid://6034983854",
	["battery_unknown"] = "rbxassetid://6034983842",
	["beach_access"] = "rbxassetid://6035107923",
	["bedtime"] = "rbxassetid://6031371054",
	["beenhere"] = "rbxassetid://6034483675",
	["bento"] = "rbxassetid://6035107924",
	["bike_scooter"] = "rbxassetid://6034483669",
	["biotech"] = "rbxassetid://6035047385",
	["block"] = "rbxassetid://6035047387",
	["block_flipped"] = "rbxassetid://6035047378",
	["bluetooth"] = "rbxassetid://6034983880",
	["bluetooth_audio"] = "rbxassetid://6034418522",
	["bluetooth_connected"] = "rbxassetid://6034983855",
	["bluetooth_disabled"] = "rbxassetid://6034989562",
	["bluetooth_searching"] = "rbxassetid://6034989553",
	["blur_circular"] = "rbxassetid://6031488945",
	["blur_linear"] = "rbxassetid://6031488930",
	["blur_off"] = "rbxassetid://6031371055",
	["blur_on"] = "rbxassetid://6031371068",
	["bolt"] = "rbxassetid://6035047381",
	["book"] = "rbxassetid://6022860343",
	["book_online"] = "rbxassetid://6022860332",
	["bookmark"] = "rbxassetid://6022852108",
	["bookmark_border"] = "rbxassetid://6022860339",
	["bookmarks"] = "rbxassetid://6023426924",
	["border_all"] = "rbxassetid://6034898101",
	["border_bottom"] = "rbxassetid://6034898094",
	["border_clear"] = "rbxassetid://6034898135",
	["border_color"] = "rbxassetid://6034898100",
	["border_horizontal"] = "rbxassetid://6034898105",
	["border_inner"] = "rbxassetid://6034898131",
	["border_left"] = "rbxassetid://6034898099",
	["border_outer"] = "rbxassetid://6034898104",
	["border_right"] = "rbxassetid://6034898120",
	["border_style"] = "rbxassetid://6034898097",
	["border_top"] = "rbxassetid://6034900726",
	["border_vertical"] = "rbxassetid://6034900725",
	["branding_watermark"] = "rbxassetid://6026647911",
	["breakfast_dining"] = "rbxassetid://6034483671",
	["brightness_1"] = "rbxassetid://6031471488",
	["brightness_2"] = "rbxassetid://6031488938",
	["brightness_3"] = "rbxassetid://6031572317",
	["brightness_4"] = "rbxassetid://6031471483",
	["brightness_5"] = "rbxassetid://6031471479",
	["brightness_6"] = "rbxassetid://6031572309",
	["brightness_7"] = "rbxassetid://6031471491",
	["brightness_auto"] = "rbxassetid://6034989545",
	["brightness_high"] = "rbxassetid://6034989541",
	["brightness_low"] = "rbxassetid://6034989542",
	["brightness_medium"] = "rbxassetid://6034989543",
	["broken_image"] = "rbxassetid://6031471480",
	["browser_not_supported"] = "rbxassetid://6034789875",
	["brunch_dining"] = "rbxassetid://6034767611",
	["brush"] = "rbxassetid://6031572320",
	["bubble_chart"] = "rbxassetid://6034925612",
	["bug_report"] = "rbxassetid://6022852107",
	["build"] = "rbxassetid://6023426938",
	["build_circle"] = "rbxassetid://6023426952",
	["burst_mode"] = "rbxassetid://6031572306",
	["bus_alert"] = "rbxassetid://6034767618",
	["business"] = "rbxassetid://6035173853",
	["business_center"] = "rbxassetid://6035107933",
	["cached"] = "rbxassetid://6023426921",
	["cake"] = "rbxassetid://6034295702",
	["calculate"] = "rbxassetid://6035047384",
	["calendar_today"] = "rbxassetid://6022668917",
	["calendar_view_day"] = "rbxassetid://6023426946",
	["call"] = "rbxassetid://6035173859",
	["call_end"] = "rbxassetid://6035173845",
	["call_made"] = "rbxassetid://6035173858",
	["call_merge"] = "rbxassetid://6035173843",
	["call_missed"] = "rbxassetid://6035173850",
	["call_missed_outgoing"] = "rbxassetid://6035173847",
	["call_received"] = "rbxassetid://6035173844",
	["call_split"] = "rbxassetid://6035173861",
	["call_to_action"] = "rbxassetid://6026647898",
	["camera"] = "rbxassetid://6031572312",
	["camera_alt"] = "rbxassetid://6031572307",
	["camera_enhance"] = "rbxassetid://6023426935",
	["camera_front"] = "rbxassetid://6031572318",
	["camera_rear"] = "rbxassetid://6031572316",
	["camera_roll"] = "rbxassetid://6031572314",
	["campaign"] = "rbxassetid://6031094666",
	["cancel"] = "rbxassetid://6031094677",
	["cancel_presentation"] = "rbxassetid://6035173837",
	["cancel_schedule_send"] = "rbxassetid://6022668963",
	["car_rental"] = "rbxassetid://6034767641",
	["car_repair"] = "rbxassetid://6034767617",
	["card_giftcard"] = "rbxassetid://6023426978",
	["card_membership"] = "rbxassetid://6023426942",
	["card_travel"] = "rbxassetid://6023426925",
	["carpenter"] = "rbxassetid://6035107955",
	["cases"] = "rbxassetid://6031572324",
	["casino"] = "rbxassetid://6035107936",
	["cast"] = "rbxassetid://6034789876",
	["cast_connected"] = "rbxassetid://6034789895",
	["cast_for_education"] = "rbxassetid://6034789872",
	["category"] = "rbxassetid://6034767621",
	["celebration"] = "rbxassetid://6034767613",
	["cell_wifi"] = "rbxassetid://6035173852",
	["center_focus_strong"] = "rbxassetid://6031625147",
	["center_focus_weak"] = "rbxassetid://6031625144",
	["change_history"] = "rbxassetid://6023426914",
	["charging_station"] = "rbxassetid://6035107925",
	["chat"] = "rbxassetid://6035173838",
	["chat_bubble"] = "rbxassetid://6035181858",
	["chat_bubble_outline"] = "rbxassetid://6035181869",
	["check"] = "rbxassetid://6031094667",
	["check_box"] = "rbxassetid://6031068421",
	["check_box_outline_blank"] = "rbxassetid://6031068420",
	["check_circle"] = "rbxassetid://6023426945",
	["check_circle_outline"] = "rbxassetid://6023426909",
	["checkroom"] = "rbxassetid://6035107931",
	["chevron_left"] = "rbxassetid://6031094670",
	["chevron_right"] = "rbxassetid://6031094680",
	["child_care"] = "rbxassetid://6035107927",
	["child_friendly"] = "rbxassetid://6035121942",
	["chrome_reader_mode"] = "rbxassetid://6023426912",
	["circle"] = "rbxassetid://6031625146",
	["circle_notifications"] = "rbxassetid://6023426923",
	["class"] = "rbxassetid://6022668949",
	["clean_hands"] = "rbxassetid://6034275729",
	["cleaning_services"] = "rbxassetid://6034767619",
	["clear"] = "rbxassetid://6035047409",
	["clear_all"] = "rbxassetid://6035181870",
	["close"] = "rbxassetid://6031094678",
	["close_fullscreen"] = "rbxassetid://6023426928",
	["closed_caption"] = "rbxassetid://6026647896",
	["closed_caption_disabled"] = "rbxassetid://6026647900",
	["closed_caption_off"] = "rbxassetid://6026647943",
	["cloud"] = "rbxassetid://6031302918",
	["cloud_circle"] = "rbxassetid://6031302919",
	["cloud_done"] = "rbxassetid://6031302927",
	["cloud_download"] = "rbxassetid://6031302917",
	["cloud_off"] = "rbxassetid://6031302993",
	["cloud_queue"] = "rbxassetid://6031302916",
	["cloud_upload"] = "rbxassetid://6031302992",
	["code"] = "rbxassetid://6022668955",
	["collections"] = "rbxassetid://6031625145",
	["collections_bookmark"] = "rbxassetid://6034328965",
	["color_lens"] = "rbxassetid://6031625148",
	["colorize"] = "rbxassetid://6031625161",
	["comment"] = "rbxassetid://6035181871",
	["comment_bank"] = "rbxassetid://6023426937",
	["commute"] = "rbxassetid://6022668901",
	["compare"] = "rbxassetid://6031625151",
	["compare_arrows"] = "rbxassetid://6022668951",
	["compass_calibration"] = "rbxassetid://6034767623",
	["compress"] = "rbxassetid://6022668878",
	["computer"] = "rbxassetid://6034789874",
	["confirmation_number"] = "rbxassetid://6034418519",
	["connect_without_contact"] = "rbxassetid://6034275800",
	["connected_tv"] = "rbxassetid://6034789870",
	["construction"] = "rbxassetid://6034275725",
	["contact_mail"] = "rbxassetid://6035181868",
	["contact_page"] = "rbxassetid://6022668881",
	["contact_phone"] = "rbxassetid://6035181861",
	["contact_support"] = "rbxassetid://6022668879",
	["contactless"] = "rbxassetid://6022668886",
	["contacts"] = "rbxassetid://6035181864",
	["content_copy"] = "rbxassetid://6035053278",
	["content_cut"] = "rbxassetid://6035053280",
	["content_paste"] = "rbxassetid://6035053285",
	["control_camera"] = "rbxassetid://6026647916",
	["control_point"] = "rbxassetid://6031625131",
	["control_point_duplicate"] = "rbxassetid://6034328959",
	["copyright"] = "rbxassetid://6023565898",
	["coronavirus"] = "rbxassetid://6034275724",
	["corporate_fare"] = "rbxassetid://6035121908",
	["countertops"] = "rbxassetid://6035121914",
	["create"] = "rbxassetid://6035053304",
	["create_new_folder"] = "rbxassetid://6031302933",
	["crop"] = "rbxassetid://6034328964",
	["crop_16_9"] = "rbxassetid://6031630205",
	["crop_3_2"] = "rbxassetid://6034328956",
	["crop_5_4"] = "rbxassetid://6034328960",
	["crop_7_5"] = "rbxassetid://6031630197",
	["crop_din"] = "rbxassetid://6031630208",
	["crop_free"] = "rbxassetid://6031630212",
	["crop_landscape"] = "rbxassetid://6031630202",
	["crop_original"] = "rbxassetid://6031630204",
	["crop_portrait"] = "rbxassetid://6031630198",
	["crop_rotate"] = "rbxassetid://6031630203",
	["crop_square"] = "rbxassetid://6031630222",
	["dangerous"] = "rbxassetid://6022668916",
	["dashboard"] = "rbxassetid://6022668883",
	["dashboard_customize"] = "rbxassetid://6022668899",
	["data_usage"] = "rbxassetid://6034989568",
	["date_range"] = "rbxassetid://6022668894",
	["deck"] = "rbxassetid://6034295703",
	["dehaze"] = "rbxassetid://6031630200",
	["delete"] = "rbxassetid://6022668885",
	["delete_forever"] = "rbxassetid://6022668939",
	["delete_outline"] = "rbxassetid://6022668962",
	["delete_sweep"] = "rbxassetid://6035053301",
	["delivery_dining"] = "rbxassetid://6034767644",
	["departure_board"] = "rbxassetid://6034767615",
	["description"] = "rbxassetid://6022668888",
	["design_services"] = "rbxassetid://6034754453",
	["desktop_access_disabled"] = "rbxassetid://6035181863",
	["desktop_mac"] = "rbxassetid://6034789898",
	["desktop_windows"] = "rbxassetid://6034789893",
	["details"] = "rbxassetid://6034328968",
	["developer_board"] = "rbxassetid://6034789883",
	["developer_mode"] = "rbxassetid://6034989549",
	["device_hub"] = "rbxassetid://6034789877",
	["device_thermostat"] = "rbxassetid://6034989544",
	["device_unknown"] = "rbxassetid://6034789884",
	["devices"] = "rbxassetid://6034989540",
	["devices_other"] = "rbxassetid://6034789873",
	["dialer_sip"] = "rbxassetid://6035181865",
	["dialpad"] = "rbxassetid://6035181892",
	["dinner_dining"] = "rbxassetid://6034754457",
	["directions"] = "rbxassetid://6034754449",
	["directions_bike"] = "rbxassetid://6034754459",
	["directions_boat"] = "rbxassetid://6034754442",
	["directions_bus"] = "rbxassetid://6034754434",
	["directions_car"] = "rbxassetid://6034754441",
	["directions_off"] = "rbxassetid://6034418517",
	["directions_railway"] = "rbxassetid://6034754433",
	["directions_run"] = "rbxassetid://6034754445",
	["directions_subway"] = "rbxassetid://6034754440",
	["directions_transit"] = "rbxassetid://6034754436",
	["directions_walk"] = "rbxassetid://6034754448",
	["dirty_lens"] = "rbxassetid://6034328967",
	["disabled_by_default"] = "rbxassetid://6023426939",
	["disc_full"] = "rbxassetid://6034418518",
	["dns"] = "rbxassetid://6023426958",
	["do_not_disturb"] = "rbxassetid://6034439645",
	["do_not_disturb_alt"] = "rbxassetid://6034461619",
	["do_not_disturb_off"] = "rbxassetid://6034439642",
	["do_not_disturb_on"] = "rbxassetid://6034439649",
	["do_not_step"] = "rbxassetid://6035121910",
	["do_not_touch"] = "rbxassetid://6035121915",
	["dock"] = "rbxassetid://6034789888",
	["domain"] = "rbxassetid://6034275722",
	["domain_disabled"] = "rbxassetid://6035181862",
	["domain_verification"] = "rbxassetid://6035181867",
	["done"] = "rbxassetid://6023426926",
	["done_all"] = "rbxassetid://6023426929",
	["done_outline"] = "rbxassetid://6023426936",
	["double_arrow"] = "rbxassetid://6031094674",
	["drafts"] = "rbxassetid://6035053297",
	["drag_handle"] = "rbxassetid://6034910907",
	["drag_indicator"] = "rbxassetid://6023426962",
	["drive_eta"] = "rbxassetid://6034464371",
	["drive_file_move"] = "rbxassetid://6031302922",
	["drive_file_move_outline"] = "rbxassetid://6031302924",
	["drive_file_rename_outline"] = "rbxassetid://6031302994",
	["drive_folder_upload"] = "rbxassetid://6031302929",
	["dry"] = "rbxassetid://6035121909",
	["dry_cleaning"] = "rbxassetid://6034754456",
	["duo"] = "rbxassetid://6035181860",
	["dvr"] = "rbxassetid://6034989561",
	["dynamic_feed"] = "rbxassetid://6035053289",
	["dynamic_form"] = "rbxassetid://6023426970",
	["east"] = "rbxassetid://6031094675",
	["eco"] = "rbxassetid://6023426988",
	["edit"] = "rbxassetid://6034328955",
	["edit_attributes"] = "rbxassetid://6034754443",
	["edit_location"] = "rbxassetid://6034754439",
	["edit_off"] = "rbxassetid://6023426983",
	["edit_road"] = "rbxassetid://6034744035",
	["eject"] = "rbxassetid://6023426930",
	["elderly"] = "rbxassetid://6034295698",
	["electric_bike"] = "rbxassetid://6034744032",
	["electric_car"] = "rbxassetid://6034744029",
	["electric_moped"] = "rbxassetid://6034744027",
	["electric_rickshaw"] = "rbxassetid://6034744043",
	["electric_scooter"] = "rbxassetid://6034744041",
	["electrical_services"] = "rbxassetid://6034744038",
	["elevator"] = "rbxassetid://6035121912",
	["email"] = "rbxassetid://6035181866",
	["emoji_emotions"] = "rbxassetid://6034275731",
	["emoji_events"] = "rbxassetid://6034275726",
	["emoji_flags"] = "rbxassetid://6034304898",
	["emoji_food_beverage"] = "rbxassetid://6034304883",
	["emoji_nature"] = "rbxassetid://6034281896",
	["emoji_objects"] = "rbxassetid://6034281900",
	["emoji_people"] = "rbxassetid://6034281904",
	["emoji_symbols"] = "rbxassetid://6034281899",
	["emoji_transportation"] = "rbxassetid://6034281894",
	["engineering"] = "rbxassetid://6034281908",
	["enhanced_encryption"] = "rbxassetid://6034439652",
	["equalizer"] = "rbxassetid://6026647906",
	["escalator"] = "rbxassetid://6035121939",
	["escalator_warning"] = "rbxassetid://6035121930",
	["euro"] = "rbxassetid://6034328963",
	["euro_symbol"] = "rbxassetid://6023426954",
	["ev_station"] = "rbxassetid://6034744037",
	["event"] = "rbxassetid://6023426959",
	["event_available"] = "rbxassetid://6034439643",
	["event_busy"] = "rbxassetid://6034439634",
	["event_note"] = "rbxassetid://6034439637",
	["exit_to_app"] = "rbxassetid://6023426922",
	["expand"] = "rbxassetid://6022668891",
	["expand_less"] = "rbxassetid://6031094679",
	["expand_more"] = "rbxassetid://6031094687",
	["explicit"] = "rbxassetid://6026647913",
	["explore"] = "rbxassetid://6023426941",
	["explore_off"] = "rbxassetid://6023426953",
	["exposure"] = "rbxassetid://6034328962",
	["exposure_neg_1"] = "rbxassetid://6034328957",
	["exposure_neg_2"] = "rbxassetid://6034328973",
	["exposure_plus_1"] = "rbxassetid://6034328970",
	["exposure_plus_2"] = "rbxassetid://6034328961",
	["exposure_zero"] = "rbxassetid://6034329000",
	["extension"] = "rbxassetid://6023565892",
	["face"] = "rbxassetid://6023426944",
	["face_retouching_natural"] = "rbxassetid://6034333274",
	["facebook"] = "rbxassetid://6034281898",
	["fact_check"] = "rbxassetid://6023426951",
	["family_restroom"] = "rbxassetid://6035121916",
	["fast_forward"] = "rbxassetid://6026647902",
	["fast_rewind"] = "rbxassetid://6026647942",
	["fastfood"] = "rbxassetid://6034744034",
	["favorite"] = "rbxassetid://6023426974",
	["favorite_border"] = "rbxassetid://6023565882",
	["featured_play_list"] = "rbxassetid://6026647932",
	["featured_video"] = "rbxassetid://6026647910",
	["feedback"] = "rbxassetid://6023426957",
	["fence"] = "rbxassetid://6035121923",
	["festival"] = "rbxassetid://6034744031",
	["fiber_dvr"] = "rbxassetid://6026647912",
	["fiber_manual_record"] = "rbxassetid://6026647909",
	["fiber_new"] = "rbxassetid://6026647930",
	["fiber_pin"] = "rbxassetid://6026660064",
	["fiber_smart_record"] = "rbxassetid://6026660080",
	["file_copy"] = "rbxassetid://6035053293",
	["file_download"] = "rbxassetid://6031302931",
	["file_download_done"] = "rbxassetid://6031302926",
	["file_upload"] = "rbxassetid://6031302996",
	["filter"] = "rbxassetid://6031597514",
	["filter_1"] = "rbxassetid://6031597511",
	["filter_2"] = "rbxassetid://6031597521",
	["filter_3"] = "rbxassetid://6031597513",
	["filter_4"] = "rbxassetid://6031597512",
	["filter_5"] = "rbxassetid://6031597518",
	["filter_6"] = "rbxassetid://6031597524",
	["filter_7"] = "rbxassetid://6031597515",
	["filter_8"] = "rbxassetid://6031597532",
	["filter_9"] = "rbxassetid://6031597534",
	["filter_9_plus"] = "rbxassetid://6031600812",
	["filter_alt"] = "rbxassetid://6023426984",
	["filter_b_and_w"] = "rbxassetid://6031600824",
	["filter_center_focus"] = "rbxassetid://6031600817",
	["filter_drama"] = "rbxassetid://6031600813",
	["filter_frames"] = "rbxassetid://6031600833",
	["filter_hdr"] = "rbxassetid://6031600819",
	["filter_list"] = "rbxassetid://6035053294",
	["filter_list_alt"] = "rbxassetid://6023426955",
	["filter_none"] = "rbxassetid://6031600815",
	["filter_tilt_shift"] = "rbxassetid://6031600814",
	["filter_vintage"] = "rbxassetid://6031600811",
	["find_in_page"] = "rbxassetid://6023426986",
	["find_replace"] = "rbxassetid://6023426979",
	["fingerprint"] = "rbxassetid://6023565895",
	["fire_extinguisher"] = "rbxassetid://6035121913",
	["fireplace"] = "rbxassetid://6034281910",
	["first_page"] = "rbxassetid://6031094682",
	["fitness_center"] = "rbxassetid://6035121907",
	["flag"] = "rbxassetid://6035053279",
	["flaky"] = "rbxassetid://6031082523",
	["flare"] = "rbxassetid://6031600816",
	["flash_auto"] = "rbxassetid://6034333287",
	["flash_off"] = "rbxassetid://6034333270",
	["flash_on"] = "rbxassetid://6034333271",
	["flight"] = "rbxassetid://6034744030",
	["flight_land"] = "rbxassetid://6023565897",
	["flight_takeoff"] = "rbxassetid://6023565891",
	["flip"] = "rbxassetid://6034333275",
	["flip_camera_android"] = "rbxassetid://6034333280",
	["flip_camera_ios"] = "rbxassetid://6034333267",
	["flip_to_back"] = "rbxassetid://6023565896",
	["flip_to_front"] = "rbxassetid://6023565894",
	["folder"] = "rbxassetid://6031302932",
	["folder_open"] = "rbxassetid://6031302934",
	["folder_shared"] = "rbxassetid://6031302945",
	["folder_special"] = "rbxassetid://6034439639",
	["follow_the_signs"] = "rbxassetid://6034281911",
	["font_download"] = "rbxassetid://6035053275",
	["food_bank"] = "rbxassetid://6035121921",
	["format_align_center"] = "rbxassetid://6034900718",
	["format_align_justify"] = "rbxassetid://6034900721",
	["format_align_left"] = "rbxassetid://6034900727",
	["format_align_right"] = "rbxassetid://6034900723",
	["format_bold"] = "rbxassetid://6034900732",
	["format_clear"] = "rbxassetid://6034910902",
	["format_color_fill"] = "rbxassetid://6034910903",
	["format_color_reset"] = "rbxassetid://6034900743",
	["format_color_text"] = "rbxassetid://6034910910",
	["format_indent_decrease"] = "rbxassetid://6034900733",
	["format_indent_increase"] = "rbxassetid://6034900724",
	["format_italic"] = "rbxassetid://6034910912",
	["format_line_spacing"] = "rbxassetid://6034910905",
	["format_list_bulleted"] = "rbxassetid://6034925620",
	["format_list_numbered"] = "rbxassetid://6034925622",
	["format_list_numbered_rtl"] = "rbxassetid://6034910906",
	["format_paint"] = "rbxassetid://6034925618",
	["format_quote"] = "rbxassetid://6034925629",
	["format_shapes"] = "rbxassetid://6034910909",
	["format_size"] = "rbxassetid://6034910908",
	["format_strikethrough"] = "rbxassetid://6034910904",
	["format_textdirection_l_to_r"] = "rbxassetid://6034925619",
	["format_textdirection_r_to_l"] = "rbxassetid://6034925623",
	["format_underlined"] = "rbxassetid://6034925627",
	["forum"] = "rbxassetid://6035202002",
	["forward"] = "rbxassetid://6035053298",
	["forward_10"] = "rbxassetid://6026660062",
	["forward_30"] = "rbxassetid://6026660088",
	["forward_5"] = "rbxassetid://6026660067",
	["forward_to_inbox"] = "rbxassetid://6035190840",
	["foundation"] = "rbxassetid://6035121918",
	["free_breakfast"] = "rbxassetid://6035145363",
	["fullscreen"] = "rbxassetid://6031094681",
	["fullscreen_exit"] = "rbxassetid://6031094691",
	["functions"] = "rbxassetid://6034925614",
	["g_translate"] = "rbxassetid://6031082526",
	["gamepad"] = "rbxassetid://6034789879",
	["games"] = "rbxassetid://6026660074",
	["gavel"] = "rbxassetid://6023565902",
	["gesture"] = "rbxassetid://6035053287",
	["get_app"] = "rbxassetid://6023565889",
	["gif"] = "rbxassetid://6031082540",
	["golf_course"] = "rbxassetid://6035145423",
	["gps_fixed"] = "rbxassetid://6034989550",
	["gps_not_fixed"] = "rbxassetid://6034989547",
	["gps_off"] = "rbxassetid://6034989548",
	["grade"] = "rbxassetid://6026568189",
	["gradient"] = "rbxassetid://6034333261",
	["grading"] = "rbxassetid://6026568191",
	["grain"] = "rbxassetid://6034333288",
	["graphic_eq"] = "rbxassetid://6034989551",
	["grass"] = "rbxassetid://6035145359",
	["grid_off"] = "rbxassetid://6034333286",
	["grid_on"] = "rbxassetid://6034333276",
	["grid_view"] = "rbxassetid://6031302950",
	["group"] = "rbxassetid://6034281901",
	["group_add"] = "rbxassetid://6034281909",
	["group_work"] = "rbxassetid://6023565910",
	["groups"] = "rbxassetid://6034281935",
	["hail"] = "rbxassetid://6034744033",
	["handyman"] = "rbxassetid://6034744057",
	["hardware"] = "rbxassetid://6034744036",
	["hd"] = "rbxassetid://6026660065",
	["hdr_enhanced_select"] = "rbxassetid://6034333281",
	["hdr_off"] = "rbxassetid://6034333266",
	["hdr_on"] = "rbxassetid://6034333279",
	["hdr_strong"] = "rbxassetid://6034333272",
	["hdr_weak"] = "rbxassetid://6034407083",
	["headset"] = "rbxassetid://6034789880",
	["headset_mic"] = "rbxassetid://6034818383",
	["headset_off"] = "rbxassetid://6034818402",
	["healing"] = "rbxassetid://6034407071",
	["hearing"] = "rbxassetid://6026660060",
	["hearing_disabled"] = "rbxassetid://6026660068",
	["height"] = "rbxassetid://6034925613",
	["help_center"] = "rbxassetid://6026568192",
	["help_outline"] = "rbxassetid://6026568201",
	["high_quality"] = "rbxassetid://6026660059",
	["highlight"] = "rbxassetid://6034925617",
	["highlight_alt"] = "rbxassetid://6023565913",
	["highlight_off"] = "rbxassetid://6023565916",
	["history"] = "rbxassetid://6026568197",
	["history_edu"] = "rbxassetid://6034281934",
	["history_toggle_off"] = "rbxassetid://6026568196",
	["home"] = "rbxassetid://6026568195",
	["home_filled"] = "rbxassetid://6026568198",
	["home_repair_service"] = "rbxassetid://6034744064",
	["home_work"] = "rbxassetid://6031094683",
	["horizontal_rule"] = "rbxassetid://6034925610",
	["horizontal_split"] = "rbxassetid://6026568194",
	["hot_tub"] = "rbxassetid://6035145382",
	["hotel"] = "rbxassetid://6034687977",
	["hourglass_bottom"] = "rbxassetid://6035202043",
	["hourglass_disabled"] = "rbxassetid://6026568193",
	["hourglass_full"] = "rbxassetid://6026568190",
	["hourglass_top"] = "rbxassetid://6035190886",
	["house"] = "rbxassetid://6035145364",
	["house_siding"] = "rbxassetid://6035145393",
	["how_to_reg"] = "rbxassetid://6035053288",
	["how_to_vote"] = "rbxassetid://6035053295",
	["https"] = "rbxassetid://6026568200",
	["hvac"] = "rbxassetid://6034687960",
	["icecream"] = "rbxassetid://6034687967",
	["image"] = "rbxassetid://6034407078",
	["image_aspect_ratio"] = "rbxassetid://6034407073",
	["image_not_supported"] = "rbxassetid://6034407076",
	["image_search"] = "rbxassetid://6034407084",
	["imagesearch_roller"] = "rbxassetid://6034439635",
	["import_contacts"] = "rbxassetid://6035190854",
	["import_export"] = "rbxassetid://6035202040",
	["important_devices"] = "rbxassetid://6026568202",
	["inbox"] = "rbxassetid://6035067831",
	["indeterminate_check_box"] = "rbxassetid://6031068445",
	["info"] = "rbxassetid://6026568227",
	["info_outline"] = "rbxassetid://6026568210",
	["input"] = "rbxassetid://6026568225",
	["insert_chart"] = "rbxassetid://6034925628",
	["insert_chart_outlined"] = "rbxassetid://6034925606",
	["insert_comment"] = "rbxassetid://6034925609",
	["insert_drive_file"] = "rbxassetid://6034941697",
	["insert_emoticon"] = "rbxassetid://6034973079",
	["insert_invitation"] = "rbxassetid://6034973091",
	["insert_link"] = "rbxassetid://6034973074",
	["insert_photo"] = "rbxassetid://6034941703",
	["insights"] = "rbxassetid://6035067839",
	["integration_instructions"] = "rbxassetid://6026568214",
	["inventory"] = "rbxassetid://6035056487",
	["invert_colors"] = "rbxassetid://6026568253",
	["invert_colors_off"] = "rbxassetid://6035190842",
	["ios_share"] = "rbxassetid://6034281941",
	["iso"] = "rbxassetid://6034407106",
	["keyboard"] = "rbxassetid://6034818398",
	["keyboard_arrow_down"] = "rbxassetid://6034818372",
	["keyboard_arrow_left"] = "rbxassetid://6034818375",
	["keyboard_arrow_right"] = "rbxassetid://6034818365",
	["keyboard_arrow_up"] = "rbxassetid://6034818379",
	["keyboard_backspace"] = "rbxassetid://6034818381",
	["keyboard_capslock"] = "rbxassetid://6034818403",
	["keyboard_hide"] = "rbxassetid://6034818386",
	["keyboard_return"] = "rbxassetid://6034818370",
	["keyboard_tab"] = "rbxassetid://6034818363",
	["keyboard_voice"] = "rbxassetid://6034818360",
	["king_bed"] = "rbxassetid://6034281948",
	["kitchen"] = "rbxassetid://6035145362",
	["label"] = "rbxassetid://6031082525",
	["label_important"] = "rbxassetid://6026568215",
	["label_important_outline"] = "rbxassetid://6026568199",
	["label_off"] = "rbxassetid://6026568209",
	["label_outline"] = "rbxassetid://6026568207",
	["landscape"] = "rbxassetid://6034407069",
	["language"] = "rbxassetid://6026568213",
	["laptop"] = "rbxassetid://6034818367",
	["laptop_chromebook"] = "rbxassetid://6034818364",
	["laptop_mac"] = "rbxassetid://6034837808",
	["laptop_windows"] = "rbxassetid://6034837796",
	["last_page"] = "rbxassetid://6031094686",
	["launch"] = "rbxassetid://6026568211",
	["layers"] = "rbxassetid://6034687957",
	["layers_clear"] = "rbxassetid://6034687975",
	["leaderboard"] = "rbxassetid://6026568216",
	["leak_add"] = "rbxassetid://6034407074",
	["leak_remove"] = "rbxassetid://6034407080",
	["legend_toggle"] = "rbxassetid://6031097233",
	["lens"] = "rbxassetid://6034407081",
	["library_add"] = "rbxassetid://6026660063",
	["library_add_check"] = "rbxassetid://6026660083",
	["library_books"] = "rbxassetid://6026660085",
	["library_music"] = "rbxassetid://6026660075",
	["lightbulb"] = "rbxassetid://6026568247",
	["lightbulb_outline"] = "rbxassetid://6026568254",
	["line_style"] = "rbxassetid://6026568276",
	["line_weight"] = "rbxassetid://6026568226",
	["linear_scale"] = "rbxassetid://6034941707",
	["link"] = "rbxassetid://6035056475",
	["link_off"] = "rbxassetid://6035056484",
	["linked_camera"] = "rbxassetid://6034407082",
	["list"] = "rbxassetid://6026568229",
	["list_alt"] = "rbxassetid://6035190838",
	["live_help"] = "rbxassetid://6035190836",
	["live_tv"] = "rbxassetid://6034439648",
	["local_activity"] = "rbxassetid://6034687955",
	["local_airport"] = "rbxassetid://6034687951",
	["local_atm"] = "rbxassetid://6034687953",
	["local_bar"] = "rbxassetid://6034687950",
	["local_cafe"] = "rbxassetid://6034687954",
	["local_car_wash"] = "rbxassetid://6034687976",
	["local_convenience_store"] = "rbxassetid://6034687956",
	["local_dining"] = "rbxassetid://6034687963",
	["local_drink"] = "rbxassetid://6034687965",
	["local_fire_department"] = "rbxassetid://6034684949",
	["local_florist"] = "rbxassetid://6034684940",
	["local_gas_station"] = "rbxassetid://6034684935",
	["local_grocery_store"] = "rbxassetid://6034684933",
	["local_hospital"] = "rbxassetid://6034684956",
	["local_hotel"] = "rbxassetid://6034684939",
	["local_laundry_service"] = "rbxassetid://6034684943",
	["local_library"] = "rbxassetid://6034684931",
	["local_mall"] = "rbxassetid://6034684934",
	["local_movies"] = "rbxassetid://6034684936",
	["local_offer"] = "rbxassetid://6034513891",
	["local_parking"] = "rbxassetid://6034513893",
	["local_pharmacy"] = "rbxassetid://6034513903",
	["local_phone"] = "rbxassetid://6034513884",
	["local_pizza"] = "rbxassetid://6034513885",
	["local_play"] = "rbxassetid://6034513889",
	["local_police"] = "rbxassetid://6034513895",
	["local_post_office"] = "rbxassetid://6034513883",
	["local_printshop"] = "rbxassetid://6034513897",
	["local_see"] = "rbxassetid://6034513887",
	["local_shipping"] = "rbxassetid://6034684926",
	["local_taxi"] = "rbxassetid://6034684927",
	["location_city"] = "rbxassetid://6034304889",
	["location_disabled"] = "rbxassetid://6034996694",
	["location_off"] = "rbxassetid://6035202049",
	["location_on"] = "rbxassetid://6035190846",
	["location_pin"] = "rbxassetid://6034684937",
	["location_searching"] = "rbxassetid://6034996695",
	["lock"] = "rbxassetid://6026568224",
	["lock_clock"] = "rbxassetid://6026568260",
	["lock_open"] = "rbxassetid://6026568220",
	["lock_outline"] = "rbxassetid://6031082533",
	["login"] = "rbxassetid://6031082527",
	["logout"] = "rbxassetid://6031082522",
	["looks"] = "rbxassetid://6034407096",
	["looks_3"] = "rbxassetid://6034407088",
	["looks_4"] = "rbxassetid://6034407089",
	["looks_5"] = "rbxassetid://6034412764",
	["looks_6"] = "rbxassetid://6034412759",
	["looks_one"] = "rbxassetid://6034412761",
	["looks_two"] = "rbxassetid://6034412757",
	["loop"] = "rbxassetid://6026660087",
	["loupe"] = "rbxassetid://6034412770",
	["low_priority"] = "rbxassetid://6035056491",
	["loyalty"] = "rbxassetid://6026568237",
	["luggage"] = "rbxassetid://6034295708",
	["lunch_dining"] = "rbxassetid://6034684928",
	["mail"] = "rbxassetid://6035056477",
	["mail_outline"] = "rbxassetid://6035190844",
	["map"] = "rbxassetid://6034684930",
	["maps_ugc"] = "rbxassetid://6034509992",
	["margin"] = "rbxassetid://6034941701",
	["mark_as_unread"] = "rbxassetid://6026568223",
	["mark_chat_read"] = "rbxassetid://6035202031",
	["mark_chat_unread"] = "rbxassetid://6035190841",
	["mark_email_read"] = "rbxassetid://6035202038",
	["mark_email_unread"] = "rbxassetid://6035202027",
	["markunread"] = "rbxassetid://6035056476",
	["markunread_mailbox"] = "rbxassetid://6031082531",
	["masks"] = "rbxassetid://6034295710",
	["maximize"] = "rbxassetid://6026568267",
	["mediation"] = "rbxassetid://6026568249",
	["medical_services"] = "rbxassetid://6034510001",
	["meeting_room"] = "rbxassetid://6035145361",
	["memory"] = "rbxassetid://6034837807",
	["menu"] = "rbxassetid://6031097225",
	["menu_book"] = "rbxassetid://6034509994",
	["menu_open"] = "rbxassetid://6031097229",
	["merge_type"] = "rbxassetid://6034941705",
	["message"] = "rbxassetid://6035202033",
	["mic"] = "rbxassetid://6026660078",
	["mic_external_off"] = "rbxassetid://6034323672",
	["mic_external_on"] = "rbxassetid://6034323671",
	["mic_none"] = "rbxassetid://6026660066",
	["mic_off"] = "rbxassetid://6026660076",
	["microwave"] = "rbxassetid://6035145367",
	["military_tech"] = "rbxassetid://6034295711",
	["minimize"] = "rbxassetid://6026568240",
	["miscellaneous_services"] = "rbxassetid://6034509993",
	["mms"] = "rbxassetid://6034461621",
	["mobile_friendly"] = "rbxassetid://6034996699",
	["mobile_off"] = "rbxassetid://6034996702",
	["mobile_screen_share"] = "rbxassetid://6035202021",
	["mode_comment"] = "rbxassetid://6034941700",
	["mode_edit"] = "rbxassetid://6034941708",
	["model_training"] = "rbxassetid://6026568222",
	["monetization_on"] = "rbxassetid://6034973115",
	["money"] = "rbxassetid://6034509997",
	["money_off"] = "rbxassetid://6034973088",
	["monitor"] = "rbxassetid://6034837803",
	["monochrome_photos"] = "rbxassetid://6034323678",
	["mood"] = "rbxassetid://6034295704",
	["mood_bad"] = "rbxassetid://6034295706",
	["moped"] = "rbxassetid://6034509999",
	["more"] = "rbxassetid://6034461627",
	["more_horiz"] = "rbxassetid://6031104650",
	["more_time"] = "rbxassetid://6035202036",
	["more_vert"] = "rbxassetid://6031104648",
	["motion_photos_off"] = "rbxassetid://6034323670",
	["motion_photos_on"] = "rbxassetid://6034323669",
	["motion_photos_pause"] = "rbxassetid://6034323668",
	["motion_photos_paused"] = "rbxassetid://6034323675",
	["mouse"] = "rbxassetid://6034837797",
	["move_to_inbox"] = "rbxassetid://6035067838",
	["movie"] = "rbxassetid://6026660081",
	["movie_creation"] = "rbxassetid://6034323681",
	["movie_filter"] = "rbxassetid://6034323687",
	["mp"] = "rbxassetid://6034323674",
	["multiline_chart"] = "rbxassetid://6034941721",
	["multiple_stop"] = "rbxassetid://6034510026",
	["museum"] = "rbxassetid://6034510005",
	["music_note"] = "rbxassetid://6034323673",
	["music_off"] = "rbxassetid://6034323679",
	["music_video"] = "rbxassetid://6026663704",
	["my_location"] = "rbxassetid://6034509987",
	["nat"] = "rbxassetid://6035202082",
	["nature"] = "rbxassetid://6034323695",
	["nature_people"] = "rbxassetid://6034323711",
	["navigate_before"] = "rbxassetid://6034323696",
	["navigate_next"] = "rbxassetid://6034315956",
	["navigation"] = "rbxassetid://6034509984",
	["near_me"] = "rbxassetid://6034509996",
	["near_me_disabled"] = "rbxassetid://6034509988",
	["network_cell"] = "rbxassetid://6034996709",
	["network_check"] = "rbxassetid://6034461631",
	["network_locked"] = "rbxassetid://6034457064",
	["network_wifi"] = "rbxassetid://6034996712",
	["new_releases"] = "rbxassetid://6026663730",
	["next_plan"] = "rbxassetid://6026568231",
	["next_week"] = "rbxassetid://6035067835",
	["nfc"] = "rbxassetid://6034996698",
	["night_shelter"] = "rbxassetid://6035145378",
	["nightlife"] = "rbxassetid://6034510003",
	["nightlight_round"] = "rbxassetid://6031084743",
	["nights_stay"] = "rbxassetid://6034304881",
	["no_backpack"] = "rbxassetid://6035145368",
	["no_cell"] = "rbxassetid://6035145376",
	["no_drinks"] = "rbxassetid://6035145390",
	["no_encryption"] = "rbxassetid://6034457059",
	["no_flash"] = "rbxassetid://6035145424",
	["no_food"] = "rbxassetid://6035145372",
	["no_luggage"] = "rbxassetid://6034304891",
	["no_meals"] = "rbxassetid://6034510024",
	["no_meals_ouline"] = "rbxassetid://6034510025",
	["no_meeting_room"] = "rbxassetid://6035153649",
	["no_photography"] = "rbxassetid://6035153664",
	["no_sim"] = "rbxassetid://6035202030",
	["no_stroller"] = "rbxassetid://6035153661",
	["no_transfer"] = "rbxassetid://6034503363",
	["north_east"] = "rbxassetid://6031097228",
	["north_west"] = "rbxassetid://6031104630",
	["not_accessible"] = "rbxassetid://6026568269",
	["not_interested"] = "rbxassetid://6026663743",
	["not_listed_location"] = "rbxassetid://6034503380",
	["not_started"] = "rbxassetid://6026568232",
	["note"] = "rbxassetid://6026663734",
	["note_add"] = "rbxassetid://6031084749",
	["notes"] = "rbxassetid://6034973084",
	["notifications"] = "rbxassetid://6034308946",
	["notifications_active"] = "rbxassetid://6034304908",
	["notifications_none"] = "rbxassetid://6034308947",
	["notifications_off"] = "rbxassetid://6034304894",
	["notifications_paused"] = "rbxassetid://6034304896",
	["offline_bolt"] = "rbxassetid://6031084742",
	["offline_pin"] = "rbxassetid://6031084770",
	["offline_share"] = "rbxassetid://6031097267",
	["ondemand_video"] = "rbxassetid://6034457065",
	["online_prediction"] = "rbxassetid://6026568239",
	["opacity"] = "rbxassetid://6026568295",
	["open_in_browser"] = "rbxassetid://6026568266",
	["open_in_full"] = "rbxassetid://6026568245",
	["open_in_new"] = "rbxassetid://6026568256",
	["open_with"] = "rbxassetid://6026568265",
	["outbond"] = "rbxassetid://6026568244",
	["outbox"] = "rbxassetid://6026568263",
	["outdoor_grill"] = "rbxassetid://6034304900",
	["outgoing_mail"] = "rbxassetid://6026568242",
	["outlet"] = "rbxassetid://6031084748",
	["outlined_flag"] = "rbxassetid://6035056486",
	["padding"] = "rbxassetid://6034973078",
	["pages"] = "rbxassetid://6034304892",
	["pageview"] = "rbxassetid://6031216007",
	["palette"] = "rbxassetid://6034316009",
	["pan_tool"] = "rbxassetid://6031084771",
	["panorama"] = "rbxassetid://6034315955",
	["panorama_fish_eye"] = "rbxassetid://6034315969",
	["panorama_horizontal"] = "rbxassetid://6034315966",
	["panorama_horizontal_select"] = "rbxassetid://6034315965",
	["panorama_photosphere"] = "rbxassetid://6034412763",
	["panorama_photosphere_select"] = "rbxassetid://6034315975",
	["panorama_vertical"] = "rbxassetid://6034315963",
	["panorama_vertical_select"] = "rbxassetid://6034315961",
	["panorama_wide_angle"] = "rbxassetid://6031770995",
	["panorama_wide_angle_select"] = "rbxassetid://6031770990",
	["park"] = "rbxassetid://6034503369",
	["party_mode"] = "rbxassetid://6034287521",
	["pause"] = "rbxassetid://6026663719",
	["pause_circle_filled"] = "rbxassetid://6026663718",
	["pause_circle_outline"] = "rbxassetid://6026663701",
	["pause_presentation"] = "rbxassetid://6035202015",
	["payment"] = "rbxassetid://6031084751",
	["payments"] = "rbxassetid://6031097227",
	["pedal_bike"] = "rbxassetid://6034503374",
	["pending"] = "rbxassetid://6031084745",
	["pending_actions"] = "rbxassetid://6031260777",
	["people"] = "rbxassetid://6034287513",
	["people_alt"] = "rbxassetid://6034287518",
	["people_outline"] = "rbxassetid://6034287528",
	["perm_camera_mic"] = "rbxassetid://6031215983",
	["perm_contact_calendar"] = "rbxassetid://6031215990",
	["perm_data_setting"] = "rbxassetid://6031215991",
	["perm_device_information"] = "rbxassetid://6031215996",
	["perm_identity"] = "rbxassetid://6031215978",
	["perm_media"] = "rbxassetid://6031215982",
	["perm_phone_msg"] = "rbxassetid://6031215986",
	["perm_scan_wifi"] = "rbxassetid://6031215985",
	["person"] = "rbxassetid://6034287594",
	["person_add"] = "rbxassetid://6034287514",
	["person_add_alt"] = "rbxassetid://6034267994",
	["person_add_alt_1"] = "rbxassetid://6034287519",
	["person_add_disabled"] = "rbxassetid://6035202007",
	["person_outline"] = "rbxassetid://6034268008",
	["person_pin"] = "rbxassetid://6034503364",
	["person_pin_circle"] = "rbxassetid://6034503375",
	["person_remove"] = "rbxassetid://6034267996",
	["person_remove_alt_1"] = "rbxassetid://6034287515",
	["person_search"] = "rbxassetid://6035202013",
	["personal_video"] = "rbxassetid://6034457070",
	["pest_control"] = "rbxassetid://6034470809",
	["pest_control_rodent"] = "rbxassetid://6034470803",
	["pets"] = "rbxassetid://6031260782",
	["phone"] = "rbxassetid://6035202017",
	["phone_android"] = "rbxassetid://6034837793",
	["phone_bluetooth_speaker"] = "rbxassetid://6034457057",
	["phone_callback"] = "rbxassetid://6034457104",
	["phone_disabled"] = "rbxassetid://6035202028",
	["phone_enabled"] = "rbxassetid://6035202089",
	["phone_forwarded"] = "rbxassetid://6034457106",
	["phone_in_talk"] = "rbxassetid://6034457067",
	["phone_iphone"] = "rbxassetid://6034837811",
	["phone_locked"] = "rbxassetid://6034457058",
	["phone_missed"] = "rbxassetid://6034457056",
	["phone_paused"] = "rbxassetid://6034457066",
	["phonelink"] = "rbxassetid://6034837801",
	["phonelink_erase"] = "rbxassetid://6035202085",
	["phonelink_lock"] = "rbxassetid://6035202064",
	["phonelink_off"] = "rbxassetid://6034837804",
	["phonelink_ring"] = "rbxassetid://6035202066",
	["phonelink_setup"] = "rbxassetid://6035202025",
	["photo"] = "rbxassetid://6031770993",
	["photo_album"] = "rbxassetid://6031770989",
	["photo_camera"] = "rbxassetid://6031770997",
	["photo_camera_back"] = "rbxassetid://6031771007",
	["photo_camera_front"] = "rbxassetid://6031771000",
	["photo_filter"] = "rbxassetid://6031770992",
	["photo_library"] = "rbxassetid://6031770998",
	["photo_size_select_actual"] = "rbxassetid://6031771012",
	["photo_size_select_large"] = "rbxassetid://6031763423",
	["photo_size_select_small"] = "rbxassetid://6031763457",
	["picture_as_pdf"] = "rbxassetid://6031763425",
	["picture_in_picture"] = "rbxassetid://6031215994",
	["picture_in_picture_alt"] = "rbxassetid://6031215979",
	["pie_chart"] = "rbxassetid://6034973076",
	["pie_chart_outlined"] = "rbxassetid://6034973077",
	["pin_drop"] = "rbxassetid://6034470807",
	["pivot_table_chart"] = "rbxassetid://6031097234",
	["place"] = "rbxassetid://6034503372",
	["plagiarism"] = "rbxassetid://6031243320",
	["play_arrow"] = "rbxassetid://6026663699",
	["play_circle_filled"] = "rbxassetid://6026663705",
	["play_circle_outline"] = "rbxassetid://6026663726",
	["play_disabled"] = "rbxassetid://6026663702",
	["play_for_work"] = "rbxassetid://6031260776",
	["playlist_add"] = "rbxassetid://6026663728",
	["playlist_add_check"] = "rbxassetid://6026663727",
	["playlist_play"] = "rbxassetid://6026663723",
	["plumbing"] = "rbxassetid://6034470800",
	["plus_one"] = "rbxassetid://6034268012",
	["point_of_sale"] = "rbxassetid://6034837798",
	["policy"] = "rbxassetid://6035056512",
	["poll"] = "rbxassetid://6034267991",
	["polymer"] = "rbxassetid://6031260785",
	["pool"] = "rbxassetid://6035153655",
	["portable_wifi_off"] = "rbxassetid://6035202091",
	["portrait"] = "rbxassetid://6031763434",
	["post_add"] = "rbxassetid://6034973083",
	["power"] = "rbxassetid://6034457105",
	["power_input"] = "rbxassetid://6034837794",
	["power_off"] = "rbxassetid://6034457087",
	["power_settings_new"] = "rbxassetid://6031260781",
	["present_to_all"] = "rbxassetid://6035202020",
	["preview"] = "rbxassetid://6031260793",
	["print"] = "rbxassetid://6031243324",
	["print_disabled"] = "rbxassetid://6035202041",
	["priority_high"] = "rbxassetid://6034457092",
	["privacy_tip"] = "rbxassetid://6031260784",
	["psychology"] = "rbxassetid://6034287516",
	["public"] = "rbxassetid://6034287522",
	["public_off"] = "rbxassetid://6034287538",
	["publish"] = "rbxassetid://6034973085",
	["published_with_changes"] = "rbxassetid://6031243328",
	["push_pin"] = "rbxassetid://6035056481",
	["qr_code"] = "rbxassetid://6035202012",
	["qr_code_scanner"] = "rbxassetid://6035202022",
	["query_builder"] = "rbxassetid://6031086183",
	["question_answer"] = "rbxassetid://6031086172",
	["queue"] = "rbxassetid://6026663724",
	["queue_music"] = "rbxassetid://6026663725",
	["queue_play_next"] = "rbxassetid://6026663700",
	["quickreply"] = "rbxassetid://6031243319",
	["radio"] = "rbxassetid://6026663698",
	["radio_button_checked"] = "rbxassetid://6031068426",
	["radio_button_unchecked"] = "rbxassetid://6031068433",
	["railway_alert"] = "rbxassetid://6034470823",
	["ramen_dining"] = "rbxassetid://6034503377",
	["rate_review"] = "rbxassetid://6034503385",
	["read_more"] = "rbxassetid://6035202014",
	["receipt"] = "rbxassetid://6031086173",
	["receipt_long"] = "rbxassetid://6031763428",
	["recent_actors"] = "rbxassetid://6026663773",
	["recommend"] = "rbxassetid://6034287524",
	["record_voice_over"] = "rbxassetid://6031243318",
	["redeem"] = "rbxassetid://6031086170",
	["redo"] = "rbxassetid://6035056483",
	["reduce_capacity"] = "rbxassetid://6034268013",
	["refresh"] = "rbxassetid://6031097226",
	["remove"] = "rbxassetid://6035067836",
	["remove_circle"] = "rbxassetid://6035067837",
	["remove_circle_outline"] = "rbxassetid://6035067843",
	["remove_done"] = "rbxassetid://6031086169",
	["remove_from_queue"] = "rbxassetid://6026663771",
	["remove_moderator"] = "rbxassetid://6034267998",
	["remove_red_eye"] = "rbxassetid://6031763426",
	["remove_shopping_cart"] = "rbxassetid://6031260778",
	["reorder"] = "rbxassetid://6031154868",
	["repeat"] = "rbxassetid://6026666998",
	["repeat_on"] = "rbxassetid://6026666994",
	["repeat_one"] = "rbxassetid://6026681590",
	["repeat_one_on"] = "rbxassetid://6026666992",
	["replay"] = "rbxassetid://6026666999",
	["replay_10"] = "rbxassetid://6026667007",
	["replay_30"] = "rbxassetid://6026667010",
	["replay_5"] = "rbxassetid://6026666993",
	["replay_circle_filled"] = "rbxassetid://6026667002",
	["reply"] = "rbxassetid://6035067844",
	["reply_all"] = "rbxassetid://6035067824",
	["report"] = "rbxassetid://6035067826",
	["report_off"] = "rbxassetid://6035067830",
	["report_problem"] = "rbxassetid://6031086176",
	["request_page"] = "rbxassetid://6031154873",
	["request_quote"] = "rbxassetid://6031302941",
	["reset_tv"] = "rbxassetid://6034996696",
	["restaurant"] = "rbxassetid://6034503366",
	["restaurant_menu"] = "rbxassetid://6034503378",
	["restore"] = "rbxassetid://6031260800",
	["restore_from_trash"] = "rbxassetid://6031154869",
	["restore_page"] = "rbxassetid://6031154877",
	["rice_bowl"] = "rbxassetid://6035153662",
	["ring_volume"] = "rbxassetid://6035202032",
	["roofing"] = "rbxassetid://6035153656",
	["room"] = "rbxassetid://6031154875",
	["room_preferences"] = "rbxassetid://6035153642",
	["room_service"] = "rbxassetid://6035153648",
	["rotate_90_degrees_ccw"] = "rbxassetid://6031763456",
	["rotate_left"] = "rbxassetid://6031763427",
	["rotate_right"] = "rbxassetid://6031763429",
	["rounded_corner"] = "rbxassetid://6031154861",
	["router"] = "rbxassetid://6034837806",
	["rowing"] = "rbxassetid://6031154857",
	["rss_feed"] = "rbxassetid://6035202016",
	["rtt"] = "rbxassetid://6035202010",
	["rule"] = "rbxassetid://6031154859",
	["rule_folder"] = "rbxassetid://6031302940",
	["run_circle"] = "rbxassetid://6034503367",
	["sanitizer"] = "rbxassetid://6034287586",
	["satellite"] = "rbxassetid://6034503370",
	["save"] = "rbxassetid://6035067857",
	["save_alt"] = "rbxassetid://6035067842",
	["saved_search"] = "rbxassetid://6031154867",
	["scanner"] = "rbxassetid://6034837799",
	["scatter_plot"] = "rbxassetid://6034973094",
	["schedule"] = "rbxassetid://6031260808",
	["schedule_send"] = "rbxassetid://6031154866",
	["school"] = "rbxassetid://6034230641",
	["science"] = "rbxassetid://6034230640",
	["score"] = "rbxassetid://6034934041",
	["screen_lock_landscape"] = "rbxassetid://6034996700",
	["screen_lock_portrait"] = "rbxassetid://6034996706",
	["screen_lock_rotation"] = "rbxassetid://6034996710",
	["screen_rotation"] = "rbxassetid://6034996701",
	["screen_search_desktop"] = "rbxassetid://6034996711",
	["screen_share"] = "rbxassetid://6035202008",
	["sd"] = "rbxassetid://6026681582",
	["sd_card"] = "rbxassetid://6034457089",
	["sd_storage"] = "rbxassetid://6034996719",
	["search"] = "rbxassetid://6031154871",
	["search_off"] = "rbxassetid://6031260783",
	["security"] = "rbxassetid://6034837802",
	["segment"] = "rbxassetid://6031260773",
	["select_all"] = "rbxassetid://6035067834",
	["self_improvement"] = "rbxassetid://6034230634",
	["send"] = "rbxassetid://6035067832",
	["send_and_archive"] = "rbxassetid://6031280889",
	["send_to_mobile"] = "rbxassetid://6034996697",
	["sensor_door"] = "rbxassetid://6031067241",
	["sensor_window"] = "rbxassetid://6031067242",
	["sentiment_dissatisfied"] = "rbxassetid://6034230637",
	["sentiment_neutral"] = "rbxassetid://6034230636",
	["sentiment_satisfied"] = "rbxassetid://6034230668",
	["sentiment_satisfied_alt"] = "rbxassetid://6035202069",
	["sentiment_very_dissatisfied"] = "rbxassetid://6034230659",
	["sentiment_very_satisfied"] = "rbxassetid://6034230650",
	["set_meal"] = "rbxassetid://6034503368",
	["settings"] = "rbxassetid://6031280882",
	["settings_applications"] = "rbxassetid://6031280894",
	["settings_backup_restore"] = "rbxassetid://6031280886",
	["settings_bluetooth"] = "rbxassetid://6031280905",
	["settings_brightness"] = "rbxassetid://6031280902",
	["settings_cell"] = "rbxassetid://6031280890",
	["settings_ethernet"] = "rbxassetid://6031280883",
	["settings_input_antenna"] = "rbxassetid://6031280891",
	["settings_input_component"] = "rbxassetid://6031280884",
	["settings_input_composite"] = "rbxassetid://6031280896",
	["settings_input_hdmi"] = "rbxassetid://6031280970",
	["settings_input_svideo"] = "rbxassetid://6031289444",
	["settings_overscan"] = "rbxassetid://6031289459",
	["settings_phone"] = "rbxassetid://6031289445",
	["settings_power"] = "rbxassetid://6031289446",
	["settings_remote"] = "rbxassetid://6031289442",
	["settings_system_daydream"] = "rbxassetid://6035030081",
	["settings_voice"] = "rbxassetid://6031265966",
	["share"] = "rbxassetid://6034230648",
	["shield"] = "rbxassetid://6035078889",
	["shop"] = "rbxassetid://6031265983",
	["shop_two"] = "rbxassetid://6031289461",
	["shopping_bag"] = "rbxassetid://6031265970",
	["shopping_basket"] = "rbxassetid://6031265997",
	["shopping_cart"] = "rbxassetid://6031265976",
	["short_text"] = "rbxassetid://6034934035",
	["show_chart"] = "rbxassetid://6034934032",
	["shuffle"] = "rbxassetid://6026667003",
	["shuffle_on"] = "rbxassetid://6026666996",
	["shutter_speed"] = "rbxassetid://6031763443",
	["sick"] = "rbxassetid://6034230642",
	["signal_cellular_0_bar"] = "rbxassetid://6035030072",
	["signal_cellular_4_bar"] = "rbxassetid://6035030076",
	["signal_cellular_alt"] = "rbxassetid://6035030079",
	["signal_cellular_connected_no_internet_4"] = "rbxassetid://6035229858",
	["signal_cellular_no_sim"] = "rbxassetid://6035030078",
	["signal_cellular_null"] = "rbxassetid://6035030075",
	["signal_cellular_off"] = "rbxassetid://6035030084",
	["signal_wifi_0_bar"] = "rbxassetid://6035030067",
	["signal_wifi_4_bar"] = "rbxassetid://6035030077",
	["signal_wifi_off"] = "rbxassetid://6035030074",
	["sim_card"] = "rbxassetid://6034837800",
	["sim_card_alert"] = "rbxassetid://6034452641",
	["single_bed"] = "rbxassetid://6034230651",
	["skip_next"] = "rbxassetid://6026667005",
	["skip_previous"] = "rbxassetid://6026667011",
	["slideshow"] = "rbxassetid://6031754546",
	["slow_motion_video"] = "rbxassetid://6026681583",
	["smart_button"] = "rbxassetid://6031265962",
	["smartphone"] = "rbxassetid://6034848731",
	["smoke_free"] = "rbxassetid://6035153647",
	["smoking_rooms"] = "rbxassetid://6035153636",
	["sms"] = "rbxassetid://6034452645",
	["sms_failed"] = "rbxassetid://6034452676",
	["snippet_folder"] = "rbxassetid://6031302947",
	["snooze"] = "rbxassetid://6026667006",
	["soap"] = "rbxassetid://6035153645",
	["sort"] = "rbxassetid://6035078888",
	["sort_by_alpha"] = "rbxassetid://6026667009",
	["source"] = "rbxassetid://6031289451",
	["south"] = "rbxassetid://6031104646",
	["south_east"] = "rbxassetid://6031104642",
	["south_west"] = "rbxassetid://6031104652",
	["spa"] = "rbxassetid://6035153639",
	["space_bar"] = "rbxassetid://6034934037",
	["speaker"] = "rbxassetid://6034848746",
	["speaker_group"] = "rbxassetid://6034848732",
	["speaker_notes"] = "rbxassetid://6031266001",
	["speaker_notes_off"] = "rbxassetid://6031265965",
	["speaker_phone"] = "rbxassetid://6035202018",
	["speed"] = "rbxassetid://6026681578",
	["spellcheck"] = "rbxassetid://6031289450",
	["sports"] = "rbxassetid://6034230647",
	["sports_bar"] = "rbxassetid://6035153638",
	["sports_baseball"] = "rbxassetid://6034230652",
	["sports_basketball"] = "rbxassetid://6034230649",
	["sports_cricket"] = "rbxassetid://6034230660",
	["sports_esports"] = "rbxassetid://6034227061",
	["sports_football"] = "rbxassetid://6034227067",
	["sports_golf"] = "rbxassetid://6034227060",
	["sports_handball"] = "rbxassetid://6034227074",
	["sports_hockey"] = "rbxassetid://6034227064",
	["sports_kabaddi"] = "rbxassetid://6034227141",
	["sports_mma"] = "rbxassetid://6034227072",
	["sports_motorsports"] = "rbxassetid://6034227071",
	["sports_rugby"] = "rbxassetid://6034227073",
	["sports_soccer"] = "rbxassetid://6034227075",
	["sports_tennis"] = "rbxassetid://6034227068",
	["sports_volleyball"] = "rbxassetid://6034227139",
	["square_foot"] = "rbxassetid://6035078918",
	["stacked_bar_chart"] = "rbxassetid://6035078892",
	["stacked_line_chart"] = "rbxassetid://6034934039",
	["stairs"] = "rbxassetid://6035153637",
	["star"] = "rbxassetid://6031068423",
	["star_border"] = "rbxassetid://6031068425",
	["star_half"] = "rbxassetid://6031068427",
	["star_outline"] = "rbxassetid://6031068428",
	["star_rate"] = "rbxassetid://6031265978",
	["stars"] = "rbxassetid://6031265971",
	["stay_current_landscape"] = "rbxassetid://6035202011",
	["stay_current_portrait"] = "rbxassetid://6035202004",
	["stay_primary_landscape"] = "rbxassetid://6035202026",
	["stay_primary_portrait"] = "rbxassetid://6035202009",
	["sticky_note_2"] = "rbxassetid://6031265972",
	["stop"] = "rbxassetid://6026681576",
	["stop_circle"] = "rbxassetid://6026681577",
	["stop_screen_share"] = "rbxassetid://6035202042",
	["storage"] = "rbxassetid://6035030083",
	["store"] = "rbxassetid://6031265968",
	["store_mall_directory"] = "rbxassetid://6034470811",
	["storefront"] = "rbxassetid://6035161534",
	["straighten"] = "rbxassetid://6031754545",
	["stream"] = "rbxassetid://6035078897",
	["streetview"] = "rbxassetid://6034470805",
	["strikethrough_s"] = "rbxassetid://6034934030",
	["stroller"] = "rbxassetid://6035161535",
	["style"] = "rbxassetid://6031754538",
	["subdirectory_arrow_left"] = "rbxassetid://6031104654",
	["subdirectory_arrow_right"] = "rbxassetid://6031104647",
	["subject"] = "rbxassetid://6031289452",
	["subscript"] = "rbxassetid://6034934059",
	["subscriptions"] = "rbxassetid://6026671207",
	["subtitles"] = "rbxassetid://6026671203",
	["subtitles_off"] = "rbxassetid://6031289466",
	["subway"] = "rbxassetid://6034467790",
	["superscript"] = "rbxassetid://6034934034",
	["supervised_user_circle"] = "rbxassetid://6031289449",
	["supervisor_account"] = "rbxassetid://6031251516",
	["support"] = "rbxassetid://6031251532",
	["support_agent"] = "rbxassetid://6034452656",
	["surround_sound"] = "rbxassetid://6026671209",
	["swap_calls"] = "rbxassetid://6035202037",
	["swap_horiz"] = "rbxassetid://6031233841",
	["swap_horizontal_circle"] = "rbxassetid://6031233833",
	["swap_vert"] = "rbxassetid://6031233847",
	["swap_vertical_circle"] = "rbxassetid://6031233839",
	["swipe"] = "rbxassetid://6031233863",
	["switch_account"] = "rbxassetid://6034227138",
	["switch_camera"] = "rbxassetid://6031754550",
	["switch_left"] = "rbxassetid://6031104651",
	["switch_right"] = "rbxassetid://6031104649",
	["switch_video"] = "rbxassetid://6031754536",
	["sync"] = "rbxassetid://6034452662",
	["sync_alt"] = "rbxassetid://6031233840",
	["sync_disabled"] = "rbxassetid://6034452649",
	["sync_problem"] = "rbxassetid://6034452653",
	["system_update"] = "rbxassetid://6034452663",
	["system_update_alt"] = "rbxassetid://6031251515",
	["tab"] = "rbxassetid://6031233851",
	["tab_unselected"] = "rbxassetid://6031251505",
	["table_chart"] = "rbxassetid://6034973081",
	["table_rows"] = "rbxassetid://6034934025",
	["table_view"] = "rbxassetid://6031233835",
	["tablet"] = "rbxassetid://6034848733",
	["tablet_android"] = "rbxassetid://6034848734",
	["tag"] = "rbxassetid://6035078895",
	["tag_faces"] = "rbxassetid://6031754560",
	["takeout_dining"] = "rbxassetid://6034467808",
	["tap_and_play"] = "rbxassetid://6034452650",
	["tapas"] = "rbxassetid://6035161533",
	["taxi_alert"] = "rbxassetid://6034467792",
	["terrain"] = "rbxassetid://6034467794",
	["text_fields"] = "rbxassetid://6034934040",
	["text_format"] = "rbxassetid://6035078890",
	["text_rotate_up"] = "rbxassetid://6031251526",
	["text_rotate_vertical"] = "rbxassetid://6031251518",
	["text_rotation_angledown"] = "rbxassetid://6031251513",
	["text_rotation_angleup"] = "rbxassetid://6031229337",
	["text_rotation_down"] = "rbxassetid://6031229334",
	["text_rotation_none"] = "rbxassetid://6031229344",
	["text_snippet"] = "rbxassetid://6031302995",
	["textsms"] = "rbxassetid://6035202006",
	["texture"] = "rbxassetid://6031754553",
	["theater_comedy"] = "rbxassetid://6034467796",
	["theaters"] = "rbxassetid://6031229335",
	["thumb_down"] = "rbxassetid://6031229336",
	["thumb_down_alt"] = "rbxassetid://6034227069",
	["thumb_down_off_alt"] = "rbxassetid://6031229354",
	["thumb_up"] = "rbxassetid://6031229347",
	["thumb_up_alt"] = "rbxassetid://6034227076",
	["thumb_up_off_alt"] = "rbxassetid://6031229342",
	["thumbs_up_down"] = "rbxassetid://6031229373",
	["time_to_leave"] = "rbxassetid://6034452660",
	["timelapse"] = "rbxassetid://6031754541",
	["timeline"] = "rbxassetid://6031229350",
	["timer"] = "rbxassetid://6031754564",
	["timer_10"] = "rbxassetid://6031734880",
	["timer_3"] = "rbxassetid://6031754540",
	["timer_off"] = "rbxassetid://6031734881",
	["title"] = "rbxassetid://6034934042",
	["toc"] = "rbxassetid://6031229341",
	["today"] = "rbxassetid://6031229352",
	["toggle_off"] = "rbxassetid://6031068429",
	["toggle_on"] = "rbxassetid://6031068430",
	["toll"] = "rbxassetid://6031229343",
	["tonality"] = "rbxassetid://6031734891",
	["topic"] = "rbxassetid://6031302976",
	["touch_app"] = "rbxassetid://6031229361",
	["tour"] = "rbxassetid://6031229362",
	["toys"] = "rbxassetid://6034848752",
	["track_changes"] = "rbxassetid://6031225814",
	["traffic"] = "rbxassetid://6034467797",
	["train"] = "rbxassetid://6034467803",
	["tram"] = "rbxassetid://6034467806",
	["transfer_within_a_station"] = "rbxassetid://6034467809",
	["transform"] = "rbxassetid://6031734873",
	["transit_enterexit"] = "rbxassetid://6034467805",
	["translate"] = "rbxassetid://6031225812",
	["trending_down"] = "rbxassetid://6031225811",
	["trending_flat"] = "rbxassetid://6031225818",
	["trending_up"] = "rbxassetid://6031225816",
	["trip_origin"] = "rbxassetid://6034467804",
	["tty"] = "rbxassetid://6035161541",
	["tune"] = "rbxassetid://6031734877",
	["turned_in"] = "rbxassetid://6031225808",
	["turned_in_not"] = "rbxassetid://6031225806",
	["tv"] = "rbxassetid://6034848740",
	["tv_off"] = "rbxassetid://6034452646",
	["two_wheeler"] = "rbxassetid://6034467795",
	["umbrella"] = "rbxassetid://6035161550",
	["unarchive"] = "rbxassetid://6035078921",
	["undo"] = "rbxassetid://6035078896",
	["unfold_less"] = "rbxassetid://6031104681",
	["unfold_more"] = "rbxassetid://6031104644",
	["unpublished"] = "rbxassetid://6031225817",
	["unsubscribe"] = "rbxassetid://6035202044",
	["update"] = "rbxassetid://6031225810",
	["upgrade"] = "rbxassetid://6031225815",
	["upload_file"] = "rbxassetid://6031302959",
	["usb"] = "rbxassetid://6035030080",
	["verified"] = "rbxassetid://6031225809",
	["verified_user"] = "rbxassetid://6031225819",
	["vertical_align_bottom"] = "rbxassetid://6034934023",
	["vertical_align_center"] = "rbxassetid://6034934051",
	["vertical_align_top"] = "rbxassetid://6034973080",
	["vertical_split"] = "rbxassetid://6031225820",
	["vibration"] = "rbxassetid://6034452651",
	["video_label"] = "rbxassetid://6026671204",
	["video_library"] = "rbxassetid://6026671208",
	["video_settings"] = "rbxassetid://6026671211",
	["videocam"] = "rbxassetid://6026671213",
	["videocam_off"] = "rbxassetid://6026671212",
	["videogame_asset"] = "rbxassetid://6034848748",
	["view_agenda"] = "rbxassetid://6031225831",
	["view_array"] = "rbxassetid://6031225842",
	["view_carousel"] = "rbxassetid://6031251507",
	["view_column"] = "rbxassetid://6031079172",
	["view_comfy"] = "rbxassetid://6031734876",
	["view_compact"] = "rbxassetid://6031734878",
	["view_day"] = "rbxassetid://6031079153",
	["view_headline"] = "rbxassetid://6031079151",
	["view_in_ar"] = "rbxassetid://6031079158",
	["view_list"] = "rbxassetid://6031079156",
	["view_module"] = "rbxassetid://6031079152",
	["view_quilt"] = "rbxassetid://6031079155",
	["view_sidebar"] = "rbxassetid://6031079160",
	["view_stream"] = "rbxassetid://6031079164",
	["view_week"] = "rbxassetid://6031079154",
	["vignette"] = "rbxassetid://6031734905",
	["visibility"] = "rbxassetid://6031075931",
	["visibility_off"] = "rbxassetid://6031075929",
	["voice_over_off"] = "rbxassetid://6031075927",
	["voicemail"] = "rbxassetid://6035202019",
	["volume_down"] = "rbxassetid://6026671206",
	["volume_mute"] = "rbxassetid://6026671214",
	["volume_off"] = "rbxassetid://6026671224",
	["volume_up"] = "rbxassetid://6026671215",
	["volunteer_activism"] = "rbxassetid://6034467799",
	["vpn_key"] = "rbxassetid://6035202034",
	["vpn_lock"] = "rbxassetid://6034452648",
	["wallpaper"] = "rbxassetid://6035030102",
	["wash"] = "rbxassetid://6035161540",
	["watch"] = "rbxassetid://6034848747",
	["watch_later"] = "rbxassetid://6031075924",
	["water_damage"] = "rbxassetid://6035161563",
	["waterfall_chart"] = "rbxassetid://6031104632",
	["waves"] = "rbxassetid://6035078898",
	["wb_auto"] = "rbxassetid://6031734875",
	["wb_cloudy"] = "rbxassetid://6031734907",
	["wb_incandescent"] = "rbxassetid://6034316010",
	["wb_iridescent"] = "rbxassetid://6034315972",
	["wb_shade"] = "rbxassetid://6034315974",
	["wb_sunny"] = "rbxassetid://6034412758",
	["wb_twighlight"] = "rbxassetid://6034412760",
	["wc"] = "rbxassetid://6034452643",
	["web"] = "rbxassetid://6026671234",
	["web_asset"] = "rbxassetid://6026671239",
	["weekend"] = "rbxassetid://6035078894",
	["west"] = "rbxassetid://6031104677",
	["whatshot"] = "rbxassetid://6034287525",
	["wheelchair_pickup"] = "rbxassetid://6035161536",
	["where_to_vote"] = "rbxassetid://6035078913",
	["widgets"] = "rbxassetid://6035039429",
	["wifi"] = "rbxassetid://6034461626",
	["wifi_calling"] = "rbxassetid://6035202065",
	["wifi_lock"] = "rbxassetid://6035039428",
	["wifi_off"] = "rbxassetid://6034461625",
	["wifi_protected_setup"] = "rbxassetid://6031075926",
	["wifi_tethering"] = "rbxassetid://6035039430",
	["work"] = "rbxassetid://6031075939",
	["work_off"] = "rbxassetid://6031075937",
	["work_outline"] = "rbxassetid://6031075930",
	["workspaces_filled"] = "rbxassetid://6031302961",
	["workspaces_outline"] = "rbxassetid://6031302952",
	["wrap_text"] = "rbxassetid://6034973118",
	["wrong_location"] = "rbxassetid://6034467801",
	["wysiwyg"] = "rbxassetid://6031075938",
	["youtube_searched_for"] = "rbxassetid://6031075934",
	["zoom_in"] = "rbxassetid://6031075573",
	["zoom_out"] = "rbxassetid://6031075577",
	["zoom_out_map"] = "rbxassetid://6035229856",
}

local Icons = setmetatable({}, {
	__index = function(_, key)
		if TextIcons[key] then return TextIcons[key] end
		if IconAssets[key] then return TextIcons.circle end
		return TextIcons.circle
	end
})
Icons.dot = TextIcons.dot
Icons.check = TextIcons.check
Icons.x = TextIcons.x
Icons.circle = TextIcons.circle
Icons.ring = TextIcons.ring
Icons.sparkle = TextIcons.sparkle
Icons.star = TextIcons.star
Icons.heart = TextIcons.heart
Icons.expand = TextIcons.expand
Icons.collapse = TextIcons.collapse
Icons.play = TextIcons.play
Icons.arrow_r = TextIcons.arrow_r
Icons.arrow_l = TextIcons.arrow_l

local function getIconAsset(name)
	return IconAssets[name]
end

local function getIcon(name)
	return TextIcons[name] or TextIcons.circle
end

local function createIconImage(parent, iconName, size, color, zIdx)
	local assetId = IconAssets[iconName]
	if not assetId then
		local fallback = Instance.new("TextLabel")
		noHit(fallback)
		fallback.BackgroundTransparency = 1
		fallback.Size = UDim2.new(0, size or 16, 0, size or 16)
		fallback.Font = Enum.Font.GothamBold
		fallback.TextSize = (size or 16) - 2
		fallback.Text = TextIcons[iconName] or TextIcons.circle
		fallback.TextColor3 = color or Color3.new(1, 1, 1)
		fallback.ZIndex = zIdx or 10
		fallback.Parent = parent
		return fallback
	end
	local img = Instance.new("ImageLabel")
	noHit(img)
	img.BackgroundTransparency = 1
	img.Size = UDim2.new(0, size or 16, 0, size or 16)
	img.Image = assetId
	img.ImageColor3 = color or Color3.new(1, 1, 1)
	img.ScaleType = Enum.ScaleType.Fit
	img.ZIndex = zIdx or 10
	img.Parent = parent
	return img
end

local function setIconImage(imageLabel, iconName, color)
	local assetId = IconAssets[iconName]
	if assetId and imageLabel then
		imageLabel.Image = assetId
		if color then imageLabel.ImageColor3 = color end
	end
end

local SND_ON = true
local Sounds = {
	click = "rbxassetid://876939830",
	toggle = "rbxassetid://876939830",
	hover = "rbxassetid://876939830",
	whoosh = "rbxassetid://876939830",
	ding = "rbxassetid://876939830",
	slide = "rbxassetid://876939830",
	pop = "rbxassetid://876939830",
	expand = "rbxassetid://876939830",
	collapse = "rbxassetid://876939830",
	typing = "rbxassetid://876939830",
	sel = "rbxassetid://876939830",
	success = "rbxassetid://876939830",
	err = "rbxassetid://876939830",
	notif = "rbxassetid://876939830",
}

local SoundProfiles = {
	click = {vol = 0.12, pitch = 1.0},
	toggle = {vol = 0.10, pitch = 1.15},
	hover = {vol = 0.04, pitch = 1.5},
	whoosh = {vol = 0.08, pitch = 0.7},
	ding = {vol = 0.12, pitch = 1.3},
	slide = {vol = 0.03, pitch = 1.2},
	pop = {vol = 0.10, pitch = 1.4},
	expand = {vol = 0.08, pitch = 0.85},
	collapse = {vol = 0.08, pitch = 0.75},
	typing = {vol = 0.03, pitch = 1.6},
	sel = {vol = 0.10, pitch = 1.1},
	success = {vol = 0.12, pitch = 1.5},
	err = {vol = 0.10, pitch = 0.6},
	notif = {vol = 0.15, pitch = 1.25},
}

local SoundPacks = {
	Default = {style = "normal"},
	Quiet = {style = "quiet"},
	Clicky = {style = "clicky"},
	Silent = {style = "silent"},
}

local activeSoundPack = "Default"
local soundPackMultipliers = {
	normal = {vol = 1.0, pitchRange = 0.0},
	quiet = {vol = 0.4, pitchRange = 0.0},
	clicky = {vol = 1.2, pitchRange = 0.05},
	silent = {vol = 0.0, pitchRange = 0.0},
}

local function setSoundPack(name)
	if SoundPacks[name] then activeSoundPack = name end
end

local _soundIdToName = {}
for k, v in pairs(Sounds) do _soundIdToName[v] = _soundIdToName[v] or k end

local _soundCache = {}
local _soundCacheSize = 0
local MAX_SOUND_CACHE = 6

local function playSound(id, vol, pitch)
	if not SND_ON then return end
	local packStyle = (SoundPacks[activeSoundPack] or {}).style or "normal"
	local mult = soundPackMultipliers[packStyle] or soundPackMultipliers.normal
	if mult.vol == 0 then return end
	local sndName = _soundIdToName[id]
	local prof = sndName and SoundProfiles[sndName]
	local finalVol = (vol or (prof and prof.vol) or 0.12) * mult.vol
	local finalPitch = (pitch or (prof and prof.pitch) or 1.0) + (math.random() - 0.5) * mult.pitchRange * 2
	pcall(function()
		local sndId = id or Sounds.click
		local s = _soundCache[sndId]
		if not s or not s.Parent then
			s = Instance.new("Sound")
			s.SoundId = sndId
			s.Parent = SoundService
			if _soundCacheSize < MAX_SOUND_CACHE then
				_soundCache[sndId] = s
				_soundCacheSize = _soundCacheSize + 1
			else
				Debris:AddItem(s, 3)
			end
		end
		s.Volume = finalVol
		s.PlaybackSpeed = finalPitch
		s:Play()
	end)
end

local function addClayShadow(parent, cr)
	local shadow = Instance.new("ImageLabel")
	noHit(shadow)
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.BackgroundTransparency = 1
	shadow.Position = UDim2.new(0.5, 3, 0.5, 3)
	shadow.Size = UDim2.new(1, 12, 1, 12)
	shadow.ZIndex = parent.ZIndex - 1
	shadow.Image = "rbxassetid://6014261993"
	shadow.ImageColor3 = C.ClayShadow
	shadow.ImageTransparency = 0.35
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(49, 49, 450, 450)
	shadow.Parent = parent

	local shadow2 = Instance.new("ImageLabel")
	noHit(shadow2)
	shadow2.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow2.BackgroundTransparency = 1
	shadow2.Position = UDim2.new(0.5, 5, 0.5, 6)
	shadow2.Size = UDim2.new(1, 28, 1, 28)
	shadow2.ZIndex = parent.ZIndex - 2
	shadow2.Image = "rbxassetid://6014261993"
	shadow2.ImageColor3 = C.ClayShadowDeep
	shadow2.ImageTransparency = 0.55
	shadow2.ScaleType = Enum.ScaleType.Slice
	shadow2.SliceCenter = Rect.new(49, 49, 450, 450)
	shadow2.Parent = parent

	return shadow
end

local function addClayHighlight(parent)
	local highlight = Instance.new("Frame")
	noHit(highlight)
	highlight.BackgroundColor3 = C.ClayHighlight
	highlight.BackgroundTransparency = 0.82
	highlight.Size = UDim2.new(1, 0, 0, 1)
	highlight.Position = UDim2.new(0, 0, 0, 0)
	highlight.ZIndex = parent.ZIndex + 1
	highlight.Parent = parent
	corner(highlight, 16)
	local hGrad = Instance.new("UIGradient")
	hGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.7),
		NumberSequenceKeypoint.new(1, 1),
	})
	hGrad.Parent = highlight
	return highlight
end

local function createRipple(parent, color)
	if not ANIM_ENABLED then return end
	local r = Instance.new("Frame")
	r.BackgroundColor3 = color or C.Accent
	r.BackgroundTransparency = 0.55
	r.AnchorPoint = Vector2.new(0.5, 0.5)
	r.Position = UDim2.new(0.5, 0, 0.5, 0)
	r.Size = UDim2.new(0, 0, 0, 0)
	r.ZIndex = 9
	r.Parent = parent
	corner(r, 999)
	local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.5
	tw(r, 0.65, {Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1}, Enum.EasingStyle.Quart)
	task.delay(0.7, function()
		if r and r.Parent then r:Destroy() end
	end)
end

local function makeDrag(frame, handle)
	local dragging = false
	local dragStart = nil
	local frameStart = nil
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			frameStart = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				frameStart.X.Scale, frameStart.X.Offset + delta.X,
				frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
			)
		end
	end)
end

local function springAnimate(obj, prop, target, stiffness, damping, mass)
	if not obj or not obj.Parent then return end
	if not ANIM_ENABLED then
		pcall(function() obj[prop] = target end)
		return
	end
	local sp = Spring.new(stiffness or 280, damping or 22, mass or 1)
	local startVal = obj[prop]
	sp.Pos = 0
	sp.Target = 1
	poolAdd(function(dt)
		if not obj or not obj.Parent then return false end
		local t = sp:Update(dt)
		if typeof(startVal) == "UDim2" then
			obj[prop] = UDim2.new(
				lerp(startVal.X.Scale, target.X.Scale, t),
				lerp(startVal.X.Offset, target.X.Offset, t),
				lerp(startVal.Y.Scale, target.Y.Scale, t),
				lerp(startVal.Y.Offset, target.Y.Offset, t)
			)
		elseif typeof(startVal) == "number" then
			obj[prop] = lerp(startVal, target, t)
		elseif typeof(startVal) == "Color3" then
			obj[prop] = lerpColor(startVal, target, t)
		end
		if sp:Done(0.002) then
			pcall(function() obj[prop] = target end)
			return false
		end
		return true
	end)
end

local function springBounce(obj, prop, target, overshoot)
	if not obj or not obj.Parent then return end
	if not ANIM_ENABLED then
		pcall(function() obj[prop] = target end)
		return
	end
	local sp = Spring.new(350, 18, 0.7)
	local startVal = obj[prop]
	sp.Pos = 0
	sp.Target = 1
	sp:Impulse(overshoot or 8)
	poolAdd(function(dt)
		if not obj or not obj.Parent then return false end
		local t = sp:Update(dt)
		if typeof(startVal) == "UDim2" then
			obj[prop] = UDim2.new(
				lerp(startVal.X.Scale, target.X.Scale, t),
				lerp(startVal.X.Offset, target.X.Offset, t),
				lerp(startVal.Y.Scale, target.Y.Scale, t),
				lerp(startVal.Y.Offset, target.Y.Offset, t)
			)
		elseif typeof(startVal) == "number" then
			obj[prop] = lerp(startVal, target, t)
		end
		if sp:Done(0.002) then
			pcall(function() obj[prop] = target end)
			return false
		end
		return true
	end)
end

local function addHoverLift(frame, liftPx)
	if IS_MOBILE or not ANIM_ENABLED then return end
	liftPx = liftPx or 3
	local origPos = nil
	local lifting = false
	frame.MouseEnter:Connect(function()
		if lifting then return end
		lifting = true
		origPos = origPos or frame.Position
		springAnimate(frame, "Position", UDim2.new(
			origPos.X.Scale, origPos.X.Offset,
			origPos.Y.Scale, origPos.Y.Offset - liftPx
			), 300, 20, 0.8)
		playSound(Sounds.hover, 0.04, 1.35)
	end)
	frame.MouseLeave:Connect(function()
		lifting = false
		if origPos then
			springAnimate(frame, "Position", origPos, 260, 22, 1)
		end
	end)
end

local function addMagneticHover(frame, strength)
	if IS_MOBILE or not ANIM_ENABLED then return end
	strength = strength or 4
	local origPos = nil
	local tracking = false
	local _magPoolId = nil
	frame.MouseEnter:Connect(function()
		if not ANIM_ENABLED then return end
		tracking = true
		origPos = origPos or frame.Position
		if not _magPoolId then
			_magPoolId = poolAdd(function(dt)
				if not frame or not frame.Parent then _magPoolId = nil return false end
				if not tracking then _magPoolId = nil return false end
				if origPos then
					local mPos = UserInputService:GetMouseLocation()
					local absPos = frame.AbsolutePosition
					local absSize = frame.AbsoluteSize
					local centerX = absPos.X + absSize.X / 2
					local centerY = absPos.Y + absSize.Y / 2
					local dx = (mPos.X - centerX) / absSize.X * strength
					local dy = (mPos.Y - centerY) / absSize.Y * strength
					frame.Position = UDim2.new(
						origPos.X.Scale, origPos.X.Offset + dx,
						origPos.Y.Scale, origPos.Y.Offset + dy
					)
				end
				return true
			end)
		end
	end)
	frame.MouseLeave:Connect(function()
		tracking = false
		if origPos and frame and frame.Parent then
			springAnimate(frame, "Position", origPos, 320, 22, 0.8)
		end
	end)
end

local function staggerIn(container)
	if not ANIM_ENABLED then return end
	local children = {}
	for _, ch in ipairs(container:GetChildren()) do
		if ch:IsA("GuiObject") and not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") and not ch:IsA("UIGridLayout") then
			children[#children + 1] = ch
		end
	end
	for i, ch in ipairs(children) do
		local orig = ch.Position
		ch.Position = UDim2.new(orig.X.Scale, orig.X.Offset + 22, orig.Y.Scale, orig.Y.Offset + 18)
		local origTr = ch.BackgroundTransparency
		if ch:IsA("Frame") or ch:IsA("TextButton") or ch:IsA("ScrollingFrame") then
			ch.BackgroundTransparency = math.min(origTr + 0.6, 1)
		end
		task.delay(i * 0.05, function()
			if not ch or not ch.Parent then return end
			springAnimate(ch, "Position", orig, 240, 20, 0.85)
			if ch:IsA("Frame") or ch:IsA("TextButton") or ch:IsA("ScrollingFrame") then
				tw(ch, 0.5, {BackgroundTransparency = origTr}, Enum.EasingStyle.Quart)
			end
		end)
	end
end

local function createOrb(parent, size, color, posX, posY, zindex, transparency)
	local orb = Instance.new("Frame")
	noHit(orb)
	orb.AnchorPoint = Vector2.new(0.5, 0.5)
	orb.BackgroundColor3 = color
	orb.BackgroundTransparency = transparency or 0.55
	orb.Position = UDim2.new(posX, 0, posY, 0)
	orb.Size = UDim2.new(0, size, 0, size)
	orb.ZIndex = zindex or 1
	orb.Parent = parent
	corner(orb, math.floor(size / 2))

	local glow1 = Instance.new("Frame")
	noHit(glow1)
	glow1.AnchorPoint = Vector2.new(0.5, 0.5)
	glow1.BackgroundColor3 = color
	glow1.BackgroundTransparency = (transparency or 0.55) + 0.15
	glow1.Position = UDim2.new(0.5, 0, 0.5, 0)
	glow1.Size = UDim2.new(1, math.floor(size * 0.5), 1, math.floor(size * 0.5))
	glow1.ZIndex = (zindex or 1) - 1
	glow1.Parent = orb
	corner(glow1, math.floor(size * 0.75))

	local glow2 = Instance.new("Frame")
	noHit(glow2)
	glow2.AnchorPoint = Vector2.new(0.5, 0.5)
	glow2.BackgroundColor3 = color
	glow2.BackgroundTransparency = (transparency or 0.55) + 0.25
	glow2.Position = UDim2.new(0.5, 0, 0.5, 0)
	glow2.Size = UDim2.new(1, math.floor(size * 1.0), 1, math.floor(size * 1.0))
	glow2.ZIndex = (zindex or 1) - 1
	glow2.Parent = orb
	corner(glow2, math.floor(size))

	return orb
end

local function addShimmer(parent, color, rad)
	if not ANIM_ENABLED then return nil end
	rad = rad or 18
	parent.ClipsDescendants = true

	-- The highlight fills the header with the SAME rounded corners as the card and
	-- extends past the bottom (which the header's clip trims to a straight edge), so
	-- its shape matches the card exactly: rounded top corners, straight sides. The
	-- sweep is a bright band slid across via UIGradient.Offset. ClipsDescendants
	-- ignores UICorner, so a moving hard-edged bar showed square nubs at the corners
	-- (and simply insetting it left an ugly hard cut) — a gradient inside a
	-- corner-matched frame has no hard edge to square off.
	local shimmer = Instance.new("Frame")
	noHit(shimmer)
	shimmer.BackgroundColor3 = color or C.Accent
	shimmer.Size = UDim2.new(1, 0, 1, rad)
	shimmer.Position = UDim2.new(0, 0, 0, 0)
	shimmer.ZIndex = parent.ZIndex + 1
	shimmer.Parent = parent
	corner(shimmer, rad)

	local sg = Instance.new("UIGradient")
	sg.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.34, 1),
		NumberSequenceKeypoint.new(0.5, 0.6),
		NumberSequenceKeypoint.new(0.66, 1),
		NumberSequenceKeypoint.new(1, 1),
	})
	sg.Offset = Vector2.new(-0.9, 0)
	sg.Parent = shimmer

	local function doShimmer()
		if not ANIM_ENABLED then return end
		sg.Offset = Vector2.new(-0.9, 0)
		tw(sg, 2.6, {Offset = Vector2.new(0.9, 0)}, Enum.EasingStyle.Sine)
	end
	doShimmer()
	local _shimmerTimer = 0
	poolAdd(function(dt)
		if not shimmer or not shimmer.Parent then return false end
		if not ANIM_ENABLED then return true end
		_shimmerTimer = _shimmerTimer + dt
		if _shimmerTimer >= 4.5 + math.random() * 3 then
			_shimmerTimer = 0
			doShimmer()
		end
		return true
	end)
	return shimmer
end

local ConfigManager = {}
ConfigManager.__index = ConfigManager

function ConfigManager.new(hubName, configFolder)
	local userId = tostring(Players.LocalPlayer.UserId)
	local self = setmetatable({
		HubName = hubName or "ExpensiveHub",
		Folder = configFolder or (hubName or "ExpensiveHub") .. "_configs",
		Profiles = {Default = {}},
		Active = "Default",
		Flags = {},
		_userId = userId,
		_boundProfile = nil,
		_autoSaveConn = nil,
		_loaded = false,
	}, ConfigManager)
	self:_ensureFolder(self.Folder)
	return self
end

function ConfigManager:_ensureFolder(path)
	pcall(function()
		if makefolder then
			if isfolder then
				if not isfolder(path) then makefolder(path) end
			else
				pcall(makefolder, path)
			end
		end
	end)
end

function ConfigManager:_userFolder()
	self:_ensureFolder(self.Folder)
	local uf = self.Folder .. "/" .. self._userId
	self:_ensureFolder(uf)
	return uf
end

function ConfigManager:_profileFile(profileName)
	return self:_userFolder() .. "/" .. (profileName or self.Active) .. ".json"
end

function ConfigManager:_metaFile()
	return self:_userFolder() .. "/_meta.json"
end

function ConfigManager:BindProfile(profileName)
	self._boundProfile = profileName or self.Active
	self:Save(self._boundProfile)
	pcall(function()
		if writefile then
			writefile(self:_metaFile(), HttpService:JSONEncode({boundProfile = self._boundProfile}))
		end
	end)
	self.Active = self._boundProfile
end

function ConfigManager:UnbindProfile()
	self._boundProfile = nil
	pcall(function()
		local path = self:_metaFile()
		if delfile and isfile and isfile(path) then
			delfile(path)
		elseif writefile then
			writefile(path, HttpService:JSONEncode({}))
		end
	end)
	return true
end

function ConfigManager:GetBoundProfile()
	if self._boundProfile then return self._boundProfile end
	pcall(function()
		if readfile and isfile and isfile(self:_metaFile()) then
			local s, data = pcall(HttpService.JSONDecode, HttpService, readfile(self:_metaFile()))
			if s and data and data.boundProfile then
				self._boundProfile = data.boundProfile
			end
		end
	end)
	return self._boundProfile
end

function ConfigManager:CreateProfile(name)
	if not name or name == "" then return false end
	self.Profiles[name] = self:CollectAll()
	self:Save(name)
	return true
end

function ConfigManager:DeleteProfile(name)
	if name == "Default" then return false end
	self.Profiles[name] = nil
	pcall(function()
		local path = self:_profileFile(name)
		if delfile and isfile and isfile(path) then delfile(path) end
	end)
	if self.Active == name then self.Active = "Default" end
	if self._boundProfile == name then self._boundProfile = nil end
	return true
end

function ConfigManager:SetProfile(n)
	if not n or n == "" then return false end
	if self:SaveExists(n) then
		return self:Load(n) -- Load fires callbacks on success
	else
		if not self.Profiles[n] then self.Profiles[n] = self:CollectAll() end
		self.Active = n
		self:Save(n)
		return true
	end
end

function ConfigManager:ListProfiles()
	local r = {}
	local seen = {}
	for k in pairs(self.Profiles) do r[#r+1] = k; seen[k] = true end
	for _, s in ipairs(self:ListSaves()) do
		if not seen[s] then r[#r+1] = s; seen[s] = true end
	end
	table.sort(r)
	return r
end

function ConfigManager:Set(f, v)
	if not self.Profiles[self.Active] then self.Profiles[self.Active] = {} end
	self.Profiles[self.Active][f] = v
end

function ConfigManager:Get(f)
	return self.Profiles[self.Active] and self.Profiles[self.Active][f]
end

function ConfigManager:Register(f, a)
	self.Flags[f] = a
end

function ConfigManager:CollectAll()
	local data = {}
	for f, a in pairs(self.Flags) do
		if a.Get then
			local ok2, val = pcall(a.Get, a)
			if ok2 then
				if typeof(val) == "Color3" then
					data[f] = {R = math.floor(val.R*255), G = math.floor(val.G*255), B = math.floor(val.B*255)}
				elseif typeof(val) == "EnumItem" then
					data[f] = val.Name
				else
					data[f] = val
				end
			end
		end
	end
	return data
end

function ConfigManager:ApplyData(data)
	if type(data) ~= "table" then return false end
	for f, a in pairs(self.Flags) do
		if data[f] ~= nil and a.Set then
			pcall(a.Set, a, data[f], true)
		end
	end
	return true
end

function ConfigManager:FireAllCallbacks()
	for f, a in pairs(self.Flags) do
		if a.Get and a._cb then
			local ok2, val = pcall(a.Get, a)
			if ok2 then pcall(a._cb, val) end
		end
	end
end

function ConfigManager:Save(name)
	name = name or self.Active
	local data = self:CollectAll()
	self.Profiles[name] = data
	local ok = false
	local path = self:_profileFile(name)
	pcall(function()
		if not writefile then return end
		writefile(path, HttpService:JSONEncode(data))
		ok = true
	end)
	return ok, path
end

function ConfigManager:SaveEnhanced(name)
	return self:Save(name)
end

function ConfigManager:Load(name)
	name = name or self.Active
	local ok = false
	pcall(function()
		local path = self:_profileFile(name)
		if readfile and isfile and isfile(path) then
			local s, data = pcall(HttpService.JSONDecode, HttpService, readfile(path))
			if s and type(data) == "table" then
				self.Profiles[name] = data
				self.Active = name
				self:ApplyData(data)
				ok = true
			end
		end
	end)
	-- ApplyData sets values silently (noCallback); fire callbacks once so the
	-- feature logic matches the loaded state (otherwise: visual on, logic off).
	if ok then task.defer(function() self:FireAllCallbacks() end) end
	return ok
end

function ConfigManager:LoadEnhanced(name)
	return self:Load(name) -- Load already fires callbacks
end

function ConfigManager:AutoLoad()
	local bound = self:GetBoundProfile()
	local target = bound or "Default"
	local ok = self:Load(target)
	if not ok and target ~= "Default" then
		ok = self:Load("Default")
	end
	self._loaded = true
	-- Load() fires callbacks when it succeeds; if nothing was loaded (first run),
	-- still apply the Default-value callbacks once so defaults activate.
	if not ok then task.defer(function() self:FireAllCallbacks() end) end
	return ok
end

function ConfigManager:SaveAll()
	local results = {}
	for _, name in ipairs(self:ListProfiles()) do
		local ok2 = self:Save(name)
		results[name] = ok2
	end
	return results
end

function ConfigManager:ListSaves()
	local saves = {}
	pcall(function()
		if listfiles then
			for _, file in ipairs(listfiles(self:_userFolder())) do
				-- normalize Windows back-slashes first; listfiles returns full paths and
				-- the old pattern failed to strip "\", capturing the whole path as the name.
				local norm = file:gsub("\\", "/")
				local name = norm:match("([^/]+)%.json$")
				if name and name ~= "_meta" then saves[#saves+1] = name end
			end
		end
	end)
	table.sort(saves)
	return saves
end

function ConfigManager:Delete(name)
	return self:DeleteProfile(name)
end

function ConfigManager:Export()
	return HttpService:JSONEncode(self:CollectAll())
end

function ConfigManager:Import(json)
	local s, data = pcall(HttpService.JSONDecode, HttpService, json)
	if s and type(data) == "table" then
		self.Profiles[self.Active] = data
		self:ApplyData(data)
		task.defer(function() self:FireAllCallbacks() end)
		return true
	end
	return false
end

function ConfigManager:EnableAutoSave(interval)
	self:DisableAutoSave()
	self._autoSaveConn = task.spawn(function()
		while true do
			task.wait(interval or 30)
			pcall(function() self:Save() end)
		end
	end)
end

function ConfigManager:DisableAutoSave()
	if self._autoSaveConn then
		pcall(function() task.cancel(self._autoSaveConn) end)
		self._autoSaveConn = nil
	end
end

function ConfigManager:GetAutoSaveStatus()
	return self._autoSaveConn ~= nil
end

function ConfigManager:QuickSave()
	return self:Save(self.Active)
end

function ConfigManager:QuickLoad()
	return self:Load(self.Active)
end

function ConfigManager:SaveExists(name)
	name = name or self.Active
	local exists = false
	pcall(function()
		local fileName = self:_profileFile(name)
		if isfile then exists = isfile(fileName) end
	end)
	return exists
end

local BlurEffect = nil
local blurEnabled = false

local function createBlur()
	pcall(function()
		BlurEffect = Instance.new("BlurEffect")
		BlurEffect.Name = "EHBlur"
		BlurEffect.Size = 0
		BlurEffect.Parent = Lighting
	end)
end

local function showBlur()
	if BlurEffect then tw(BlurEffect, 0.5, {Size = 20}, Enum.EasingStyle.Quint) end
end

local function hideBlur()
	if BlurEffect then tw(BlurEffect, 0.35, {Size = 0}, Enum.EasingStyle.Quint) end
end

local function destroyBlur()
	if BlurEffect then BlurEffect:Destroy() BlurEffect = nil end
end

local Library = {}

if _G.__ExpensiveHub_Cleanup then
	pcall(_G.__ExpensiveHub_Cleanup)
end

function Library:CreateWindow(cfg)
	cfg = cfg or {}
	local title = cfg.Title or "Expensive Hub"
	local introOn = cfg.Intro ~= false
	local keybind = cfg.Keybind or Enum.KeyCode.RightControl
	SND_ON = cfg.Sounds ~= false
	SC = getScale()

	local WW = math.floor(math.clamp(960 * SC, 680, 1100))
	local WH = math.floor(math.clamp(640 * SC, 460, 750))
	local SIDEBAR_W = math.floor(58 * SC)
	local SIDEBAR_EXP = math.floor(195 * SC)
	local TOPBAR_H = math.floor(52 * SC)
	local SUBTAB_H = math.floor(42 * SC)
	local FOOTER_H = math.floor(32 * SC)

	local W = {
		Tabs = {},
		ActiveTab = nil,
		Visible = true,
		_conns = {},
		_flags = {},
		_elems = {},
		_activeFeatures = {},
		-- Names the user has opted out of the Active Features panel (via a toggle's
		-- HideFromActive option or Window:SetFeatureHiddenFromActive). The feature
		-- still works and still counts internally; it just isn't listed in the panel.
		_activeHidden = {},
		Config = ConfigManager.new(cfg.ConfigName or title:gsub("%s+", ""), cfg.ConfigFolder),
		AutoSaveEnabled = true,
	}
	-- Single source of truth: the window flag registry IS the ConfigManager registry.
	W._flags = W.Config.Flags

	local sidebarExpanded = false
	local sidebarHoverLock = false

	local function trackConn(conn)
		W._conns[#W._conns + 1] = conn
	end

	createBlur()

	pcall(function()
		local old = CoreGui:FindFirstChild("ExpensiveHub")
		if not old then old = Player:WaitForChild("PlayerGui"):FindFirstChild("ExpensiveHub") end
		if old then old:Destroy() end
	end)

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ExpensiveHub"
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	pcall(function() screenGui.Parent = CoreGui end)
	if not screenGui.Parent then
		screenGui.Parent = Player:WaitForChild("PlayerGui")
	end

	local uiScaleObj = Instance.new("UIScale")
	-- Mobile defaults to 80% so the window doesn't dominate small touch screens.
	uiScaleObj.Scale = IS_MOBILE and 0.8 or 1
	uiScaleObj.Parent = screenGui

	local main = Instance.new("CanvasGroup")
	main.Name = "Main"
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = C.BG
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.Size = introOn and UDim2.new(0, 0, 0, 0) or UDim2.new(0, WW, 0, WH)
	main.GroupTransparency = introOn and 1 or 0
	main.ClipsDescendants = true
	main.Parent = screenGui
	corner(main, 22)

	for i = 1, 4 do
		local sh = Instance.new("ImageLabel")
		noHit(sh)
		sh.AnchorPoint = Vector2.new(0.5, 0.5)
		sh.BackgroundTransparency = 1
		sh.Position = UDim2.new(0.5, i * 1.5, 0.5, i * 2.5)
		sh.Size = UDim2.new(1, 45 + i * 22, 1, 45 + i * 22)
		sh.ZIndex = -1
		sh.Image = "rbxassetid://6014261993"
		sh.ImageColor3 = C.ClayShadow
		sh.ImageTransparency = 0.25 + i * 0.12
		sh.ScaleType = Enum.ScaleType.Slice
		sh.SliceCenter = Rect.new(49, 49, 450, 450)
		sh.Parent = main
	end

	for i = 1, 2 do
		local hl = Instance.new("ImageLabel")
		noHit(hl)
		hl.AnchorPoint = Vector2.new(0.5, 0.5)
		hl.BackgroundTransparency = 1
		hl.Position = UDim2.new(0.5, -i * 1.5, 0.5, -i * 1.5)
		hl.Size = UDim2.new(1, 20 + i * 12, 1, 20 + i * 12)
		hl.ZIndex = -1
		hl.Image = "rbxassetid://6014261993"
		hl.ImageColor3 = C.ClayHighlight
		hl.ImageTransparency = 0.78 + i * 0.08
		hl.ScaleType = Enum.ScaleType.Slice
		hl.SliceCenter = Rect.new(49, 49, 450, 450)
		hl.Parent = main
	end

	local bgMaster = Instance.new("Frame")
	noHit(bgMaster)
	bgMaster.BackgroundColor3 = C.BG
	bgMaster.Size = UDim2.new(1, 0, 1, 0)
	bgMaster.ZIndex = 0
	bgMaster.ClipsDescendants = true
	bgMaster.Parent = main

	local bgGradient = Instance.new("UIGradient")
	bgGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, C.GradA),
		ColorSequenceKeypoint.new(0.3, lerpColor(C.GradA, C.GradB, 0.6)),
		ColorSequenceKeypoint.new(0.6, C.GradB),
		ColorSequenceKeypoint.new(0.8, C.GradC),
		ColorSequenceKeypoint.new(1, C.GradD),
	})
	bgGradient.Rotation = 135
	bgGradient.Parent = bgMaster

	local _bgGradAccum = 0
	poolAdd(function(dt)
		if not bgGradient or not bgGradient.Parent then return false end
		if not ANIM_ENABLED then return true end
		_bgGradAccum = _bgGradAccum + dt
		if _bgGradAccum < 0.05 then return true end
		_bgGradAccum = 0
		local t = tick() * 0.03
		bgGradient.Rotation = 135 + math.sin(t) * 15
		bgGradient.Offset = Vector2.new(math.sin(t * 0.8) * 0.08, math.cos(t * 0.6) * 0.05)
		return true
	end)

	local bgPresets = {}
	local activeBG = "matrix"

	do
		local matrixContainer = Instance.new("Frame")
		noHit(matrixContainer)
		matrixContainer.BackgroundTransparency = 1
		matrixContainer.Size = UDim2.new(1, 0, 1, 0)
		matrixContainer.ZIndex = 1
		matrixContainer.ClipsDescendants = true
		matrixContainer.Visible = true
		matrixContainer.Parent = bgMaster

		local COL_COUNT = 8
		local matrixLabels = {}

		for col = 1, COL_COUNT do
			local colX = (col - 0.5) / COL_COUNT
			local speed = 18 + math.random() * 25
			local ROW_COUNT = 3 + math.random(0, 2)
			local spacing = 1.0 / ROW_COUNT

			for row = 1, ROW_COUNT do
				local lbl = Instance.new("TextLabel")
				noHit(lbl)
				lbl.BackgroundTransparency = 1
				lbl.AnchorPoint = Vector2.new(0.5, 0.5)
				local startY = -0.15 + (row - 1) * spacing + math.random() * 0.05
				lbl.Position = UDim2.new(colX, 0, startY, 0)
				lbl.Size = UDim2.new(0, 90, 0, 24)
				lbl.Font = Enum.Font.GothamBlack
				local fSize = math.floor((10 + math.random() * 6) * SC)
				lbl.TextSize = fSize
				lbl.Text = (math.random() > 0.4) and "EH" or "EXPENSIVE HUB"
				lbl.TextColor3 = C.Text
				lbl.TextTransparency = 0.88 + math.random() * 0.08
				lbl.ZIndex = 1
				lbl.Parent = matrixContainer
				matrixLabels[#matrixLabels + 1] = {
					label = lbl,
					colX = colX,
					startY = startY,
					speed = speed + math.random() * 8,
					baseTr = 0.88 + math.random() * 0.08,
				}
			end
		end

		local bigEH = Instance.new("TextLabel")
		noHit(bigEH)
		bigEH.BackgroundTransparency = 1
		bigEH.AnchorPoint = Vector2.new(0.5, 0.5)
		bigEH.Position = UDim2.new(0.5, 0, 0.5, 0)
		bigEH.Size = UDim2.new(1, 0, 0.5, 0)
		bigEH.Font = Enum.Font.GothamBlack
		bigEH.TextSize = math.floor(140 * SC)
		bigEH.Text = "EH"
		bigEH.TextColor3 = C.Text
		bigEH.TextTransparency = 0.96
		bigEH.ZIndex = 1
		bigEH.Parent = matrixContainer

		local _matrixAccum = 0
		poolAdd(function(dt)
			if not matrixContainer or not matrixContainer.Parent or not matrixContainer.Visible then return true end
			if not ANIM_ENABLED then return true end
			_matrixAccum = _matrixAccum + dt
			if _matrixAccum < 0.033 then return true end
			_matrixAccum = 0
			local now = tick()
			for _, item in ipairs(matrixLabels) do
				local newY = item.startY + (now * item.speed * 0.002) % 1.4
				if newY > 1.2 then newY = newY - 1.4 end
				item.label.Position = UDim2.new(item.colX, 0, newY, 0)
			end
			bigEH.TextTransparency = 0.95 + math.sin(now * 0.15) * 0.02
			return true
		end)

		bgPresets["matrix"] = matrixContainer
	end

	do
		local auroraContainer = Instance.new("Frame")
		noHit(auroraContainer)
		auroraContainer.BackgroundTransparency = 1
		auroraContainer.Size = UDim2.new(1, 0, 1, 0)
		auroraContainer.ZIndex = 1
		auroraContainer.ClipsDescendants = true
		auroraContainer.Visible = false
		auroraContainer.Parent = bgMaster

		local auroraColors = {
			{lerpColor(C.BG, C.Purple, 0.15), lerpColor(C.BG, C.Lilac, 0.2), lerpColor(C.BG, C.ElecBlue, 0.18), lerpColor(C.BG, C.SkyBlue, 0.15), lerpColor(C.BG, C.Mint, 0.12)},
			{lerpColor(C.BG, C.HotPink, 0.1), lerpColor(C.BG, C.Purple, 0.18), lerpColor(C.BG, C.Lavender, 0.15), lerpColor(C.BG, C.Peach, 0.1)},
			{lerpColor(C.BG, C.ElecBlue, 0.12), lerpColor(C.BG, C.Accent, 0.15), lerpColor(C.BG, C.SkyBlue, 0.1)},
		}

		local auroraBands = {}
		local bandConfigs = {
			{pos = {0.5, 0.3}, size = {2.0, 0.35}, rot = -8, alpha = 0.45, colors = auroraColors[1]},
			{pos = {0.45, 0.55}, size = {2.2, 0.3}, rot = 5, alpha = 0.5, colors = auroraColors[2]},
			{pos = {0.55, 0.15}, size = {1.8, 0.2}, rot = -3, alpha = 0.6, colors = auroraColors[3]},
		}

		for i, cfg in ipairs(bandConfigs) do
			local band = Instance.new("Frame")
			noHit(band)
			band.BackgroundColor3 = Color3.new(1, 1, 1)
			band.BackgroundTransparency = cfg.alpha
			band.AnchorPoint = Vector2.new(0.5, 0.5)
			band.Position = UDim2.new(cfg.pos[1], 0, cfg.pos[2], 0)
			band.Size = UDim2.new(cfg.size[1], 0, cfg.size[2], 0)
			band.Rotation = cfg.rot
			band.ZIndex = 1
			band.Parent = auroraContainer
			corner(band, 200)
			local grad = Instance.new("UIGradient")
			local keypoints = {}
			for j, c in ipairs(cfg.colors) do
				keypoints[#keypoints + 1] = ColorSequenceKeypoint.new((j - 1) / (#cfg.colors - 1), c)
			end
			grad.Color = ColorSequence.new(keypoints)
			grad.Parent = band
			auroraBands[#auroraBands + 1] = {frame = band, grad = grad, cfg = cfg}
		end

		for i = 1, 2 do
			local depth = Instance.new("Frame")
			noHit(depth)
			depth.BackgroundColor3 = Color3.fromRGB(8 + i * 2, 8 + i * 2, 14 + i * 2)
			depth.BackgroundTransparency = 0.3 + i * 0.1
			depth.AnchorPoint = Vector2.new(0.5, 0.5)
			depth.Position = UDim2.new(0.5 + (i == 1 and 0.05 or -0.1), 0, 0.4 + i * 0.15, 0)
			depth.Size = UDim2.new(1.6, 0, 0.5, 0)
			depth.Rotation = -4 + i * 8
			depth.ZIndex = 1
			depth.Parent = auroraContainer
			corner(depth, 150)
		end

		local streaks = {}
		local streakColors = {C.Purple, C.ElecBlue, C.Lilac, C.Mint, C.SkyBlue, C.HotPink}
		for i = 1, 6 do
			local streak = Instance.new("Frame")
			noHit(streak)
			streak.BackgroundColor3 = lerpColor(streakColors[i], C.BG, 0.5)
			streak.BackgroundTransparency = 0.88
			streak.AnchorPoint = Vector2.new(0.5, 0.5)
			streak.Position = UDim2.new(0.5, 0, 0.1 + (i - 1) * 0.15, 0)
			streak.Size = UDim2.new(2.5, 0, 0, math.floor((1 + math.random() * 2) * SC))
			streak.Rotation = -12 + (i - 1) * 4
			streak.ZIndex = 2
			streak.Parent = auroraContainer
			local sGrad = Instance.new("UIGradient")
			sGrad.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.25, 0.3),
				NumberSequenceKeypoint.new(0.5, 0.1),
				NumberSequenceKeypoint.new(0.75, 0.3),
				NumberSequenceKeypoint.new(1, 1),
			})
			sGrad.Parent = streak
			streaks[#streaks + 1] = {frame = streak, grad = sGrad, baseY = 0.1 + (i-1) * 0.15, speed = 0.06 + math.random() * 0.08, phase = math.random() * math.pi * 2}
		end

		local auroraParX, auroraParY = 0, 0
		poolAdd(function(dt)
			if not auroraContainer or not auroraContainer.Parent then return false end
			if not auroraContainer.Visible or not ANIM_ENABLED then return true end
			local t = tick() * 0.3
			local mPos = UserInputService:GetMouseLocation()
			local vpS = Camera.ViewportSize
			auroraParX = auroraParX + ((mPos.X / vpS.X - 0.5) * 0.01 - auroraParX) * math.min(dt * 2.5, 1)
			auroraParY = auroraParY + ((mPos.Y / vpS.Y - 0.5) * 0.01 - auroraParY) * math.min(dt * 2.5, 1)

			for i, b in ipairs(auroraBands) do
				b.frame.Rotation = b.cfg.rot + math.sin(t * (0.3 + i * 0.1)) * 3
				b.frame.Position = UDim2.new(
					b.cfg.pos[1] + math.sin(t * (0.2 + i * 0.05)) * 0.03 - auroraParX * (0.8 + i * 0.3),
					0,
					b.cfg.pos[2] + math.cos(t * (0.25 + i * 0.08)) * 0.02 - auroraParY * (0.6 + i * 0.2),
					0
				)
				b.frame.BackgroundTransparency = b.cfg.alpha + math.sin(t * (0.4 + i * 0.15)) * 0.05
				b.grad.Offset = Vector2.new(math.sin(t * (0.12 + i * 0.03)) * 0.15, 0)
			end
			for _, s in ipairs(streaks) do
				s.frame.Position = UDim2.new(0.5 + math.sin(t * s.speed + s.phase) * 0.02, 0, s.baseY + math.cos(t * s.speed * 0.7 + s.phase) * 0.01, 0)
				s.grad.Offset = Vector2.new(math.sin(t * 0.1 + s.phase) * 0.2, 0)
			end
			return true
		end)

		bgPresets["aurora"] = auroraContainer
	end

	do
		local gridContainer = Instance.new("Frame")
		noHit(gridContainer)
		gridContainer.BackgroundTransparency = 1
		gridContainer.Size = UDim2.new(1, 0, 1, 0)
		gridContainer.ZIndex = 1
		gridContainer.ClipsDescendants = true
		gridContainer.Visible = false
		gridContainer.Parent = bgMaster

		local gridDots = {}
		local GRID_COLS = 8
		local GRID_ROWS = 5
		local gridColors = {C.Accent, C.Purple, C.Peach, C.Lilac, C.SkyBlue, C.ElecBlue, C.Mint}

		for row = 1, GRID_ROWS do
			for col = 1, GRID_COLS do
				local px = (col - 0.5) / GRID_COLS
				local py = (row - 0.5) / GRID_ROWS
				local dotS = math.floor((2 + math.random() * 2) * SC)
				local dot = Instance.new("Frame")
				noHit(dot)
				dot.AnchorPoint = Vector2.new(0.5, 0.5)
				dot.BackgroundColor3 = gridColors[math.random(1, #gridColors)]
				dot.BackgroundTransparency = 0.88
				dot.Position = UDim2.new(px, 0, py, 0)
				dot.Size = UDim2.new(0, dotS, 0, dotS)
				dot.ZIndex = 2
				dot.Parent = gridContainer
				corner(dot, math.floor(dotS / 2))
				gridDots[#gridDots + 1] = {
					frame = dot,
					bx = px, by = py,
					speed = 0.15 + math.random() * 0.2,
					phase = math.random() * math.pi * 2,
				}
			end
		end

		for i = 1, 5 do
			local line = Instance.new("Frame")
			noHit(line)
			line.BackgroundColor3 = gridColors[math.random(1, #gridColors)]
			line.BackgroundTransparency = 0.94
			line.AnchorPoint = Vector2.new(0.5, 0.5)
			line.Position = UDim2.new(0.5, 0, i / 6, 0)
			line.Size = UDim2.new(1.2, 0, 0, 1)
			line.Rotation = -3 + math.random() * 6
			line.ZIndex = 1
			line.Parent = gridContainer
			local lGrad = Instance.new("UIGradient")
			lGrad.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.3, 0.5),
				NumberSequenceKeypoint.new(0.7, 0.5),
				NumberSequenceKeypoint.new(1, 1),
			})
			lGrad.Parent = line
		end

		local gridParX, gridParY = 0, 0
		poolAdd(function(dt)
			if not gridContainer or not gridContainer.Parent then return false end
			if not gridContainer.Visible or not ANIM_ENABLED then return true end
			local t = tick() * 0.35
			local mPos = UserInputService:GetMouseLocation()
			local vpS = Camera.ViewportSize
			gridParX = gridParX + ((mPos.X / vpS.X - 0.5) * 0.01 - gridParX) * math.min(dt * 2.5, 1)
			gridParY = gridParY + ((mPos.Y / vpS.Y - 0.5) * 0.01 - gridParY) * math.min(dt * 2.5, 1)
			for i, d in ipairs(gridDots) do
				local px = d.bx + math.sin(t * d.speed + d.phase) * 0.008 - gridParX * (0.5 + (i % 4) * 0.15)
				local py = d.by + math.cos(t * d.speed * 0.8 + d.phase) * 0.006 - gridParY * (0.3 + (i % 3) * 0.1)
				d.frame.Position = UDim2.new(px, 0, py, 0)
				d.frame.BackgroundTransparency = 0.86 + math.sin(t * (0.6 + i * 0.1)) * 0.06
			end
			return true
		end)

		bgPresets["grid"] = gridContainer
	end

	do
		local wavesContainer = Instance.new("Frame")
		noHit(wavesContainer)
		wavesContainer.BackgroundTransparency = 1
		wavesContainer.Size = UDim2.new(1, 0, 1, 0)
		wavesContainer.ZIndex = 1
		wavesContainer.ClipsDescendants = true
		wavesContainer.Visible = false
		wavesContainer.Parent = bgMaster

		local waveFrames = {}
		local waveColors = {C.Wave1, C.Wave2, C.Wave3}
		for i = 1, 3 do
			local wave = Instance.new("Frame")
			noHit(wave)
			wave.BackgroundColor3 = waveColors[i]
			wave.BackgroundTransparency = 0.12 + i * 0.03
			wave.AnchorPoint = Vector2.new(0.5, 0)
			wave.Position = UDim2.new(0.5, 0, 0, TOPBAR_H + (i - 1) * 12)
			wave.Size = UDim2.new(1.3 - i * 0.05, 0, 0.35 - i * 0.05, 0)
			wave.Rotation = -2 + (i - 1) * 2
			wave.ZIndex = 1
			wave.Parent = wavesContainer
			corner(wave, 80)
			local wGrad = Instance.new("UIGradient")
			wGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, lerpColor(waveColors[i], C.BG, 0.3)),
				ColorSequenceKeypoint.new(0.5, waveColors[i]),
				ColorSequenceKeypoint.new(1, lerpColor(waveColors[i], C.BGAlt, 0.4)),
			})
			wGrad.Parent = wave
			waveFrames[#waveFrames + 1] = {frame = wave, grad = wGrad, baseRot = -2 + (i-1) * 2, baseY = TOPBAR_H + (i-1)*12}
		end

		for i = 1, 2 do
			local dark = Instance.new("Frame")
			noHit(dark)
			dark.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
			dark.BackgroundTransparency = 0.25 + i * 0.15
			dark.AnchorPoint = Vector2.new(0.5, 0)
			dark.Position = UDim2.new(0.5 + (i == 1 and 0.05 or -0.1), 0, 0.25 + i * 0.15, 0)
			dark.Size = UDim2.new(1.5, 0, 0.6 - i * 0.05, 0)
			dark.Rotation = -4 + i * 9
			dark.ZIndex = 1
			dark.Parent = wavesContainer
			corner(dark, 100)
		end

		poolAdd(function(dt)
			if not wavesContainer or not wavesContainer.Parent then return false end
			if not wavesContainer.Visible or not ANIM_ENABLED then return true end
			local t = tick() * 0.45
			for i, w in ipairs(waveFrames) do
				w.frame.Rotation = w.baseRot + math.sin(t * (0.5 + i * 0.1)) * 2.5
				w.frame.Position = UDim2.new(
					0.5 + math.sin(t * (0.3 + i * 0.08)) * 0.02,
					0, 0,
					w.baseY + math.cos(t * (0.4 + i * 0.06)) * 4
				)
				w.grad.Offset = Vector2.new(math.sin(t * (0.2 + i * 0.05)) * 0.1, 0)
			end
			return true
		end)

		bgPresets["waves"] = wavesContainer
	end

	do
		local particleContainer = Instance.new("Frame")
		noHit(particleContainer)
		particleContainer.BackgroundTransparency = 1
		particleContainer.Size = UDim2.new(1, 0, 1, 0)
		particleContainer.ZIndex = 1
		particleContainer.ClipsDescendants = true
		particleContainer.Visible = false
		particleContainer.Parent = bgMaster

		local particles = {}
		local pColors = {C.Accent, C.Purple, C.ElecBlue, C.Mint, C.Lilac, C.SkyBlue, C.Peach, C.Lavender}
		for i = 1, 20 do
			local p = Instance.new("Frame")
			noHit(p)
			p.AnchorPoint = Vector2.new(0.5, 0.5)
			p.BackgroundColor3 = pColors[math.random(1, #pColors)]
			local sz = math.floor((2 + math.random() * 6) * SC)
			p.Size = UDim2.new(0, sz, 0, sz)
			p.BackgroundTransparency = 0.82 + math.random() * 0.12
			local px = math.random(5, 95) / 100
			local py = math.random(5, 95) / 100
			p.Position = UDim2.new(px, 0, py, 0)
			p.ZIndex = 1
			p.Parent = particleContainer
			corner(p, math.floor(sz / 2))
			particles[#particles + 1] = {
				frame = p,
				bx = px, by = py,
				vx = (math.random() - 0.5) * 0.01,
				vy = -0.002 - math.random() * 0.005,
				speed = 0.3 + math.random() * 0.5,
				phase = math.random() * math.pi * 2,
				baseTr = 0.82 + math.random() * 0.12,
			}
		end

		local pParX, pParY = 0, 0
		poolAdd(function(dt)
			if not particleContainer or not particleContainer.Parent then return false end
			if not particleContainer.Visible or not ANIM_ENABLED then return true end
			local t = tick()
			local mPos = UserInputService:GetMouseLocation()
			local vpS = Camera.ViewportSize
			pParX = pParX + ((mPos.X / vpS.X - 0.5) * 0.015 - pParX) * math.min(dt * 2, 1)
			pParY = pParY + ((mPos.Y / vpS.Y - 0.5) * 0.015 - pParY) * math.min(dt * 2, 1)
			for i, p in ipairs(particles) do
				p.bx = p.bx + p.vx * dt
				p.by = p.by + p.vy * dt
				if p.by < -0.1 then p.by = 1.1; p.bx = math.random(5, 95) / 100 end
				if p.bx < -0.1 then p.bx = 1.1 end
				if p.bx > 1.1 then p.bx = -0.1 end
				local wobbleX = math.sin(t * p.speed + p.phase) * 0.008
				local wobbleY = math.cos(t * p.speed * 0.7 + p.phase) * 0.005
				p.frame.Position = UDim2.new(
					p.bx + wobbleX - pParX * (0.5 + (i % 5) * 0.2),
					0,
					p.by + wobbleY - pParY * (0.3 + (i % 4) * 0.15),
					0
				)
				p.frame.BackgroundTransparency = p.baseTr + math.sin(t * (0.5 + i * 0.08)) * 0.06
			end
			return true
		end)

		bgPresets["particles"] = particleContainer
	end

	function W:SetBackground(name)
		name = name or "matrix"
		for k, container in pairs(bgPresets) do
			container.Visible = (k == name)
		end
		activeBG = name
	end

	function W:GetBackgroundNames()
		local names = {}
		for k in pairs(bgPresets) do
			names[#names + 1] = k
		end
		table.sort(names)
		return names
	end

	W:SetBackground(activeBG)

	if introOn then
		-- Plain Frame, NOT a CanvasGroup: CanvasGroup pre-rasterizes all children
		-- into an offscreen buffer, which blurs text/icons (very visible fullscreen on hi-res).
		-- All elements already fade out individually below, so the final fade only needs
		-- to dissolve this background fill via BackgroundTransparency.
		local intro = Instance.new("Frame")
		intro.BackgroundTransparency = 0
		intro.BackgroundColor3 = C.BG
		intro.Size = UDim2.new(1, 0, 1, 0)
		intro.ZIndex = 100
		intro.ClipsDescendants = true
		intro.Parent = screenGui

		local cY = 0.42

		local glow1 = Instance.new("ImageLabel")
		noHit(glow1)
		glow1.BackgroundTransparency = 1
		glow1.AnchorPoint = Vector2.new(0.5, 0.5)
		glow1.Position = UDim2.new(0.5, 0, cY, 0)
		glow1.Size = UDim2.new(0, 0, 0, 0)
		glow1.Image = "rbxassetid://6031280882"
		glow1.ImageColor3 = C.Accent
		glow1.ImageTransparency = 1
		glow1.ScaleType = Enum.ScaleType.Fit
		glow1.ZIndex = 101
		glow1.Parent = intro

		local orbA = Instance.new("Frame")
		noHit(orbA)
		orbA.BackgroundColor3 = C.Accent
		orbA.BackgroundTransparency = 0.9
		orbA.AnchorPoint = Vector2.new(0.5, 0.5)
		orbA.Position = UDim2.new(0.5, 0, cY, 0)
		orbA.Size = UDim2.new(0, 0, 0, 0)
		orbA.ZIndex = 101
		orbA.Parent = intro
		corner(orbA, 999)

		local orbB = Instance.new("Frame")
		noHit(orbB)
		orbB.BackgroundColor3 = lerpColor(C.Accent, Color3.new(1,1,1), 0.3)
		orbB.BackgroundTransparency = 0.94
		orbB.AnchorPoint = Vector2.new(0.5, 0.5)
		orbB.Position = UDim2.new(0.5, 0, cY, 0)
		orbB.Size = UDim2.new(0, 0, 0, 0)
		orbB.ZIndex = 101
		orbB.Parent = intro
		corner(orbB, 999)

		local ring = Instance.new("Frame")
		noHit(ring)
		ring.BackgroundTransparency = 1
		ring.AnchorPoint = Vector2.new(0.5, 0.5)
		ring.Position = UDim2.new(0.5, 0, cY, 0)
		ring.Size = UDim2.new(0, 0, 0, 0)
		ring.ZIndex = 102
		ring.Parent = intro
		corner(ring, 999)
		strokeInst(ring, C.Accent, 1.5, 1)

		local iconSz = math.floor(56 * SC)
		local iIcon = Instance.new("ImageLabel")
		noHit(iIcon)
		iIcon.BackgroundTransparency = 1
		iIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		iIcon.Position = UDim2.new(0.5, 0, cY, 0)
		iIcon.Size = UDim2.new(0, 0, 0, 0)
		iIcon.Image = getIconAsset("flare") or ""
		iIcon.ImageColor3 = C.Accent
		iIcon.ImageTransparency = 1
		iIcon.ScaleType = Enum.ScaleType.Fit
		iIcon.ZIndex = 106
		iIcon.Rotation = -180
		iIcon.Parent = intro

		local iTitle = Instance.new("TextLabel")
		noHit(iTitle)
		iTitle.BackgroundTransparency = 1
		iTitle.AnchorPoint = Vector2.new(0.5, 0)
		iTitle.Position = UDim2.new(0.5, 0, cY + 0.1, 0)
		iTitle.Size = UDim2.new(0.8, 0, 0, math.floor(36 * SC))
		iTitle.Font = Enum.Font.GothamBlack
		iTitle.TextSize = math.floor(30 * SC)
		iTitle.RichText = true
		iTitle.Text = ""
		iTitle.TextColor3 = C.Text
		iTitle.TextTransparency = 1
		iTitle.ZIndex = 106
		iTitle.Parent = intro

		local iSub = Instance.new("TextLabel")
		noHit(iSub)
		iSub.BackgroundTransparency = 1
		iSub.AnchorPoint = Vector2.new(0.5, 0)
		iSub.Position = UDim2.new(0.5, 0, cY + 0.19, 0)
		iSub.Size = UDim2.new(0.5, 0, 0, math.floor(16 * SC))
		iSub.Font = Enum.Font.GothamMedium
		iSub.TextSize = math.floor(12 * SC)
		iSub.Text = cfg.Subtitle or "by skg & n3x"
		iSub.TextColor3 = C.Sub
		iSub.TextTransparency = 1
		iSub.ZIndex = 106
		iSub.Parent = intro

		local barBg = Instance.new("Frame")
		noHit(barBg)
		barBg.AnchorPoint = Vector2.new(0.5, 0)
		barBg.BackgroundColor3 = C.Surface
		barBg.BackgroundTransparency = 1
		barBg.Position = UDim2.new(0.5, 0, cY + 0.26, 0)
		barBg.Size = UDim2.new(0.18, 0, 0, math.floor(3 * SC))
		barBg.ZIndex = 105
		barBg.ClipsDescendants = true
		barBg.Parent = intro
		corner(barBg, 2)
		local barFill = Instance.new("Frame")
		noHit(barFill)
		barFill.BackgroundColor3 = C.Accent
		barFill.Size = UDim2.new(0, 0, 1, 0)
		barFill.ZIndex = 106
		barFill.Parent = barBg
		corner(barFill, 2)

		local dots = {}
		for i = 1, 10 do
			local d = Instance.new("Frame")
			noHit(d)
			d.AnchorPoint = Vector2.new(0.5, 0.5)
			d.BackgroundColor3 = lerpColor(C.Accent, Color3.new(1,1,1), math.random() * 0.3)
			d.BackgroundTransparency = 1
			local sz = math.floor((2 + math.random() * 3) * SC)
			d.Size = UDim2.new(0, sz, 0, sz)
			d.Position = UDim2.new(0.5, 0, cY, 0)
			d.ZIndex = 104
			d.Parent = intro
			corner(d, sz)
			dots[i] = d
		end

		local line1 = Instance.new("Frame")
		noHit(line1)
		line1.AnchorPoint = Vector2.new(0.5, 0.5)
		line1.BackgroundColor3 = C.Accent
		line1.BackgroundTransparency = 1
		line1.Position = UDim2.new(0.5, 0, cY, 0)
		line1.Size = UDim2.new(0, 0, 0, 1)
		line1.ZIndex = 102
		line1.Parent = intro

		task.spawn(function()
			task.wait(0.05)

			-- Build-up: everything overlaps and snaps in fast instead of the old
			-- ~1.2s-per-element crawl. Ring spins as it grows for a bit of energy.
			tw(orbA, 0.55, {Size = UDim2.new(0, math.floor(280*SC), 0, math.floor(280*SC)), BackgroundTransparency = 0.85}, Enum.EasingStyle.Quint)
			tw(orbB, 0.6, {Size = UDim2.new(0, math.floor(200*SC), 0, math.floor(200*SC)), BackgroundTransparency = 0.9}, Enum.EasingStyle.Quint)
			tw(line1, 0.4, {Size = UDim2.new(0, math.floor(120*SC), 0, 1), BackgroundTransparency = 0.7}, Enum.EasingStyle.Quint)

			tw(ring, 0.45, {Size = UDim2.new(0, math.floor(85*SC), 0, math.floor(85*SC)), Rotation = 90}, Enum.EasingStyle.Quint)
			for _, s in pairs(ring:GetChildren()) do
				if s:IsA("UIStroke") then tw(s, 0.45, {Transparency = 0.25}, Enum.EasingStyle.Quint) end
			end

			task.wait(0.12)
			tw(glow1, 0.4, {Size = UDim2.new(0, math.floor(120*SC), 0, math.floor(120*SC)), ImageTransparency = 0.7}, Enum.EasingStyle.Quint)
			tw(iIcon, 0.45, {Size = UDim2.new(0, iconSz, 0, iconSz), ImageTransparency = 0, Rotation = 0}, Enum.EasingStyle.Back)
			playSound(Sounds.expand, 0.12, 1.15)

			for i, d in ipairs(dots) do
				local ang = (i / #dots) * math.pi * 2 + math.random() * 0.3
				local dist = math.floor((55 + math.random() * 35) * SC)
				local tx = 0.5 + math.cos(ang) * dist / 800
				local ty = cY + math.sin(ang) * dist / 600
				task.delay(i * 0.012, function()
					tw(d, 0.35, {Position = UDim2.new(tx, 0, ty, 0), BackgroundTransparency = 0.2}, Enum.EasingStyle.Quint)
				end)
				task.delay(0.28 + i * 0.02, function()
					tw(d, 0.28, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Quint)
				end)
			end

			task.wait(0.33)
			-- Icon pop + an expanding accent shockwave ring for a punchier hit.
			tw(iIcon, 0.13, {Size = UDim2.new(0, math.floor(iconSz*1.18), 0, math.floor(iconSz*1.18))}, Enum.EasingStyle.Quint)
			local shock = Instance.new("Frame")
			noHit(shock)
			shock.AnchorPoint = Vector2.new(0.5, 0.5)
			shock.BackgroundTransparency = 1
			shock.Position = UDim2.new(0.5, 0, cY, 0)
			shock.Size = UDim2.new(0, math.floor(60*SC), 0, math.floor(60*SC))
			shock.ZIndex = 103
			shock.Parent = intro
			corner(shock, 999)
			local shockStroke = strokeInst(shock, C.Accent, 2, 0.2)
			tw(shock, 0.5, {Size = UDim2.new(0, math.floor(230*SC), 0, math.floor(230*SC))}, Enum.EasingStyle.Quint)
			tw(shockStroke, 0.5, {Transparency = 1, Thickness = 0}, Enum.EasingStyle.Quint)
			task.delay(0.55, function() if shock and shock.Parent then shock:Destroy() end end)
			task.wait(0.11)
			tw(iIcon, 0.18, {Size = UDim2.new(0, iconSz, 0, iconSz)}, Enum.EasingStyle.Back)

			task.wait(0.06)
			local fullTitle = title or "Expensive Hub"
			iTitle.TextTransparency = 0
			for ci = 1, #fullTitle do
				iTitle.Text = string.sub(fullTitle, 1, ci)
				task.wait(0.018)
			end

			task.wait(0.05)
			tw(iSub, 0.3, {TextTransparency = 0}, Enum.EasingStyle.Quint)
			tw(line1, 0.35, {Size = UDim2.new(0, math.floor(200*SC), 0, 1), BackgroundTransparency = 0.85}, Enum.EasingStyle.Quint)

			task.wait(0.08)
			tw(barBg, 0.2, {BackgroundTransparency = 0.5})
			tw(barFill, 0.5, {Size = UDim2.new(1, 0, 1, 0)}, Enum.EasingStyle.Quint)

			task.wait(0.5)

			-- Snappy outro: elements burst outward and dissolve.
			for _, s in pairs(ring:GetChildren()) do
				if s:IsA("UIStroke") then tw(s, 0.22, {Transparency = 1}) end
			end
			tw(ring, 0.3, {Size = UDim2.new(0, math.floor(200*SC), 0, math.floor(200*SC)), Rotation = 200}, Enum.EasingStyle.Quint)
			tw(iIcon, 0.3, {ImageTransparency = 1, Size = UDim2.new(0, math.floor(iconSz*0.4), 0, math.floor(iconSz*0.4)), Rotation = 120}, Enum.EasingStyle.Quint)
			tw(glow1, 0.3, {ImageTransparency = 1, Size = UDim2.new(0, math.floor(210*SC), 0, math.floor(210*SC))}, Enum.EasingStyle.Quint)
			tw(iTitle, 0.25, {TextTransparency = 1, Position = UDim2.new(0.5, 0, cY + 0.06, 0)}, Enum.EasingStyle.Quint)
			tw(iSub, 0.2, {TextTransparency = 1}, Enum.EasingStyle.Quint)
			tw(barBg, 0.2, {BackgroundTransparency = 1})
			tw(barFill, 0.2, {BackgroundTransparency = 1})
			tw(line1, 0.25, {BackgroundTransparency = 1})
			tw(orbA, 0.35, {Size = UDim2.new(0, math.floor(520*SC), 0, math.floor(520*SC)), BackgroundTransparency = 1}, Enum.EasingStyle.Quint)
			tw(orbB, 0.35, {BackgroundTransparency = 1}, Enum.EasingStyle.Quint)

			task.wait(0.22)
			tw(intro, 0.28, {BackgroundTransparency = 1}, Enum.EasingStyle.Quint)
			task.wait(0.32)
			if intro and intro.Parent then intro:Destroy() end
		end)
	end

	task.spawn(function()
		if introOn then task.wait(1.45) end
		if blurEnabled then showBlur() end
		tw(main, 0.6, {Size = UDim2.new(0, WW, 0, WH), GroupTransparency = 0}, Enum.EasingStyle.Back)
		playSound(Sounds.expand, 0.15, 0.9)
	end)

	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"
	topbar.BackgroundColor3 = C.TopbarBG
	topbar.BackgroundTransparency = 0
	topbar.Position = UDim2.new(0, 0, 0, 0)
	topbar.Size = UDim2.new(1, 0, 0, TOPBAR_H)
	topbar.ZIndex = 30
	topbar.BorderSizePixel = 0
	topbar.Parent = main

	local topbarOverlay = Instance.new("Frame")
	noHit(topbarOverlay)
	topbarOverlay.BackgroundColor3 = Color3.new(1, 1, 1)
	topbarOverlay.BackgroundTransparency = 0.92
	topbarOverlay.Size = UDim2.new(1, 0, 1, 0)
	topbarOverlay.ZIndex = 30
	topbarOverlay.Parent = topbar
	local tbGrad = Instance.new("UIGradient")
	tbGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, lerpColor(C.PurpleSub, C.BG, 0.7)),
		ColorSequenceKeypoint.new(0.5, C.BG),
		ColorSequenceKeypoint.new(1, lerpColor(C.AccentSub, C.BG, 0.6)),
	})
	tbGrad.Parent = topbarOverlay

	local topbarBotLine = Instance.new("Frame")
	noHit(topbarBotLine)
	topbarBotLine.BackgroundColor3 = C.Border
	topbarBotLine.BackgroundTransparency = 0.5
	topbarBotLine.Position = UDim2.new(0, 0, 1, -1)
	topbarBotLine.Size = UDim2.new(1, 0, 0, 1)
	topbarBotLine.ZIndex = 31
	topbarBotLine.Parent = topbar

	local logoIcon = Instance.new("ImageLabel")
	noHit(logoIcon)
	logoIcon.BackgroundTransparency = 1
	logoIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	logoIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	logoIcon.Size = UDim2.new(0, math.floor(26 * SC), 0, math.floor(26 * SC))
	logoIcon.Image = getIconAsset("flare") or "rbxassetid://6031280882"
	logoIcon.ImageColor3 = C.Accent
	logoIcon.ScaleType = Enum.ScaleType.Fit
	logoIcon.ZIndex = 32
	logoIcon.Rotation = 0
	logoIcon.Parent = topbar

	local logoText = Instance.new("TextLabel")
	noHit(logoText)
	logoText.BackgroundTransparency = 1
	logoText.Position = UDim2.new(0, 46, 0, 0)
	logoText.Size = UDim2.new(0, 220, 1, 0)
	logoText.Font = Enum.Font.GothamBlack
	logoText.TextSize = FONT_TITLE
	logoText.RichText = true
	logoText.Text = string.format(
		'<font color="rgb(%d,%d,%d)">Expensive</font> <font color="rgb(%d,%d,%d)">Hub</font>',
		math.floor(C.Text.R * 255), math.floor(C.Text.G * 255), math.floor(C.Text.B * 255),
		math.floor(C.Dim.R * 255), math.floor(C.Dim.G * 255), math.floor(C.Dim.B * 255)
	)
	logoText.TextXAlignment = Enum.TextXAlignment.Left
	logoText.TextTransparency = 1
	logoText.ZIndex = 32
	logoText.Parent = topbar

	task.spawn(function()
		if introOn then task.wait(1.8) else task.wait(0.8) end
		tw(logoIcon, 0.5, {Rotation = 720, Position = UDim2.new(0, 27, 0.5, 0)}, Enum.EasingStyle.Quint)
		task.wait(0.4)
		tw(logoIcon, 0.3, {Rotation = 0}, Enum.EasingStyle.Back)
		tw(logoText, 0.5, {TextTransparency = 0}, Enum.EasingStyle.Quint)
	end)

	local searchContainer = Instance.new("Frame")
	searchContainer.Active = true
	searchContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	searchContainer.BackgroundColor3 = C.Surface
	searchContainer.BackgroundTransparency = 0.3
	searchContainer.Position = UDim2.new(0.5, 20, 0.5, 0)
	searchContainer.Size = UDim2.new(0, math.floor(240 * SC), 0, math.floor(30 * SC))
	searchContainer.ZIndex = 33
	searchContainer.Parent = topbar
	corner(searchContainer, 12)
	strokeInst(searchContainer, C.Border, 1, 0.45)

	local searchIcon = Instance.new("TextLabel")
	noHit(searchIcon)
	searchIcon.BackgroundTransparency = 1
	searchIcon.Position = UDim2.new(0, 10, 0, 0)
	searchIcon.Size = UDim2.new(0, 20, 1, 0)
	searchIcon.Font = Enum.Font.GothamBold
	searchIcon.TextSize = math.floor(14 * SC)
	searchIcon.Text = ""
	searchIcon.TextColor3 = C.Dim
	local searchImgIcon = Instance.new("ImageLabel")
	noHit(searchImgIcon)
	searchImgIcon.BackgroundTransparency = 1
	searchImgIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	searchImgIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	searchImgIcon.Size = UDim2.new(0, math.floor(14 * SC), 0, math.floor(14 * SC))
	searchImgIcon.Image = getIconAsset("search") or ""
	searchImgIcon.ImageColor3 = C.Dim
	searchImgIcon.ScaleType = Enum.ScaleType.Fit
	searchImgIcon.ZIndex = 33
	searchImgIcon.Parent = searchIcon
	searchIcon.ZIndex = 34
	searchIcon.Parent = searchContainer

	local searchBox = Instance.new("TextBox")
	searchBox.BackgroundTransparency = 1
	searchBox.Position = UDim2.new(0, 30, 0, 0)
	searchBox.Size = UDim2.new(1, -70, 1, 0)
	searchBox.Font = Enum.Font.GothamMedium
	searchBox.TextSize = math.floor(11 * SC)
	searchBox.Text = ""
	searchBox.PlaceholderText = "Search... (Ctrl+K)"
	searchBox.PlaceholderColor3 = C.Dim
	searchBox.TextColor3 = C.Text
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.ClearTextOnFocus = true
	searchBox.ZIndex = 35
	searchBox.Parent = searchContainer

	local searchKbd = Instance.new("TextLabel")
	noHit(searchKbd)
	searchKbd.AnchorPoint = Vector2.new(1, 0.5)
	searchKbd.BackgroundColor3 = C.BGAlt
	searchKbd.BackgroundTransparency = 0.4
	searchKbd.Position = UDim2.new(1, -6, 0.5, 0)
	searchKbd.Size = UDim2.new(0, 36, 0, 18)
	searchKbd.Font = Enum.Font.GothamBold
	searchKbd.TextSize = math.floor(8 * SC)
	searchKbd.Text = "Ctrl K"
	searchKbd.TextColor3 = C.Dim
	searchKbd.ZIndex = 34
	searchKbd.Parent = searchContainer
	corner(searchKbd, 5)

	local function createCtrlBtn(symbol, posX, hoverColor, callback)
		local btn = Instance.new("TextButton")
		btn.AnchorPoint = Vector2.new(1, 0.5)
		btn.BackgroundTransparency = 1
		btn.BackgroundColor3 = hoverColor
		btn.Position = UDim2.new(1, posX, 0.5, 0)
		btn.Size = UDim2.new(0, 34, 0, 34)
		btn.Text = symbol
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = symbol == "\xC3\x97" and 22 or 16
		btn.TextColor3 = C.Dim
		btn.AutoButtonColor = false
		btn.ZIndex = 35
		btn.Parent = topbar
		corner(btn, 11)

		btn.MouseEnter:Connect(function()
			tw(btn, 0.14, {BackgroundTransparency = 0.75, TextColor3 = hoverColor})
			playSound(Sounds.hover, 0.05, 1.3)
		end)
		btn.MouseLeave:Connect(function()
			tw(btn, 0.14, {BackgroundTransparency = 1, TextColor3 = C.Dim})
		end)
		btn.MouseButton1Click:Connect(function()
			playSound(Sounds.click, 0.12, 1.0)
			createRipple(btn, hoverColor)
			callback()
		end)
		return btn
	end

	local function hideWindow()
		W.Visible = false
		playSound(Sounds.collapse, 0.12, 1.1)
		hideBlur()
		tw(main, 0.35, {
			GroupTransparency = 1,
			Size = UDim2.new(0, WW * 0.92, 0, WH * 0.92),
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.38, function()
			main.Visible = false
		end)
	end

	local function showWindow()
		W.Visible = true
		main.Visible = true
		if blurEnabled then showBlur() end
		playSound(Sounds.expand, 0.12, 0.95)
		tw(main, 0.5, {
			GroupTransparency = 0,
			Size = UDim2.new(0, WW, 0, WH),
		}, Enum.EasingStyle.Back)
	end

	createCtrlBtn("\xC3\x97", -14, C.Err, hideWindow)
	createCtrlBtn("\xE2\x80\x94", -52, C.Warn, hideWindow)
	makeDrag(main, topbar)

	trackConn(UserInputService.InputBegan:Connect(function(input, gpe)
		if input.KeyCode == keybind then
			local focused = UserInputService:GetFocusedTextBox()
			if focused then return end
			if W.Visible then hideWindow() else showWindow() end
		end
	end))

	if IS_MOBILE then
		local mobileBtn = Instance.new("TextButton")
		mobileBtn.AnchorPoint = Vector2.new(0, 1)
		mobileBtn.BackgroundColor3 = C.Surface
		mobileBtn.BackgroundTransparency = 0.1
		mobileBtn.Position = UDim2.new(0, 12, 1, -12)
		mobileBtn.Size = UDim2.new(0, 48, 0, 48)
		mobileBtn.Text = ""
		mobileBtn.Font = Enum.Font.GothamBold
		mobileBtn.TextSize = 22
		mobileBtn.TextColor3 = C.Accent
		mobileBtn.AutoButtonColor = false
		mobileBtn.ZIndex = 99
		mobileBtn.Parent = screenGui
		corner(mobileBtn, 24)
		strokeInst(mobileBtn, C.Border, 1.5, 0.3)
		addClayShadow(mobileBtn, 24)

		local mobileIcon = Instance.new("ImageLabel")
		noHit(mobileIcon)
		mobileIcon.BackgroundTransparency = 1
		mobileIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		mobileIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
		mobileIcon.Size = UDim2.new(0, 26, 0, 26)
		mobileIcon.Image = getIconAsset("flare") or "rbxassetid://6031280882"
		mobileIcon.ImageColor3 = C.Accent
		mobileIcon.ScaleType = Enum.ScaleType.Fit
		mobileIcon.ZIndex = 100
		mobileIcon.Parent = mobileBtn

		local mobileDragging = false
		local mobileDragStart = nil
		local mobileBtnStart = nil

		mobileBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				mobileDragging = true
				mobileDragStart = input.Position
				mobileBtnStart = mobileBtn.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						mobileDragging = false
					end
				end)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if mobileDragging and input.UserInputType == Enum.UserInputType.Touch then
				local delta = input.Position - mobileDragStart
				if delta.Magnitude > 15 then
					mobileBtn.Position = UDim2.new(
						mobileBtnStart.X.Scale, mobileBtnStart.X.Offset + delta.X,
						mobileBtnStart.Y.Scale, mobileBtnStart.Y.Offset + delta.Y
					)
				end
			end
		end)

		mobileBtn.MouseButton1Click:Connect(function()
			playSound(Sounds.click, 0.12, 1.0)
			createRipple(mobileBtn, C.Accent)
			if W.Visible then
				hideWindow()
				tw(mobileBtn, 0.2, {BackgroundTransparency = 0.1})
			else
				showWindow()
				tw(mobileBtn, 0.2, {BackgroundTransparency = 0.4})
			end
		end)

		poolAdd(function(dt)
			if not mobileBtn or not mobileBtn.Parent then return false end
			if not ANIM_ENABLED then return true end
			local t = tick() * 2
			mobileBtn.Rotation = math.sin(t * 0.3) * 3
			return true
		end)
	end

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.BackgroundColor3 = C.SidebarBG
	sidebar.BackgroundTransparency = 0.03
	sidebar.Position = UDim2.new(0, 0, 0, TOPBAR_H)
	sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -TOPBAR_H - FOOTER_H)
	sidebar.ZIndex = 25
	sidebar.BorderSizePixel = 0
	sidebar.ClipsDescendants = true
	sidebar.Parent = main

	local sideGrad = Instance.new("UIGradient")
	sideGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, C.SidebarBG),
		ColorSequenceKeypoint.new(1, lerpColor(C.SidebarBG, C.BG, 0.5)),
	})
	sideGrad.Rotation = 180
	sideGrad.Parent = sidebar

	local sideRightLine = Instance.new("Frame")
	noHit(sideRightLine)
	sideRightLine.BackgroundColor3 = C.Border
	sideRightLine.BackgroundTransparency = 0.5
	sideRightLine.Position = UDim2.new(1, -1, 0, 0)
	sideRightLine.Size = UDim2.new(0, 1, 1, 0)
	sideRightLine.ZIndex = 26
	sideRightLine.Parent = sidebar

	local sideScroll = Instance.new("ScrollingFrame")
	sideScroll.BackgroundTransparency = 1
	sideScroll.Size = UDim2.new(1, 0, 1, -math.floor(56 * SC))
	sideScroll.Position = UDim2.new(0, 0, 0, math.floor(56 * SC))
	sideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	sideScroll.ScrollBarThickness = 0
	sideScroll.ZIndex = 26
	sideScroll.Parent = sidebar
	pad(sideScroll, 6, 12, 0, 0)

	local sideLayout = uiList(sideScroll, 7, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top)
	sideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		task.defer(function()
			if sideScroll and sideScroll.Parent then
				-- AbsoluteContentSize is in scaled px; divide by UIScale so CanvasSize (local
				-- space) stays correct when UI Scale < 100% — otherwise the canvas shrinks
				-- below the content and the bottom tabs become unreachable.
				sideScroll.CanvasSize = UDim2.new(0, 0, 0, sideLayout.AbsoluteContentSize.Y / math.max(uiScaleObj.Scale, 0.01) + 24)
			end
		end)
	end)

	local playerInfoFrame = Instance.new("Frame")
	noHit(playerInfoFrame)
	playerInfoFrame.BackgroundTransparency = 1
	playerInfoFrame.Size = UDim2.new(1, 0, 0, math.floor(50 * SC))
	playerInfoFrame.Position = UDim2.new(0, 0, 0, 4)
	playerInfoFrame.ZIndex = 27
	playerInfoFrame.Parent = sidebar

	local playerAvatar = Instance.new("ImageLabel")
	noHit(playerAvatar)
	playerAvatar.AnchorPoint = Vector2.new(0.5, 0.5)
	playerAvatar.BackgroundColor3 = C.AccentSub
	playerAvatar.BackgroundTransparency = 0.4
	playerAvatar.Position = UDim2.new(0, math.floor(SIDEBAR_W / 2), 0.5, 0)
	playerAvatar.Size = UDim2.new(0, math.floor(32 * SC), 0, math.floor(32 * SC))
	playerAvatar.ZIndex = 28
	playerAvatar.Parent = playerInfoFrame
	corner(playerAvatar, math.floor(16 * SC))
	pcall(function()
		playerAvatar.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	strokeInst(playerAvatar, C.Border, 1.5, 0.3)

	local playerNameLabel = Instance.new("TextLabel")
	noHit(playerNameLabel)
	playerNameLabel.BackgroundTransparency = 1
	playerNameLabel.Position = UDim2.new(0, math.floor(SIDEBAR_W / 2) + math.floor(22 * SC), 0, 6)
	playerNameLabel.Size = UDim2.new(1, -math.floor(SIDEBAR_W / 2) - math.floor(28 * SC), 0, math.floor(18 * SC))
	playerNameLabel.Font = Enum.Font.GothamBold
	playerNameLabel.TextSize = math.floor(11 * SC)
	playerNameLabel.Text = Player.DisplayName
	playerNameLabel.TextColor3 = C.Text
	playerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	playerNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	playerNameLabel.TextTransparency = 1
	playerNameLabel.Visible = false
	playerNameLabel.ZIndex = 28
	playerNameLabel.Parent = playerInfoFrame

	local playerIdLabel = Instance.new("TextLabel")
	noHit(playerIdLabel)
	playerIdLabel.BackgroundTransparency = 1
	playerIdLabel.Position = UDim2.new(0, math.floor(SIDEBAR_W / 2) + math.floor(22 * SC), 0, math.floor(24 * SC))
	playerIdLabel.Size = UDim2.new(1, -math.floor(SIDEBAR_W / 2) - math.floor(28 * SC), 0, math.floor(14 * SC))
	playerIdLabel.Font = Enum.Font.GothamMedium
	playerIdLabel.TextSize = math.floor(9 * SC)
	playerIdLabel.Text = "ID: " .. tostring(Player.UserId)
	playerIdLabel.TextColor3 = C.Dim
	playerIdLabel.TextXAlignment = Enum.TextXAlignment.Left
	playerIdLabel.TextTruncate = Enum.TextTruncate.AtEnd
	playerIdLabel.TextTransparency = 1
	playerIdLabel.Visible = false
	playerIdLabel.ZIndex = 28
	playerIdLabel.Parent = playerInfoFrame
	local _allSideLabels = {}
	local _sidebarTweens = {}

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.ClipsDescendants = true
	content.Position = UDim2.new(0, SIDEBAR_W, 0, TOPBAR_H)
	content.Size = UDim2.new(1, -SIDEBAR_W, 1, -TOPBAR_H - FOOTER_H)
	content.ZIndex = 5
	content.Parent = main

	local function cancelSidebarTweens()
		for _, t in ipairs(_sidebarTweens) do
			pcall(function() t:Cancel() end)
		end
		_sidebarTweens = {}
	end

	local function expandSidebar()
		if sidebarExpanded then return end
		sidebarExpanded = true
		playSound(Sounds.expand, 0.06, 1.15)
		cancelSidebarTweens()
		local dur = 0.25
		local style = Enum.EasingStyle.Quart
		local dir = Enum.EasingDirection.Out
		local info = TweenInfo.new(dur, style, dir)
		_sidebarTweens[#_sidebarTweens+1] = TweenService:Create(sidebar, info, {Size = UDim2.new(0, SIDEBAR_EXP, 1, -TOPBAR_H - FOOTER_H)})
		_sidebarTweens[#_sidebarTweens+1] = TweenService:Create(content, info, {Position = UDim2.new(0, SIDEBAR_EXP, 0, TOPBAR_H)})
		for _, t in ipairs(_sidebarTweens) do t:Play() end
		for _, info2 in ipairs(_allSideLabels) do
			if info2.label and info2.label.Parent then
				info2.label.Visible = true
				tw(info2.label, dur, {TextTransparency = 0}, style, dir)
			end
		end
		if playerNameLabel and playerNameLabel.Parent then
			playerNameLabel.Visible = true
			playerIdLabel.Visible = true
			tw(playerNameLabel, dur, {TextTransparency = 0}, style, dir)
			tw(playerIdLabel, dur, {TextTransparency = 0}, style, dir)
		end
	end

	local function collapseSidebar()
		if not sidebarExpanded then return end
		sidebarExpanded = false
		playSound(Sounds.collapse, 0.04, 1.2)
		cancelSidebarTweens()
		local dur = 0.2
		local style = Enum.EasingStyle.Quart
		local dir = Enum.EasingDirection.Out
		local info = TweenInfo.new(dur, style, dir)
		_sidebarTweens[#_sidebarTweens+1] = TweenService:Create(sidebar, info, {Size = UDim2.new(0, SIDEBAR_W, 1, -TOPBAR_H - FOOTER_H)})
		_sidebarTweens[#_sidebarTweens+1] = TweenService:Create(content, info, {Position = UDim2.new(0, SIDEBAR_W, 0, TOPBAR_H)})
		for _, t in ipairs(_sidebarTweens) do t:Play() end
		for _, info2 in ipairs(_allSideLabels) do
			if info2.label and info2.label.Parent then
				tw(info2.label, dur, {TextTransparency = 1}, style, dir)
				task.delay(dur, function()
					if not sidebarExpanded and info2.label and info2.label.Parent then info2.label.Visible = false end
				end)
			end
		end
		if playerNameLabel and playerNameLabel.Parent then
			tw(playerNameLabel, dur, {TextTransparency = 1}, style, dir)
			tw(playerIdLabel, dur, {TextTransparency = 1}, style, dir)
			task.delay(dur, function()
				if not sidebarExpanded and playerNameLabel and playerNameLabel.Parent then
					playerNameLabel.Visible = false
					playerIdLabel.Visible = false
				end
			end)
		end
	end

	sidebar.MouseEnter:Connect(function()
		if not sidebarHoverLock then expandSidebar() end
	end)
	sidebar.MouseLeave:Connect(function()
		if not sidebarHoverLock then collapseSidebar() end
	end)

	local footer = Instance.new("Frame")
	footer.Name = "Footer"
	footer.BackgroundColor3 = C.FooterBG
	footer.BackgroundTransparency = 0.08
	footer.Position = UDim2.new(0, 0, 1, -FOOTER_H)
	footer.Size = UDim2.new(1, 0, 0, FOOTER_H)
	footer.ZIndex = 30
	footer.BorderSizePixel = 0
	footer.Parent = main

	local footerTopLine = Instance.new("Frame")
	noHit(footerTopLine)
	footerTopLine.BackgroundColor3 = C.Border
	footerTopLine.BackgroundTransparency = 0.5
	footerTopLine.Size = UDim2.new(1, 0, 0, 1)
	footerTopLine.ZIndex = 31
	footerTopLine.Parent = footer

	local footerGrad = Instance.new("UIGradient")
	footerGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, lerpColor(C.FooterBG, C.BG, 0.3)),
		ColorSequenceKeypoint.new(1, C.FooterBG),
	})
	footerGrad.Parent = footer

	local fpsLabel = Instance.new("TextLabel")
	noHit(fpsLabel)
	fpsLabel.BackgroundTransparency = 1
	fpsLabel.Position = UDim2.new(0, 14, 0, 0)
	fpsLabel.Size = UDim2.new(0, 100, 1, 0)
	fpsLabel.Font = Enum.Font.GothamBold
	fpsLabel.TextSize = FONT_FOOTER
	fpsLabel.Text = "FPS: --"
	fpsLabel.TextColor3 = C.Sub
	fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
	fpsLabel.ZIndex = 32
	fpsLabel.Parent = footer

	local pingLabel = Instance.new("TextLabel")
	noHit(pingLabel)
	pingLabel.BackgroundTransparency = 1
	pingLabel.Position = UDim2.new(0, 120, 0, 0)
	pingLabel.Size = UDim2.new(0, 110, 1, 0)
	pingLabel.Font = Enum.Font.GothamBold
	pingLabel.TextSize = FONT_FOOTER
	pingLabel.Text = "Ping: --ms"
	pingLabel.TextColor3 = C.Sub
	pingLabel.TextXAlignment = Enum.TextXAlignment.Left
	pingLabel.ZIndex = 32
	pingLabel.Parent = footer

	local timeLabel = Instance.new("TextLabel")
	noHit(timeLabel)
	timeLabel.AnchorPoint = Vector2.new(1, 0)
	timeLabel.BackgroundTransparency = 1
	timeLabel.Position = UDim2.new(1, -14, 0, 0)
	timeLabel.Size = UDim2.new(0, 120, 1, 0)
	timeLabel.Font = Enum.Font.GothamBold
	timeLabel.TextSize = FONT_FOOTER
	timeLabel.Text = "00:00:00"
	timeLabel.TextColor3 = C.Sub
	timeLabel.TextXAlignment = Enum.TextXAlignment.Right
	timeLabel.ZIndex = 32
	timeLabel.Parent = footer

	local versionFooter = Instance.new("TextLabel")
	noHit(versionFooter)
	versionFooter.AnchorPoint = Vector2.new(0.5, 0)
	versionFooter.BackgroundTransparency = 1
	versionFooter.Position = UDim2.new(0.5, 0, 0, 0)
	versionFooter.Size = UDim2.new(0, 200, 1, 0)
	versionFooter.Font = Enum.Font.GothamBold
	versionFooter.TextSize = FONT_FOOTER
	versionFooter.Text = title
	versionFooter.TextColor3 = C.Dim
	versionFooter.TextTransparency = 0.25
	versionFooter.ZIndex = 32
	versionFooter.Parent = footer

	local fpsCounter = 0
	local fpsAccum = 0
	local _pingAccum = 0
	local _timeAccum = 0
	poolAdd(function(dt)
		if not fpsLabel or not fpsLabel.Parent then return false end
		fpsAccum = fpsAccum + dt
		fpsCounter = fpsCounter + 1
		_pingAccum = _pingAccum + dt
		_timeAccum = _timeAccum + dt
		if fpsAccum >= 0.5 then
			local fps = math.floor(fpsCounter / fpsAccum)
			fpsLabel.Text = "FPS: " .. tostring(fps)
			fpsLabel.TextColor3 = fps >= 50 and C.Ok or fps >= 30 and C.Warn or C.Err
			fpsCounter = 0
			fpsAccum = 0
		end
		if _pingAccum >= 1 then
			_pingAccum = 0
			local pingValue = nil
			pcall(function()
				pingValue = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			end)
			if not pingValue then
				pcall(function()
					pingValue = math.floor(Player:GetNetworkPing() * 1000)
				end)
			end
			if pingValue then
				pingLabel.Text = "Ping: " .. tostring(pingValue) .. "ms"
				pingLabel.TextColor3 = pingValue <= 80 and C.Ok or pingValue <= 150 and C.Warn or C.Err
			else
				pingLabel.Text = "Ping: N/A"
				pingLabel.TextColor3 = C.Dim
			end
		end
		if _timeAccum >= 1 then
			_timeAccum = 0
			local now = os.date("*t")
			timeLabel.Text = string.format("%02d:%02d:%02d", now.hour, now.min, now.sec)
		end
		return true
	end)

	local ACTIVE_W = math.floor(180 * SC)
	local ACTIVE_HEADER_H = math.floor(30 * SC)
	local ACTIVE_ITEM_H = math.floor(24 * SC)
	local ACTIVE_MAX_VISIBLE = 10
	local activePanelMinimized = false

	local activeOverlay = Instance.new("Frame")
	noHit(activeOverlay)
	activeOverlay.AnchorPoint = Vector2.new(1, 0)
	activeOverlay.BackgroundColor3 = C.BG
	activeOverlay.BackgroundTransparency = 0.06
	activeOverlay.Position = UDim2.new(1, -10, 0, 54)
	activeOverlay.Size = UDim2.new(0, ACTIVE_W, 0, 0)
	activeOverlay.AutomaticSize = Enum.AutomaticSize.Y
	activeOverlay.ZIndex = 45
	activeOverlay.Visible = false
	activeOverlay.ClipsDescendants = true
	activeOverlay.Active = true
	activeOverlay.Draggable = true
	activeOverlay.Parent = screenGui
	corner(activeOverlay, 10)
	strokeInst(activeOverlay, C.Border, 1, 0.4)
	addClayShadow(activeOverlay, 10)

	local activeHeader = Instance.new("Frame")
	noHit(activeHeader)
	activeHeader.BackgroundTransparency = 1
	activeHeader.Size = UDim2.new(1, 0, 0, ACTIVE_HEADER_H)
	activeHeader.ZIndex = 47
	activeHeader.Parent = activeOverlay

	local activeStatusDot = Instance.new("Frame")
	noHit(activeStatusDot)
	activeStatusDot.AnchorPoint = Vector2.new(0, 0.5)
	activeStatusDot.BackgroundColor3 = C.Accent
	activeStatusDot.Position = UDim2.new(0, 10, 0.5, 0)
	activeStatusDot.Size = UDim2.new(0, math.floor(6 * SC), 0, math.floor(6 * SC))
	activeStatusDot.ZIndex = 48
	activeStatusDot.Parent = activeHeader
	corner(activeStatusDot, 99)

	local activeTitle = Instance.new("TextLabel")
	noHit(activeTitle)
	activeTitle.BackgroundTransparency = 1
	activeTitle.Position = UDim2.new(0, math.floor(22 * SC), 0, 0)
	activeTitle.Size = UDim2.new(0.7, 0, 1, 0)
	activeTitle.Font = Enum.Font.GothamBold
	activeTitle.TextSize = math.floor(11 * SC)
	activeTitle.Text = "Active"
	activeTitle.TextColor3 = C.Text
	activeTitle.TextTransparency = 0.1
	activeTitle.TextXAlignment = Enum.TextXAlignment.Left
	activeTitle.ZIndex = 47
	activeTitle.Parent = activeHeader

	local activeCountBadge = Instance.new("Frame")
	noHit(activeCountBadge)
	activeCountBadge.AnchorPoint = Vector2.new(1, 0.5)
	activeCountBadge.BackgroundColor3 = C.Accent
	activeCountBadge.BackgroundTransparency = 0.4
	activeCountBadge.Position = UDim2.new(1, -8, 0.5, 0)
	activeCountBadge.Size = UDim2.new(0, math.floor(22 * SC), 0, math.floor(16 * SC))
	activeCountBadge.ZIndex = 48
	activeCountBadge.Parent = activeHeader
	corner(activeCountBadge, 8)

	local activeCountLabel = Instance.new("TextLabel")
	noHit(activeCountLabel)
	activeCountLabel.BackgroundTransparency = 1
	activeCountLabel.Size = UDim2.new(1, 0, 1, 0)
	activeCountLabel.Font = Enum.Font.GothamBold
	activeCountLabel.TextSize = math.floor(10 * SC)
	activeCountLabel.Text = "0"
	activeCountLabel.TextColor3 = C.Text
	activeCountLabel.ZIndex = 49
	activeCountLabel.Parent = activeCountBadge
	strokeInst(activeCountBadge, C.Accent, 1, 0.35)

	-- Hairline under the header separates title/count from the feature list.
	local headerDivider = Instance.new("Frame")
	noHit(headerDivider)
	headerDivider.BackgroundColor3 = C.Border
	headerDivider.BackgroundTransparency = 0.35
	headerDivider.Position = UDim2.new(0, 10, 0, ACTIVE_HEADER_H - 1)
	headerDivider.Size = UDim2.new(1, -20, 0, 1)
	headerDivider.ZIndex = 47
	headerDivider.Parent = activeOverlay
	local hdGrad = Instance.new("UIGradient")
	hdGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0),
		NumberSequenceKeypoint.new(0.8, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	hdGrad.Parent = headerDivider

	local activeListFrame = Instance.new("ScrollingFrame")
	noHit(activeListFrame)
	activeListFrame.BackgroundTransparency = 1
	activeListFrame.Position = UDim2.new(0, 0, 0, ACTIVE_HEADER_H + 2)
	activeListFrame.Size = UDim2.new(1, 0, 0, 0)
	activeListFrame.AutomaticSize = Enum.AutomaticSize.Y
	activeListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	activeListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	activeListFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	activeListFrame.ScrollBarThickness = 2
	activeListFrame.ScrollBarImageColor3 = C.Border
	activeListFrame.ZIndex = 46
	activeListFrame.Parent = activeOverlay
	pad(activeListFrame, 2, 4, 4, 4)
	uiList(activeListFrame, 2, Enum.FillDirection.Vertical)

	local activeFeatureLabels = {}
	local prevActiveCount = 0

	local function updateActivePanel()
		for _, lbl in pairs(activeFeatureLabels) do
			if lbl and lbl.Parent then lbl:Destroy() end
		end
		activeFeatureLabels = {}
		local activeCount = 0
		local sortedNames = {}
		for name, val in pairs(W._activeFeatures) do
			if val and not W._activeHidden[name] then
				activeCount = activeCount + 1
				sortedNames[#sortedNames + 1] = name
			end
		end
		table.sort(sortedNames)

		activeCountLabel.Text = tostring(activeCount)
		if activeCount ~= prevActiveCount then
			springBounce(activeCountBadge, "Size",
				UDim2.new(0, math.floor(22 * SC), 0, math.floor(16 * SC)), 1.1)
			prevActiveCount = activeCount
		end

		activeCountBadge.BackgroundColor3 = C.Accent
		activeStatusDot.BackgroundColor3 = C.Accent

		local maxH = ACTIVE_ITEM_H * math.min(#sortedNames, ACTIVE_MAX_VISIBLE) + 12
		activeListFrame.Size = UDim2.new(1, 0, 0, maxH)

		for i, name in ipairs(sortedNames) do
			local item = Instance.new("Frame")
			noHit(item)
			item.BackgroundColor3 = C.ActiveItemBG
			item.BackgroundTransparency = 1
			item.Size = UDim2.new(1, -6, 0, ACTIVE_ITEM_H)
			item.LayoutOrder = i
			item.ZIndex = 47
			item.Parent = activeListFrame
			corner(item, 6)

			-- Slim accent edge reads cleaner than a floating dot and gives each row a spine.
			local edge = Instance.new("Frame")
			noHit(edge)
			edge.AnchorPoint = Vector2.new(0, 0.5)
			edge.BackgroundColor3 = C.Accent
			edge.BackgroundTransparency = 1
			edge.Position = UDim2.new(0, 5, 0.5, 0)
			edge.Size = UDim2.new(0, math.floor(2 * SC), 0, math.floor(ACTIVE_ITEM_H * 0.5))
			edge.ZIndex = 49
			edge.Parent = item
			corner(edge, 2)

			local nameLabel = Instance.new("TextLabel")
			noHit(nameLabel)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Position = UDim2.new(0, math.floor(14 * SC), 0, 0)
			nameLabel.Size = UDim2.new(1, -math.floor(18 * SC), 1, 0)
			nameLabel.Font = Enum.Font.GothamMedium
			nameLabel.TextSize = math.floor(11 * SC)
			nameLabel.Text = name
			nameLabel.TextColor3 = C.Text
			nameLabel.TextTransparency = 1
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
			nameLabel.ZIndex = 49
			nameLabel.Parent = item

			-- Quick, subtly staggered fade-in so the list feels alive on change.
			local delayT = math.min((i - 1) * 0.02, 0.22)
			task.delay(delayT, function()
				if not item.Parent then return end
				tw(item, 0.2, {BackgroundTransparency = 0.45}, Enum.EasingStyle.Quint)
				tw(edge, 0.2, {BackgroundTransparency = 0.1}, Enum.EasingStyle.Quint)
				tw(nameLabel, 0.2, {TextTransparency = 0.12}, Enum.EasingStyle.Quint)
			end)

			activeFeatureLabels[#activeFeatureLabels + 1] = item
		end
		activeOverlay.Visible = activeCount > 0 and W._activePanelEnabled ~= false
	end

	W._activePanelEnabled = true

	function W:SetActivePanelVisible(visible)
		W._activePanelEnabled = visible
		if not visible then
			activeOverlay.Visible = false
		else
			updateActivePanel()
		end
	end

	function W:ToggleActivePanel()
		W:SetActivePanelVisible(not W._activePanelEnabled)
	end

	function W:IsActivePanelVisible()
		return W._activePanelEnabled
	end

	-- Hide/show a single feature in the Active Features panel by its display name
	-- (the toggle's Name, or Flag if it has no Name). The feature keeps working and
	-- keeps counting; it's only removed from the panel list. Equivalent to setting
	-- HideFromActive on the toggle, but toggleable at runtime.
	function W:SetFeatureHiddenFromActive(name, hidden)
		if not name then return end
		W._activeHidden[name] = hidden and true or nil
		if updateActivePanel then updateActivePanel() end
	end

	function W:IsFeatureHiddenFromActive(name)
		return W._activeHidden[name] == true
	end

	W._updateLog = {}
	function W:LogUpdate(msg)
		W._updateLog[#W._updateLog + 1] = {time = os.date("%H:%M:%S"), msg = msg}
		while #W._updateLog > 50 do table.remove(W._updateLog, 1) end
	end
	function W:GetUpdateLog()
		return W._updateLog
	end
	function W:ClearUpdateLog()
		W._updateLog = {}
	end

	local notifContainer = Instance.new("Frame")
	noHit(notifContainer)
	notifContainer.AnchorPoint = Vector2.new(1, 1)
	notifContainer.BackgroundTransparency = 1
	notifContainer.Position = UDim2.new(1, -18, 1, -18)
	notifContainer.Size = UDim2.new(0, 310, 0, 460)
	notifContainer.ZIndex = 70
	notifContainer.Parent = screenGui
	uiList(notifContainer, 8, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)

	function W:Notify(opts)
		opts = opts or {}
		local color = ({Success = C.Ok, Warning = C.Warn, Error = C.Err, Info = C.Info})[opts.Type or "Info"] or C.Accent
		local duration = opts.Duration or 3.5
		playSound(Sounds.notif, 0.12, 1.1)

		local toast = Instance.new("Frame")
		toast.BackgroundColor3 = C.NotifBG
		toast.BackgroundTransparency = 0.01
		toast.Size = UDim2.new(0, 300, 0, 0)
		toast.ClipsDescendants = true
		toast.ZIndex = 72
		toast.Parent = notifContainer
		corner(toast, 16)
		addClayShadow(toast, 16)

		local accentBar = Instance.new("Frame")
		noHit(accentBar)
		accentBar.BackgroundColor3 = color
		accentBar.BackgroundTransparency = 0.3
		accentBar.Position = UDim2.new(0, 16, 0, 0)
		accentBar.Size = UDim2.new(1, -32, 0, 2)
		accentBar.ZIndex = 74
		accentBar.Parent = toast
		corner(accentBar, 1)
		local notifAccGrad = Instance.new("UIGradient")
		notifAccGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.15, 0),
			NumberSequenceKeypoint.new(0.85, 0),
			NumberSequenceKeypoint.new(1, 1),
		})
		notifAccGrad.Parent = accentBar

		local iconFrame = Instance.new("Frame")
		noHit(iconFrame)
		iconFrame.AnchorPoint = Vector2.new(0, 0.5)
		iconFrame.BackgroundColor3 = color
		iconFrame.BackgroundTransparency = 0.78
		iconFrame.Position = UDim2.new(0, 16, 0, 28)
		iconFrame.Size = UDim2.new(0, 30, 0, 30)
		iconFrame.ZIndex = 74
		iconFrame.Parent = toast
		corner(iconFrame, 15)

		local iconText = Instance.new("TextLabel")
		noHit(iconText)
		iconText.BackgroundTransparency = 1
		iconText.Size = UDim2.new(1, 0, 1, 0)
		iconText.Font = Enum.Font.GothamBold
		iconText.TextSize = 14
		local notifIconNames = {Success = "check_circle", Error = "cancel", Warning = "warning", Info = "info"}
		local notifIconAsset = getIconAsset(notifIconNames[opts.Type or "Info"])
		if notifIconAsset then
			iconText.Visible = false
			local notifImg = Instance.new("ImageLabel")
			noHit(notifImg)
			notifImg.BackgroundTransparency = 1
			notifImg.AnchorPoint = Vector2.new(0.5, 0.5)
			notifImg.Position = UDim2.new(0.5, 0, 0.5, 0)
			notifImg.Size = UDim2.new(0, 18, 0, 18)
			notifImg.Image = notifIconAsset
			notifImg.ImageColor3 = color
			notifImg.ScaleType = Enum.ScaleType.Fit
			notifImg.ZIndex = 75
			notifImg.Parent = iconFrame
		else
			local notifIconNames = {Success = "check_circle", Error = "cancel", Warning = "warning", Info = "info"}
			local notifIconAsset = getIconAsset(notifIconNames[opts.Type or "Info"])
			if notifIconAsset then
				iconText.Text = ""
				local nImg = Instance.new("ImageLabel")
				noHit(nImg)
				nImg.BackgroundTransparency = 1
				nImg.AnchorPoint = Vector2.new(0.5, 0.5)
				nImg.Position = UDim2.new(0.5, 0, 0.5, 0)
				nImg.Size = UDim2.new(0, math.floor(16 * SC), 0, math.floor(16 * SC))
				nImg.Image = notifIconAsset
				nImg.ImageColor3 = typeColor
				nImg.ScaleType = Enum.ScaleType.Fit
				nImg.ZIndex = iconText.ZIndex + 1
				nImg.Parent = iconText
			else
				iconText.Text = opts.Type == "Success" and "OK" or opts.Type == "Error" and "X" or opts.Type == "Warning" and "!" or "i"
			end
		end
		iconText.TextColor3 = color
		iconText.ZIndex = 75
		iconText.Parent = iconFrame

		local titleLabel = Instance.new("TextLabel")
		noHit(titleLabel)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Position = UDim2.new(0, 54, 0, 8)
		titleLabel.Size = UDim2.new(1, -64, 0, 18)
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextSize = 14
		titleLabel.Text = opts.Title or ""
		titleLabel.TextColor3 = C.Text
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
		titleLabel.ZIndex = 74
		titleLabel.Parent = toast

		local contentLabel = Instance.new("TextLabel")
		noHit(contentLabel)
		contentLabel.BackgroundTransparency = 1
		contentLabel.Position = UDim2.new(0, 54, 0, 28)
		contentLabel.Size = UDim2.new(1, -64, 0, 16)
		contentLabel.Font = Enum.Font.GothamMedium
		contentLabel.TextSize = 11
		contentLabel.Text = opts.Content or ""
		contentLabel.TextColor3 = C.Sub
		contentLabel.TextXAlignment = Enum.TextXAlignment.Left
		contentLabel.TextTruncate = Enum.TextTruncate.AtEnd
		contentLabel.ZIndex = 74
		contentLabel.Parent = toast

		local progressBG = Instance.new("Frame")
		noHit(progressBG)
		progressBG.BackgroundColor3 = color
		progressBG.BackgroundTransparency = 0.78
		progressBG.AnchorPoint = Vector2.new(0, 1)
		progressBG.Position = UDim2.new(0, 10, 1, -6)
		progressBG.Size = UDim2.new(1, -20, 0, 3)
		progressBG.ZIndex = 74
		progressBG.Parent = toast
		corner(progressBG, 2)

		local progressFill = Instance.new("Frame")
		noHit(progressFill)
		progressFill.BackgroundColor3 = color
		progressFill.Size = UDim2.new(1, 0, 1, 0)
		progressFill.ZIndex = 75
		progressFill.Parent = progressBG
		corner(progressFill, 2)

		tw(toast, 0.45, {Size = UDim2.new(0, 300, 0, 58)}, Enum.EasingStyle.Back)
		tw(progressFill, duration, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear)

		task.delay(duration + 0.5, function()
			if toast and toast.Parent then
				tw(toast, 0.3, {Size = UDim2.new(0, 300, 0, 0), BackgroundTransparency = 1})
				task.delay(0.35, function()
					if toast and toast.Parent then toast:Destroy() end
				end)
			end
		end)
	end

	local cmdOverlay = Instance.new("TextButton")
	cmdOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
	cmdOverlay.BackgroundTransparency = 0.35
	cmdOverlay.Size = UDim2.new(1, 0, 1, 0)
	cmdOverlay.Text = ""
	cmdOverlay.ZIndex = 79
	cmdOverlay.Visible = false
	cmdOverlay.AutoButtonColor = false
	cmdOverlay.Parent = screenGui

	local cmdFrame = Instance.new("Frame")
	cmdFrame.AnchorPoint = Vector2.new(0.5, 0)
	cmdFrame.BackgroundColor3 = C.Surface
	cmdFrame.Position = UDim2.new(0.5, 0, 0.1, 0)
	cmdFrame.Size = UDim2.new(0, 500, 0, 56)
	cmdFrame.ZIndex = 80
	cmdFrame.Visible = false
	cmdFrame.ClipsDescendants = true
	cmdFrame.Parent = screenGui
	corner(cmdFrame, 20)
	strokeInst(cmdFrame, C.BorderLit, 1, 0.3)
	addClayShadow(cmdFrame, 20)

	local cmdBox = Instance.new("TextBox")
	cmdBox.BackgroundTransparency = 1
	cmdBox.Position = UDim2.new(0, 20, 0, 0)
	cmdBox.Size = UDim2.new(1, -40, 0, 52)
	cmdBox.Font = Enum.Font.GothamMedium
	cmdBox.TextSize = 16
	cmdBox.Text = ""
	cmdBox.PlaceholderText = "Search features..."
	cmdBox.PlaceholderColor3 = C.Dim
	cmdBox.TextColor3 = C.Text
	cmdBox.TextXAlignment = Enum.TextXAlignment.Left
	cmdBox.ClearTextOnFocus = true
	cmdBox.ZIndex = 82
	cmdBox.Parent = cmdFrame

	local cmdResults = Instance.new("ScrollingFrame")
	cmdResults.BackgroundTransparency = 1
	cmdResults.Position = UDim2.new(0, 0, 0, 54)
	cmdResults.Size = UDim2.new(1, 0, 1, -54)
	cmdResults.CanvasSize = UDim2.new(0, 0, 0, 0)
	cmdResults.ScrollBarThickness = 2
	cmdResults.ScrollBarImageColor3 = C.Accent
	cmdResults.ZIndex = 81
	cmdResults.Parent = cmdFrame
	pad(cmdResults, 6, 12, 12, 12)
	local cmdLayout = uiList(cmdResults, 5)

	local cmdOpen = false
	local closeCmd

	local function openCmd()
		if cmdOpen then return end
		cmdOpen = true
		cmdOverlay.Visible = true
		cmdFrame.Visible = true
		cmdFrame.Size = UDim2.new(0, 500, 0, 56)
		playSound(Sounds.expand, 0.1, 1.1)

		for _, ch in pairs(cmdResults:GetChildren()) do
			if ch:IsA("TextButton") then ch:Destroy() end
		end

		local totalElems = 0
		for _, elem in ipairs(W._elems) do
			totalElems = totalElems + 1
			local rb = Instance.new("TextButton")
			rb.BackgroundColor3 = C.SurfaceAlt
			rb.BackgroundTransparency = 0.2
			rb.Size = UDim2.new(1, 0, 0, 34)
			rb.Text = ""
			rb.AutoButtonColor = false
			rb.ZIndex = 83
			rb.Parent = cmdResults
			corner(rb, 12)

			local iconL = Instance.new("TextLabel")
			noHit(iconL)
			iconL.BackgroundTransparency = 1
			iconL.Position = UDim2.new(0, 8, 0, 0)
			iconL.Size = UDim2.new(0, 22, 1, 0)
			iconL.Font = Enum.Font.GothamBold
			iconL.TextSize = 14
			iconL.Text = elem.Type == "Toggle" and "T" or elem.Type == "Slider" and "S" or elem.Type == "Dropdown" and "D" or elem.Type == "Button" and "B" or elem.Type == "Input" and "I" or elem.Type == "Keybind" and "K" or "?"
			iconL.TextColor3 = C.Dim
			iconL.ZIndex = 84
			iconL.Parent = rb

			local nl = Instance.new("TextLabel")
			noHit(nl)
			nl.Name = "ElemName"
			nl.BackgroundTransparency = 1
			nl.Position = UDim2.new(0, 34, 0, 0)
			nl.Size = UDim2.new(0.5, -34, 1, 0)
			nl.Font = Enum.Font.GothamBold
			nl.TextSize = 13
			nl.Text = elem.Name
			nl.TextColor3 = C.Text
			nl.TextXAlignment = Enum.TextXAlignment.Left
			nl.ZIndex = 84
			nl.Parent = rb

			local ml = Instance.new("TextLabel")
			noHit(ml)
			ml.BackgroundTransparency = 1
			ml.Position = UDim2.new(0.5, 0, 0, 0)
			ml.Size = UDim2.new(0.5, -16, 1, 0)
			ml.Font = Enum.Font.GothamMedium
			ml.TextSize = 10
			ml.Text = elem.Tab .. " / " .. (elem.SubTab or elem.Group or "") .. " / " .. elem.Type
			ml.TextColor3 = C.Dim
			ml.TextXAlignment = Enum.TextXAlignment.Right
			ml.ZIndex = 84
			ml.Parent = rb

			rb.MouseEnter:Connect(function()
				tw(rb, 0.12, {BackgroundTransparency = 0.02})
				playSound(Sounds.hover, 0.03, 1.4)
			end)
			rb.MouseLeave:Connect(function()
				tw(rb, 0.12, {BackgroundTransparency = 0.2})
			end)
			rb.MouseButton1Click:Connect(function()
				playSound(Sounds.sel, 0.1, 1.0)
				for _, tab in pairs(W.Tabs) do
					if tab.Name == elem.Tab and tab._select then
						tab._select()
						if elem.SubTab then
							task.delay(0.1, function()
								for _, st in pairs(tab.SubTabs or {}) do
									if st.Name == elem.SubTab and st._select then
										st._select()
										break
									end
								end
							end)
						end
						if elem._card and elem._card.Parent then
							task.delay(0.2, function()
								tw(elem._card, 0.15, {BackgroundColor3 = C.Accent})
								task.delay(0.5, function()
									if elem._card and elem._card.Parent then
										tw(elem._card, 0.4, {BackgroundColor3 = C.SurfaceAlt})
									end
								end)
							end)
						end
						break
					end
				end
				closeCmd()
			end)
		end

		local targetH = math.min(400, 56 + totalElems * 38 + 20)
		tw(cmdFrame, 0.35, {Size = UDim2.new(0, 500, 0, targetH)}, Enum.EasingStyle.Back)
		cmdBox:CaptureFocus()
		cmdBox.Text = ""
	end

	closeCmd = function()
		if not cmdOpen then return end
		cmdOpen = false
		playSound(Sounds.collapse, 0.08, 1.2)
		tw(cmdFrame, 0.22, {Size = UDim2.new(0, 500, 0, 56)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.28, function()
			cmdFrame.Visible = false
			cmdOverlay.Visible = false
		end)
	end

	cmdOverlay.MouseButton1Click:Connect(closeCmd)

	cmdBox:GetPropertyChangedSignal("Text"):Connect(function()
		local query = cmdBox.Text:lower()
		for _, ch in pairs(cmdResults:GetChildren()) do
			if ch:IsA("TextButton") then
				local nl = ch:FindFirstChild("ElemName")
				if nl then
					ch.Visible = (query == "" or nl.Text:lower():find(query, 1, true) ~= nil)
				end
			end
		end
		local visCount = 0
		for _, ch in pairs(cmdResults:GetChildren()) do
			if ch:IsA("TextButton") and ch.Visible then visCount = visCount + 1 end
		end
		local targetH = math.min(400, 56 + visCount * 38 + 20)
		tw(cmdFrame, 0.2, {Size = UDim2.new(0, 500, 0, targetH)}, Enum.EasingStyle.Quint)
	end)

	searchBox.Focused:Connect(function()
		searchBox:ReleaseFocus()
		openCmd()
	end)

	trackConn(UserInputService.InputBegan:Connect(function(input, gpe)
		if input.KeyCode == Enum.KeyCode.K and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			if cmdOpen then closeCmd() else openCmd() end
		end
		if input.KeyCode == Enum.KeyCode.Escape and cmdOpen then
			closeCmd()
		end
	end))

	function W:CreateTab(tc)
		tc = tc or {}
		local Tab = {
			Name = tc.Name or "Tab",
			Icon = tc.Icon or "circle",
			Groups = {},
			SubTabs = {},
			ActiveSubTab = nil,
			_select = nil,
		}
		local accent = tc.Accent or C.Accent
		local tabIndex = #W.Tabs + 1
		W.Tabs[tabIndex] = Tab

		local sBtn = Instance.new("TextButton")
		sBtn.BackgroundColor3 = C.SidebarActive
		sBtn.BackgroundTransparency = 1
		sBtn.Size = UDim2.new(1, -12, 0, math.floor(44 * SC))
		sBtn.Text = ""
		sBtn.AutoButtonColor = false
		sBtn.LayoutOrder = tabIndex
		sBtn.ZIndex = 27
		sBtn.Parent = sideScroll
		corner(sBtn, 12)

		local sIcon
		local sIconIsImage = false
		local sIconAsset = getIconAsset(tc.Icon)
		if sIconAsset then
			sIconIsImage = true
			sIcon = Instance.new("ImageLabel")
			noHit(sIcon)
			sIcon.BackgroundTransparency = 1
			sIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			sIcon.Position = UDim2.new(0, math.floor(SIDEBAR_W / 2) - 3, 0.5, 0)
			sIcon.Size = UDim2.new(0, math.floor(20 * SC), 0, math.floor(20 * SC))
			sIcon.Image = sIconAsset
			sIcon.ImageColor3 = C.Dim
			sIcon.ScaleType = Enum.ScaleType.Fit
			sIcon.ZIndex = 28
		else
			sIcon = Instance.new("TextLabel")
			noHit(sIcon)
			sIcon.BackgroundTransparency = 1
			sIcon.Position = UDim2.new(0, 0, 0, 0)
			sIcon.Size = UDim2.new(0, math.floor(SIDEBAR_W - 12), 1, 0)
			sIcon.Font = Enum.Font.GothamBold
			sIcon.TextSize = FONT_ICON_SIDEBAR
			sIcon.Text = getIcon(tc.Icon)
			sIcon.TextColor3 = C.Dim
			sIcon.ZIndex = 28
		end
		sIcon.Parent = sBtn

		local sLabel = Instance.new("TextLabel")
		noHit(sLabel)
		sLabel.BackgroundTransparency = 1
		sLabel.Position = UDim2.new(0, math.floor(SIDEBAR_W - 12), 0, 0)
		sLabel.Size = UDim2.new(1, -math.floor(SIDEBAR_W - 12), 1, 0)
		sLabel.Font = Enum.Font.GothamBold
		sLabel.TextSize = FONT_SIDEBAR_LABEL
		sLabel.Text = tc.Name or "Tab"
		sLabel.TextColor3 = C.Sub
		sLabel.TextXAlignment = Enum.TextXAlignment.Left
		sLabel.TextTransparency = 1
		sLabel.Visible = false
		sLabel.ZIndex = 28
		sLabel.Parent = sBtn
		_allSideLabels[#_allSideLabels + 1] = {label = sLabel}

		local indicator = Instance.new("Frame")
		noHit(indicator)
		indicator.AnchorPoint = Vector2.new(0, 0.5)
		indicator.BackgroundColor3 = accent
		indicator.BackgroundTransparency = 1
		indicator.Position = UDim2.new(0, 2, 0.5, 0)
		indicator.Size = UDim2.new(0, 3, 0, 0)
		indicator.ZIndex = 29
		indicator.Parent = sBtn
		corner(indicator, 2)

		sBtn.MouseEnter:Connect(function()
			if W.ActiveTab ~= Tab then
				tw(sBtn, 0.14, {BackgroundTransparency = 0.75})
				tweenIconColor(sIcon, 0.14, C.Sub)
			end
			playSound(Sounds.hover, 0.04, 1.35)
		end)
		sBtn.MouseLeave:Connect(function()
			if W.ActiveTab ~= Tab then
				tw(sBtn, 0.14, {BackgroundTransparency = 1})
				tweenIconColor(sIcon, 0.14, C.Dim)
			end
		end)

		local tabFrame = Instance.new("Frame")
		tabFrame.Name = "TabFrame_" .. (tc.Name or "")
		tabFrame.BackgroundTransparency = 1
		tabFrame.Size = UDim2.new(1, 0, 1, 0)
		tabFrame.Visible = false
		tabFrame.ZIndex = 6
		tabFrame.Parent = content

		local subTabBar = Instance.new("Frame")
		noHit(subTabBar)
		subTabBar.BackgroundColor3 = C.SubTabBG
		subTabBar.BackgroundTransparency = 0.2
		subTabBar.Size = UDim2.new(1, 0, 0, SUBTAB_H)
		subTabBar.ZIndex = 15
		subTabBar.BorderSizePixel = 0
		subTabBar.Parent = tabFrame

		local subTabBotLine = Instance.new("Frame")
		noHit(subTabBotLine)
		subTabBotLine.BackgroundColor3 = C.Border
		subTabBotLine.BackgroundTransparency = 0.5
		subTabBotLine.Position = UDim2.new(0, 0, 1, -1)
		subTabBotLine.Size = UDim2.new(1, 0, 0, 1)
		subTabBotLine.ZIndex = 16
		subTabBotLine.Parent = subTabBar

		local subTabScroll = Instance.new("ScrollingFrame")
		subTabScroll.BackgroundTransparency = 1
		subTabScroll.Size = UDim2.new(1, -24, 1, 0)
		subTabScroll.Position = UDim2.new(0, 12, 0, 0)
		subTabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		subTabScroll.ScrollBarThickness = 0
		subTabScroll.ZIndex = 16
		subTabScroll.Parent = subTabBar
		local subTabLayout = uiList(subTabScroll, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
		subTabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			-- divide by UIScale: AbsoluteContentSize is scaled px, CanvasSize is local space
			subTabScroll.CanvasSize = UDim2.new(0, subTabLayout.AbsoluteContentSize.X / math.max(uiScaleObj.Scale, 0.01) + 24, 0, 0)
		end)

		local contentScroll = Instance.new("ScrollingFrame")
		contentScroll.BackgroundTransparency = 1
		contentScroll.Position = UDim2.new(0, 0, 0, SUBTAB_H)
		contentScroll.Size = UDim2.new(1, 0, 1, -SUBTAB_H)
		contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		contentScroll.ScrollingDirection = Enum.ScrollingDirection.Y
		contentScroll.ScrollBarThickness = 3
		contentScroll.ScrollBarImageColor3 = C.Border
		contentScroll.ZIndex = 7
		contentScroll.Parent = tabFrame
		pad(contentScroll, 14, 50, 14, 14)

		local contentLayout = uiList(contentScroll, 14)

		local function selectTab()
			if W.ActiveTab == Tab then return end
			for _, t in pairs(W.Tabs) do
				if t ~= Tab and t._frame then t._frame.Visible = false end
				if t._sideBtn then
					tw(t._sideBtn, 0.15, {BackgroundTransparency = 1})
					tweenIconColor(t._sideIcon, 0.15, C.Dim)
					if t._indicator then
						tw(t._indicator, 0.18, {BackgroundTransparency = 1, Size = UDim2.new(0, 3, 0, 0)})
					end
				end
			end
			W.ActiveTab = Tab
			tabFrame.Visible = true
			tw(sBtn, 0.2, {BackgroundTransparency = 0.5})
			tweenIconColor(sIcon, 0.2, accent)
			springBounce(indicator, "Size", UDim2.new(0, 3, 0, 22), 6)
			tw(indicator, 0.28, {BackgroundTransparency = 0.15})
			playSound(Sounds.sel, 0.1, 1.0)
			staggerIn(contentScroll)
		end

		Tab._frame = tabFrame
		Tab._sideBtn = sBtn
		Tab._sideIcon = sIcon
		Tab._indicator = indicator
		Tab._select = selectTab
		Tab._contentScroll = contentScroll
		Tab._subTabScroll = subTabScroll
		Tab._accent = accent
		sBtn.MouseButton1Click:Connect(selectTab)
		if tabIndex == 1 then task.defer(selectTab) end

		function Tab:CreateSubTab(stc)
			stc = stc or {}
			local ST = {
				Name = stc.Name or "SubTab",
				_select = nil,
				_contentFrame = nil,
			}
			local stIndex = #Tab.SubTabs + 1
			Tab.SubTabs[stIndex] = ST

			local stBtn = Instance.new("TextButton")
			stBtn.BackgroundColor3 = C.SubTabActive
			stBtn.BackgroundTransparency = 1
			stBtn.Size = UDim2.new(0, 0, 0, math.floor(28 * SC))
			stBtn.AutomaticSize = Enum.AutomaticSize.X
			stBtn.Text = ""
			stBtn.AutoButtonColor = false
			stBtn.LayoutOrder = stIndex
			stBtn.ZIndex = 17
			stBtn.Parent = subTabScroll
			corner(stBtn, 10)
			pad(stBtn, 0, 0, 14, 14)

			local stLabel = Instance.new("TextLabel")
			noHit(stLabel)
			stLabel.BackgroundTransparency = 1
			stLabel.Size = UDim2.new(0, 0, 1, 0)
			stLabel.AutomaticSize = Enum.AutomaticSize.X
			stLabel.Font = Enum.Font.GothamBold
			stLabel.TextSize = FONT_SUBTAB
			stLabel.Text = stc.Name or "SubTab"
			stLabel.TextColor3 = C.Dim
			stLabel.ZIndex = 18
			stLabel.Parent = stBtn

			local stIndicator = Instance.new("Frame")
			noHit(stIndicator)
			stIndicator.AnchorPoint = Vector2.new(0.5, 1)
			stIndicator.BackgroundColor3 = accent
			stIndicator.BackgroundTransparency = 1
			stIndicator.Position = UDim2.new(0.5, 0, 1, 0)
			stIndicator.Size = UDim2.new(0.6, 0, 0, 2)
			stIndicator.ZIndex = 18
			stIndicator.Parent = stBtn
			corner(stIndicator, 1)

			local stContent = Instance.new("Frame")
			noHit(stContent)
			stContent.BackgroundTransparency = 1
			stContent.Size = UDim2.new(1, 0, 0, 0)
			stContent.AutomaticSize = Enum.AutomaticSize.Y
			stContent.LayoutOrder = stIndex
			stContent.Visible = false
			stContent.ZIndex = 7
			stContent.Parent = contentScroll

			local stContentLayout = uiList(stContent, 14)
			ST._contentFrame = stContent

			local function selectSubTab()
				if Tab.ActiveSubTab == ST then return end
				for _, ost in pairs(Tab.SubTabs) do
					if ost ~= ST and ost._contentFrame then
						ost._contentFrame.Visible = false
					end
					if ost._btn then
						tw(ost._btn, 0.15, {BackgroundTransparency = 1})
						if ost._label then tw(ost._label, 0.15, {TextColor3 = C.Dim}) end
						if ost._indicator then tw(ost._indicator, 0.15, {BackgroundTransparency = 1}) end
					end
				end
				Tab.ActiveSubTab = ST
				stContent.Visible = true
				tw(stBtn, 0.2, {BackgroundTransparency = 0.5})
				tw(stLabel, 0.2, {TextColor3 = C.Text})
				tw(stIndicator, 0.2, {BackgroundTransparency = 0.15})
				playSound(Sounds.sel, 0.06, 1.15)
				staggerIn(stContent)
			end

			ST._select = selectSubTab
			ST._btn = stBtn
			ST._label = stLabel
			ST._indicator = stIndicator

			stBtn.MouseEnter:Connect(function()
				if Tab.ActiveSubTab ~= ST then
					tw(stBtn, 0.12, {BackgroundTransparency = 0.7})
					tw(stLabel, 0.12, {TextColor3 = C.Sub})
				end
				playSound(Sounds.hover, 0.03, 1.4)
			end)
			stBtn.MouseLeave:Connect(function()
				if Tab.ActiveSubTab ~= ST then
					tw(stBtn, 0.12, {BackgroundTransparency = 1})
					tw(stLabel, 0.12, {TextColor3 = C.Dim})
				end
			end)
			stBtn.MouseButton1Click:Connect(selectSubTab)

			if stIndex == 1 then task.defer(selectSubTab) end

			function ST:CreateGroup(gc)
				gc = gc or {}
				return Tab:_createGroupInternal(gc, stContent, ST.Name)
			end

			return ST
		end

		function Tab:_createGroupInternal(gc, parentScroll, subTabName)
			gc = gc or {}
			local groupOrder = #Tab.Groups + 1
			Tab.Groups[groupOrder] = gc
			local G = {}
			local useBento = gc.BentoGrid == true

			local groupFrame = Instance.new("Frame")
			groupFrame.Name = gc.Name or "Group"
			groupFrame.BackgroundColor3 = C.Surface
			groupFrame.BackgroundTransparency = 0.15
			groupFrame.Size = UDim2.new(1, 0, 0, 0)
			groupFrame.AutomaticSize = Enum.AutomaticSize.Y
			groupFrame.LayoutOrder = groupOrder
			groupFrame.ClipsDescendants = true
			groupFrame.ZIndex = 8
			groupFrame.Parent = parentScroll
			corner(groupFrame, 18)
			addClayShadow(groupFrame, 18)
			addClayHighlight(groupFrame)
			strokeInst(groupFrame, C.Border, 1, 0.55)

			local header = Instance.new("Frame")
			noHit(header)
			header.BackgroundTransparency = 1
			header.Size = UDim2.new(1, 0, 0, math.floor(38 * SC))
			header.ClipsDescendants = true
			header.ZIndex = 10
			header.Parent = groupFrame
			corner(header, 18)

			local hasIcon = gc.Icon ~= nil and gc.Icon ~= ""
			local labelX = hasIcon and 44 or 16

			if hasIcon then
				local hIconAsset = getIconAsset(gc.Icon)
				if hIconAsset then
					local hImgIcon = Instance.new("ImageLabel")
					noHit(hImgIcon)
					hImgIcon.BackgroundTransparency = 1
					hImgIcon.Position = UDim2.new(0, 16, 0.5, 0)
					hImgIcon.AnchorPoint = Vector2.new(0, 0.5)
					hImgIcon.Size = UDim2.new(0, math.floor(16 * SC), 0, math.floor(16 * SC))
					hImgIcon.Image = hIconAsset
					hImgIcon.ImageColor3 = accent
					hImgIcon.ScaleType = Enum.ScaleType.Fit
					hImgIcon.ZIndex = 11
					hImgIcon.Parent = header
				else
					local hIcon = Instance.new("TextLabel")
					noHit(hIcon)
					hIcon.BackgroundTransparency = 1
					hIcon.Position = UDim2.new(0, 16, 0, 0)
					hIcon.Size = UDim2.new(0, 24, 1, 0)
					hIcon.Font = Enum.Font.GothamBold
					hIcon.TextSize = FONT_SECTION_ICON
					hIcon.Text = getIcon(gc.Icon)
					hIcon.TextColor3 = accent
					hIcon.ZIndex = 11
					hIcon.Parent = header
				end
			end

			local hLabel = Instance.new("TextLabel")
			noHit(hLabel)
			hLabel.BackgroundTransparency = 1
			hLabel.Position = UDim2.new(0, labelX, 0, 0)
			hLabel.Size = UDim2.new(1, -(labelX + 16), 1, 0)
			hLabel.Font = Enum.Font.GothamBold
			hLabel.TextSize = FONT_SECTION
			hLabel.Text = gc.Name or "Group"
			hLabel.TextColor3 = C.Text
			hLabel.TextXAlignment = Enum.TextXAlignment.Left
			hLabel.ZIndex = 11
			hLabel.Parent = header
			addShimmer(header, accent)

			local gContent = Instance.new("Frame")
			noHit(gContent)
			gContent.BackgroundTransparency = 1
			gContent.Position = UDim2.new(0, 0, 0, math.floor(38 * SC))
			gContent.Size = UDim2.new(1, 0, 0, 0)
			gContent.AutomaticSize = Enum.AutomaticSize.Y
			gContent.ZIndex = 8
			gContent.Parent = groupFrame

			if useBento then
				uiGrid(gContent, gc.GridCellWidth or math.floor(230 * SC), gc.GridCellHeight or math.floor(52 * SC), 8)
				pad(gContent, 4, 14, 14, 14)
			else
				uiList(gContent, 6)
				pad(gContent, 4, 14, 14, 14)
			end

			local elemOrder = 0
			local function gNext()
				elemOrder = elemOrder + 1
				return elemOrder
			end

			local function createCard(height, opts)
				opts = opts or {}
				local card = Instance.new("TextButton")
				card.BackgroundColor3 = C.SurfaceAlt
				card.BackgroundTransparency = 0.12
				card.Size = UDim2.new(1, 0, 0, height or math.floor(44 * SC))
				card.LayoutOrder = gNext()
				card.ClipsDescendants = true
				card.Active = true
				card.Text = ""
				card.AutoButtonColor = false
				card.ZIndex = 9
				card.Parent = gContent
				corner(card, 14)
				if not opts.noShadow then
					addClayShadow(card, 14)
				end
				strokeInst(card, C.Border, 1, 0.6)
				addHoverLift(card, 2)
				return card
			end

			-- Clay-style shadow with a FIXED height (width still hugs the card). Used for
			-- text cards whose height grows via AutomaticSize: the shadow stays the same
			-- compact size as a normal ~44px card instead of stretching with the text.
			-- Center-anchored so it stays put; scale-sized on X so it never inflates the
			-- card's AutomaticSize.
			local function addFixedShadow(card)
				local h1 = math.floor(56 * SC)
				local h2 = math.floor(72 * SC)

				local shadow = Instance.new("ImageLabel")
				noHit(shadow)
				shadow.AnchorPoint = Vector2.new(0.5, 0.5)
				shadow.BackgroundTransparency = 1
				shadow.Position = UDim2.new(0.5, 3, 0.5, 3)
				shadow.Size = UDim2.new(1, 12, 0, h1)
				shadow.ZIndex = card.ZIndex - 1
				shadow.Image = "rbxassetid://6014261993"
				shadow.ImageColor3 = C.ClayShadow
				shadow.ImageTransparency = 0.35
				shadow.ScaleType = Enum.ScaleType.Slice
				shadow.SliceCenter = Rect.new(49, 49, 450, 450)
				shadow.Parent = card

				local shadow2 = Instance.new("ImageLabel")
				noHit(shadow2)
				shadow2.AnchorPoint = Vector2.new(0.5, 0.5)
				shadow2.BackgroundTransparency = 1
				shadow2.Position = UDim2.new(0.5, 5, 0.5, 6)
				shadow2.Size = UDim2.new(1, 28, 0, h2)
				shadow2.ZIndex = card.ZIndex - 2
				shadow2.Image = "rbxassetid://6014261993"
				shadow2.ImageColor3 = C.ClayShadowDeep
				shadow2.ImageTransparency = 0.55
				shadow2.ScaleType = Enum.ScaleType.Slice
				shadow2.SliceCenter = Rect.new(49, 49, 450, 450)
				shadow2.Parent = card
			end

			function G:CreateToggle(tc2)
				tc2 = tc2 or {}
				local toggled = tc2.Default or false
				-- Key this toggle is tracked under in the Active panel (matches updateToggle).
				local activeKey = tc2.Name or tc2.Flag
				-- HideFromActive (alias: ShowInActive = false) keeps the toggle out of the
				-- Active Features panel while still working/counting normally.
				if activeKey and (tc2.HideFromActive or tc2.ShowInActive == false) then
					W._activeHidden[activeKey] = true
				end
				local cH = math.floor(44 * SC)
				local card = createCard(cH)

				local nL = Instance.new("TextLabel")
				noHit(nL)
				nL.BackgroundTransparency = 1
				nL.Position = UDim2.new(0, 16, 0, 0)
				nL.Size = UDim2.new(1, -80, 1, 0)
				nL.Font = Enum.Font.GothamBold
				nL.TextSize = FONT_ELEM_NAME
				nL.TextColor3 = C.Text
				nL.TextXAlignment = Enum.TextXAlignment.Left
				nL.ZIndex = 10
				nL.Parent = card
				local tIconAsset = tc2.Icon and getIconAsset(tc2.Icon)
				if tIconAsset then
					nL.Position = UDim2.new(0, 36, 0, 0)
					nL.Size = UDim2.new(1, -116, 1, 0)
					nL.Text = tc2.Name or "Toggle"
					local tImg = Instance.new("ImageLabel")
					noHit(tImg)
					tImg.BackgroundTransparency = 1
					tImg.AnchorPoint = Vector2.new(0, 0.5)
					tImg.Position = UDim2.new(0, 14, 0.5, 0)
					tImg.Size = UDim2.new(0, math.floor(14 * SC), 0, math.floor(14 * SC))
					tImg.Image = tIconAsset
					tImg.ImageColor3 = accent
					tImg.ScaleType = Enum.ScaleType.Fit
					tImg.ZIndex = 11
					tImg.Parent = card
				else
					nL.Text = tc2.Name or "Toggle"
				end

				local tW = math.floor(42 * SC)
				local tH = math.floor(24 * SC)
				local kD = math.floor(18 * SC)

				local tBg = Instance.new("Frame")
				noHit(tBg)
				tBg.AnchorPoint = Vector2.new(1, 0.5)
				tBg.BackgroundColor3 = C.TrackOff
				tBg.Position = UDim2.new(1, -16, 0.5, 0)
				tBg.Size = UDim2.new(0, tW, 0, tH)
				tBg.ZIndex = 11
				tBg.Parent = card
				corner(tBg, math.floor(tH / 2))
				strokeInst(tBg, C.Border, 1, 0.5)

				local fill = Instance.new("Frame")
				noHit(fill)
				fill.BackgroundColor3 = accent
				fill.BackgroundTransparency = 1
				fill.Size = UDim2.new(1, 0, 1, 0)
				fill.ZIndex = 10
				fill.Parent = tBg
				corner(fill, math.floor(tH / 2))

				local knob = Instance.new("Frame")
				noHit(knob)
				knob.AnchorPoint = Vector2.new(0, 0.5)
				knob.BackgroundColor3 = C.Dim
				knob.Position = UDim2.new(0, 3, 0.5, 0)
				knob.Size = UDim2.new(0, kD, 0, kD)
				knob.ZIndex = 12
				knob.Parent = tBg
				corner(knob, math.floor(kD / 2))

				local function updateToggle(animate, suppressCallback)
					if toggled then
						if animate ~= false then
							tw(fill, 0.3, {BackgroundTransparency = 0.08})
							springBounce(knob, "Position", UDim2.new(1, -kD - 3, 0.5, 0), 5)
							tw(knob, 0.3, {BackgroundColor3 = C.Text})
							tw(tBg, 0.3, {BackgroundColor3 = accent})
						else
							fill.BackgroundTransparency = 0.08
							knob.Position = UDim2.new(1, -kD - 3, 0.5, 0)
							knob.BackgroundColor3 = C.Text
							tBg.BackgroundColor3 = accent
						end
					else
						if animate ~= false then
							tw(fill, 0.3, {BackgroundTransparency = 1})
							springBounce(knob, "Position", UDim2.new(0, 3, 0.5, 0), 5)
							tw(knob, 0.3, {BackgroundColor3 = C.Dim})
							tw(tBg, 0.3, {BackgroundColor3 = C.TrackOff})
						else
							fill.BackgroundTransparency = 1
							knob.Position = UDim2.new(0, 3, 0.5, 0)
							knob.BackgroundColor3 = C.Dim
							tBg.BackgroundColor3 = C.TrackOff
						end
					end
					if tc2.Flag then
						W._activeFeatures[tc2.Name or tc2.Flag] = toggled
						updateActivePanel()
						W.Config:Set(tc2.Flag, toggled)
					end
					if tc2.Callback and not suppressCallback then task.spawn(tc2.Callback, toggled) end
				end

				card.MouseButton1Click:Connect(function()
					toggled = not toggled
					playSound(Sounds.toggle, 0.1, toggled and 1.15 or 0.9)
					createRipple(card, accent)
					updateToggle()
				end)

				if toggled then task.defer(function() updateToggle(false, true) end) end

				local elemData = {Name = tc2.Name or "Toggle", Tab = Tab.Name, SubTab = subTabName, Group = gc.Name, Type = "Toggle", _card = card}
				W._elems[#W._elems + 1] = elemData
				local api = {}
				function api:Set(v, noCallback)
					toggled = v
					updateToggle(nil, noCallback)
				end
				function api:Get() return toggled end
				-- Runtime control over this toggle's presence in the Active panel.
				function api:SetHiddenFromActive(hidden)
					if not activeKey then return end
					W._activeHidden[activeKey] = hidden and true or nil
					updateActivePanel()
				end
				function api:IsHiddenFromActive() return activeKey ~= nil and W._activeHidden[activeKey] == true end
				api._cb = tc2.Callback
				if tc2.Flag then W._flags[tc2.Flag] = api; W.Config:Register(tc2.Flag, api) end
				return api
			end

			function G:CreateSlider(sc2)
				sc2 = sc2 or {}
				local min = sc2.Min or 0
				local max = sc2.Max or 100
				local increment = sc2.Increment or 1
				local value = math.clamp(sc2.Default or min, min, max)
				local suffix = sc2.Suffix or ""
				local cH = math.floor(64 * SC)
				local card = createCard(cH)

				local nL = Instance.new("TextLabel")
				noHit(nL)
				nL.BackgroundTransparency = 1
				nL.Position = UDim2.new(0, 16, 0, 4)
				nL.Size = UDim2.new(0.55, -16, 0, 20)
				nL.Font = Enum.Font.GothamBold
				nL.TextSize = FONT_ELEM_NAME
				nL.TextColor3 = C.Text
				nL.TextXAlignment = Enum.TextXAlignment.Left
				nL.ZIndex = 10
				nL.Parent = card
				local slImgAsset = sc2.Icon and getIconAsset(sc2.Icon)
				if slImgAsset then
					nL.Position = UDim2.new(0, 36, 0, 4)
					nL.Size = UDim2.new(0.5, -36, 0, 20)
					nL.Text = sc2.Name or "Slider"
					local slI = Instance.new("ImageLabel")
					noHit(slI)
					slI.BackgroundTransparency = 1
					slI.AnchorPoint = Vector2.new(0, 0.5)
					slI.Position = UDim2.new(0, 14, 0, 14)
					slI.Size = UDim2.new(0, math.floor(14 * SC), 0, math.floor(14 * SC))
					slI.Image = slImgAsset
					slI.ImageColor3 = accent
					slI.ScaleType = Enum.ScaleType.Fit
					slI.ZIndex = 11
					slI.Parent = card
				else
					nL.Text = sc2.Name or "Slider"
				end

				local vL = Instance.new("TextLabel")
				noHit(vL)
				vL.BackgroundTransparency = 1
				vL.AnchorPoint = Vector2.new(1, 0)
				vL.Position = UDim2.new(1, -16, 0, 4)
				vL.Size = UDim2.new(0.45, -16, 0, 20)
				vL.Font = Enum.Font.GothamBold
				vL.TextSize = FONT_ELEM_VALUE
				vL.Text = tostring(value) .. suffix
				vL.TextColor3 = accent
				vL.TextXAlignment = Enum.TextXAlignment.Right
				vL.ZIndex = 10
				vL.Parent = card

				local trackHeight = math.floor(8 * SC)
				local tBg = Instance.new("Frame")
				noHit(tBg)
				tBg.BackgroundColor3 = C.TrackOff
				tBg.Position = UDim2.new(0, 16, 0, 30)
				tBg.Size = UDim2.new(1, -32, 0, trackHeight)
				tBg.ZIndex = 10
				tBg.Parent = card
				corner(tBg, math.floor(4 * SC))
				strokeInst(tBg, C.Border, 1, 0.55)

				local tFill = Instance.new("Frame")
				noHit(tFill)
				tFill.BackgroundColor3 = accent
				tFill.Size = UDim2.new(0, 0, 1, 0)
				tFill.ZIndex = 11
				tFill.Parent = tBg
				corner(tFill, math.floor(4 * SC))

				local tFillGrad = Instance.new("UIGradient")
				tFillGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, lerpColor(accent, C.Text, 0.25)),
					ColorSequenceKeypoint.new(1, accent),
				})
				tFillGrad.Parent = tFill

				local kS = math.floor(18 * SC)
				local knob = Instance.new("Frame")
				noHit(knob)
				knob.AnchorPoint = Vector2.new(0.5, 0.5)
				knob.BackgroundColor3 = C.Text
				knob.Position = UDim2.new(0, 0, 0.5, 0)
				knob.Size = UDim2.new(0, kS, 0, kS)
				knob.ZIndex = 13
				knob.Parent = tBg
				corner(knob, math.floor(kS / 2))
				addClayShadow(knob, math.floor(kS / 2))

				local tooltip = Instance.new("TextLabel")
				noHit(tooltip)
				tooltip.AnchorPoint = Vector2.new(0.5, 1)
				tooltip.BackgroundColor3 = C.Surface
				tooltip.BackgroundTransparency = 0.05
				tooltip.Position = UDim2.new(0.5, 0, 0, -4)
				tooltip.Size = UDim2.new(0, 48, 0, 20)
				tooltip.Font = Enum.Font.GothamBold
				tooltip.TextSize = math.floor(10 * SC)
				tooltip.Text = tostring(value)
				tooltip.TextColor3 = C.Text
				tooltip.Visible = false
				tooltip.ZIndex = 20
				tooltip.Parent = knob
				corner(tooltip, 6)
				strokeInst(tooltip, C.Border, 1, 0.5)

				local function updateVisual(val, suppressCallback)
					value = val
					local pct = (value - min) / (max - min)
					tFill.Size = UDim2.new(pct, 0, 1, 0)
					knob.Position = UDim2.new(pct, 0, 0.5, 0)
					vL.Text = tostring(value) .. suffix
					tooltip.Text = tostring(value)
					if sc2.Flag then W.Config:Set(sc2.Flag, value) end
					if sc2.Callback and not suppressCallback then task.spawn(sc2.Callback, value) end
				end
				updateVisual(value, true) -- initial render must not fire the callback

				local sliderDragging = false

				local function processInput(input)
					local absPos = tBg.AbsolutePosition
					local absSize = tBg.AbsoluteSize
					local relX = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
					local raw = min + (max - min) * relX
					local stepped = math.floor(raw / increment + 0.5) * increment
					stepped = math.clamp(stepped, min, max)
					if increment < 1 then
						stepped = tonumber(string.format("%." .. tostring(math.ceil(-math.log10(increment))) .. "f", stepped))
					end
					if stepped ~= value then
						updateVisual(stepped)
						playSound(Sounds.slide, 0.03, 0.9 + relX * 0.3)
					end
				end

				local hitSlider = Instance.new("TextButton")
				hitSlider.BackgroundTransparency = 1
				hitSlider.Text = ""
				hitSlider.Position = UDim2.new(0, 0, 0, 24)
				hitSlider.Size = UDim2.new(1, 0, 0, cH - 24)
				hitSlider.ZIndex = 14
				hitSlider.AutoButtonColor = false
				hitSlider.Parent = card

				hitSlider.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						sliderDragging = true
						tooltip.Visible = true
						card.ClipsDescendants = false
						card.ZIndex = 20
						tw(knob, 0.12, {Size = UDim2.new(0, kS + 8, 0, kS + 8), BackgroundColor3 = accent})
						tw(tFill, 0.1, {BackgroundTransparency = 0})
						processInput(input)
					end
				end)

				trackConn(UserInputService.InputChanged:Connect(function(input)
					if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						processInput(input)
					end
				end))

				trackConn(UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						if sliderDragging then
							sliderDragging = false
							tooltip.Visible = false
							card.ClipsDescendants = true
							card.ZIndex = 9
							tw(knob, 0.2, {Size = UDim2.new(0, kS, 0, kS), BackgroundColor3 = C.Text})
						end
					end
				end))

				local elemData = {Name = sc2.Name or "Slider", Tab = Tab.Name, SubTab = subTabName, Group = gc.Name, Type = "Slider", _card = card}
				W._elems[#W._elems + 1] = elemData
				local api = {}
				function api:Set(v, noCallback) updateVisual(math.clamp(v, min, max), noCallback) end
				function api:Get() return value end
				api._cb = sc2.Callback
				if sc2.Flag then W._flags[sc2.Flag] = api; W.Config:Register(sc2.Flag, api) end
				return api
			end

			function G:CreateDropdown(dc)
				dc = dc or {}
				local options = dc.Options or {}
				local multi = dc.Multi or false
				local selected, selectedSet
				if multi then
					selectedSet = {}
					if type(dc.Default) == "table" then
						selected = {}
						for _, v in ipairs(dc.Default) do selected[#selected+1] = v; selectedSet[v] = true end
					elseif dc.Default then
						selected = {dc.Default}; selectedSet[dc.Default] = true
					else
						selected = {}
					end
				else
					selected = dc.Default or (options[1] or "")
				end

				local function displayText()
					if multi then
						if #selected == 0 then return "None" end
						if #selected == 1 then return selected[1] end
						return selected[1] .. " +" .. (#selected - 1)
					end
					return tostring(selected)
				end

				local cH = math.floor(44 * SC)
				local card = createCard(cH)
				local expanded = false

				local nL = Instance.new("TextLabel")
				noHit(nL)
				nL.BackgroundTransparency = 1
				nL.Position = UDim2.new(0, 16, 0, 0)
				nL.Size = UDim2.new(0.5, -16, 0, cH)
				nL.Font = Enum.Font.GothamBold
				nL.TextSize = FONT_ELEM_NAME
				nL.Text = dc.Name or "Dropdown"
				nL.TextColor3 = C.Text
				nL.TextXAlignment = Enum.TextXAlignment.Left
				nL.ZIndex = 10
				nL.Parent = card

				local vL = Instance.new("TextLabel")
				noHit(vL)
				vL.AnchorPoint = Vector2.new(1, 0.5)
				vL.BackgroundColor3 = C.AccentSub
				vL.BackgroundTransparency = 0.35
				vL.Position = UDim2.new(1, -16, 0, math.floor(cH / 2))
				vL.Size = UDim2.new(0, math.floor(120 * SC), 0, math.floor(28 * SC))
				vL.Font = Enum.Font.GothamBold
				vL.TextSize = FONT_ELEM_VALUE
				vL.Text = displayText()
				vL.TextColor3 = accent
				vL.TextXAlignment = Enum.TextXAlignment.Left
				vL.ZIndex = 10
				vL.Parent = card
				corner(vL, 10)
				strokeInst(vL, C.Border, 1, 0.5)

				local vLPad = Instance.new("UIPadding")
				vLPad.PaddingLeft = UDim.new(0, 8)
				vLPad.PaddingRight = UDim.new(0, 24)
				vLPad.Parent = vL

				local ddArrow = Instance.new("ImageLabel")
				noHit(ddArrow)
				ddArrow.BackgroundTransparency = 1
				ddArrow.AnchorPoint = Vector2.new(1, 0.5)
				ddArrow.Position = UDim2.new(1, 14, 0.5, 0)
				ddArrow.Size = UDim2.new(0, math.floor(12 * SC), 0, math.floor(12 * SC))
				ddArrow.Image = getIconAsset("expand_more") or "rbxassetid://6031094687"
				ddArrow.ImageColor3 = accent
				ddArrow.ScaleType = Enum.ScaleType.Fit
				ddArrow.ZIndex = 11
				ddArrow.Rotation = 0
				ddArrow.Parent = vL

				local optList = Instance.new("Frame")
				noHit(optList)
				optList.BackgroundTransparency = 1
				optList.Position = UDim2.new(0, 8, 0, cH + 2)
				optList.Size = UDim2.new(1, -16, 0, 0)
				optList.ClipsDescendants = true
				optList.ZIndex = 12
				optList.Parent = card
				local optLayout = uiList(optList, 2)

				local function isSel(opt)
					if multi then return selectedSet[opt] == true end
					return opt == selected
				end

				local function buildOptions()
					for _, ch in pairs(optList:GetChildren()) do
						if ch:IsA("TextButton") then ch:Destroy() end
					end
					for i, opt in ipairs(options) do
						local sel = isSel(opt)
						local ob = Instance.new("TextButton")
						ob.BackgroundColor3 = sel and C.AccentSub or C.SurfaceAlt
						ob.BackgroundTransparency = sel and 0.2 or 0.5
						ob.Size = UDim2.new(1, 0, 0, math.floor(28 * SC))
						ob.Text = ""
						ob.AutoButtonColor = false
						ob.LayoutOrder = i
						ob.ZIndex = 14
						ob.Parent = optList
						corner(ob, 8)

						local xOff = multi and 28 or 10
						local ol = Instance.new("TextLabel")
						noHit(ol)
						ol.BackgroundTransparency = 1
						ol.Position = UDim2.new(0, xOff, 0, 0)
						ol.Size = UDim2.new(1, -(xOff + 10), 1, 0)
						ol.Font = sel and Enum.Font.GothamBold or Enum.Font.GothamMedium
						ol.TextSize = FONT_ELEM_VALUE
						ol.Text = opt
						ol.TextColor3 = sel and accent or C.Sub
						ol.TextXAlignment = Enum.TextXAlignment.Left
						ol.ZIndex = 15
						ol.Parent = ob

						if multi then
							local chk = Instance.new("Frame")
							noHit(chk)
							chk.AnchorPoint = Vector2.new(0, 0.5)
							chk.Position = UDim2.new(0, 8, 0.5, 0)
							chk.Size = UDim2.new(0, math.floor(14 * SC), 0, math.floor(14 * SC))
							chk.BackgroundColor3 = sel and accent or C.SurfaceAlt
							chk.BackgroundTransparency = sel and 0 or 0.3
							chk.ZIndex = 16
							chk.Parent = ob
							corner(chk, 4)
							strokeInst(chk, sel and accent or C.Border, 1, 0.4)
							if sel then
								local cm = Instance.new("TextLabel")
								noHit(cm)
								cm.BackgroundTransparency = 1
								cm.Size = UDim2.new(1, 0, 1, 0)
								cm.Font = Enum.Font.GothamBold
								cm.TextSize = math.floor(10 * SC)
								cm.Text = "?"
								cm.TextColor3 = C.BG
								cm.ZIndex = 17
								cm.Parent = chk
							end
						end

						ob.MouseEnter:Connect(function() tw(ob, 0.1, {BackgroundTransparency = 0.1}) end)
						ob.MouseLeave:Connect(function() tw(ob, 0.1, {BackgroundTransparency = sel and 0.2 or 0.5}) end)

						ob.MouseButton1Click:Connect(function()
							if multi then
								if selectedSet[opt] then
									selectedSet[opt] = nil
									local ns = {}
									for _, v in ipairs(selected) do if v ~= opt then ns[#ns+1] = v end end
									selected = ns
								else
									selectedSet[opt] = true
									selected[#selected+1] = opt
								end
								vL.Text = displayText()
								playSound(Sounds.sel, 0.08, 1.1)
								buildOptions()
								if dc.Flag then W.Config:Set(dc.Flag, selected) end
								if dc.Callback then task.spawn(dc.Callback, selected) end
							else
								selected = opt
								vL.Text = displayText()
								playSound(Sounds.sel, 0.1, 1.0)
								if dc.Flag then W.Config:Set(dc.Flag, selected) end
								if dc.Callback then task.spawn(dc.Callback, selected) end
								expanded = false
								tw(card, 0.2, {Size = UDim2.new(1, 0, 0, cH)}, Enum.EasingStyle.Quint)
								tw(optList, 0.2, {Size = UDim2.new(1, -16, 0, 0)}, Enum.EasingStyle.Quint)
								tw(ddArrow, 0.15, {Rotation = 0})
								buildOptions()
							end
						end)
					end
				end
				buildOptions()

				card.MouseButton1Click:Connect(function()
					expanded = not expanded
					if expanded then
						playSound(Sounds.expand, 0.08, 1.15)
						local itemH = math.floor(28 * SC) + 2
						local listH = #options * itemH + 4
						tw(card, 0.25, {Size = UDim2.new(1, 0, 0, cH + listH + 6)}, Enum.EasingStyle.Quint)
						tw(optList, 0.25, {Size = UDim2.new(1, -16, 0, listH)}, Enum.EasingStyle.Quint)
						tw(ddArrow, 0.2, {Rotation = 180})
					else
						playSound(Sounds.collapse, 0.06, 1.2)
						tw(card, 0.2, {Size = UDim2.new(1, 0, 0, cH)}, Enum.EasingStyle.Quint)
						tw(optList, 0.2, {Size = UDim2.new(1, -16, 0, 0)}, Enum.EasingStyle.Quint)
						tw(ddArrow, 0.15, {Rotation = 0})
					end
				end)

				local elemData = {Name = dc.Name or "Dropdown", Tab = Tab.Name, SubTab = subTabName, Group = gc.Name, Type = "Dropdown", _card = card}
				W._elems[#W._elems + 1] = elemData
				local api = {}
				function api:Set(v, noCallback)
					if multi then
						if type(v) == "table" then
							selected = v; selectedSet = {}
							for _, x in ipairs(v) do selectedSet[x] = true end
						end
					else
						selected = v
					end
					vL.Text = displayText()
					if dc.Flag then W.Config:Set(dc.Flag, selected) end
					if not noCallback and dc.Callback then task.spawn(dc.Callback, selected) end
					buildOptions()
				end
				function api:Get() return selected end
				function api:SetOptions(o)
					options = o
					if multi then
						local ns, nss = {}, {}
						for _, v in ipairs(selected) do
							for _, opt in ipairs(o) do if v == opt then ns[#ns+1] = v; nss[v] = true; break end end
						end
						selected = ns; selectedSet = nss
					else
						local f = false
						for _, opt in ipairs(o) do if opt == selected then f = true; break end end
						if not f then selected = o[1] or "" end
					end
					vL.Text = displayText()
					buildOptions()
				end
				api._cb = dc.Callback
				if dc.Flag then W._flags[dc.Flag] = api; W.Config:Register(dc.Flag, api) end
				return api
			end

			function G:CreateButton(bc)
				bc = bc or {}
				local cH = math.floor(44 * SC)
				local card = createCard(cH)
				addMagneticHover(card, 2)

				local bIcon = Instance.new("TextLabel")
				noHit(bIcon)
				bIcon.BackgroundTransparency = 1
				bIcon.Position = UDim2.new(0, 16, 0, 0)
				bIcon.Size = UDim2.new(0, 22, 1, 0)
				bIcon.Font = Enum.Font.GothamBold
				bIcon.TextSize = math.floor(15 * SC)
				bIcon.TextColor3 = accent
				bIcon.ZIndex = 10
				bIcon.Parent = card

				local bIconAsset = getIconAsset(bc.Icon)
				if bIconAsset then
					bIcon.Visible = false
					local bImgIcon = Instance.new("ImageLabel")
					noHit(bImgIcon)
					bImgIcon.BackgroundTransparency = 1
					bImgIcon.AnchorPoint = Vector2.new(0, 0.5)
					bImgIcon.Position = UDim2.new(0, 16, 0.5, 0)
					bImgIcon.Size = UDim2.new(0, math.floor(16 * SC), 0, math.floor(16 * SC))
					bImgIcon.Image = bIconAsset
					bImgIcon.ImageColor3 = accent
					bImgIcon.ScaleType = Enum.ScaleType.Fit
					bImgIcon.ZIndex = 11
					bImgIcon.Parent = card
				else
					bIcon.Text = getIcon(bc.Icon)
				end

				local bL = Instance.new("TextLabel")
				noHit(bL)
				bL.BackgroundTransparency = 1
				bL.Position = UDim2.new(0, 42, 0, 0)
				bL.Size = UDim2.new(1, -58, 1, 0)
				bL.Font = Enum.Font.GothamBold
				bL.TextSize = FONT_ELEM_NAME
				bL.Text = bc.Name or "Button"
				bL.TextColor3 = C.Text
				bL.TextXAlignment = Enum.TextXAlignment.Left
				bL.ZIndex = 10
				bL.Parent = card

				local arrow = Instance.new("TextLabel")
				noHit(arrow)
				arrow.AnchorPoint = Vector2.new(1, 0.5)
				arrow.BackgroundTransparency = 1
				arrow.Position = UDim2.new(1, -16, 0.5, 0)
				arrow.Size = UDim2.new(0, 20, 0, 20)
				arrow.Font = Enum.Font.GothamBold
				arrow.TextSize = 14
				arrow.Text = "\xE2\x86\x92"
				arrow.TextColor3 = C.Dim
				arrow.ZIndex = 10
				arrow.Parent = card

				card.MouseButton1Click:Connect(function()
					playSound(Sounds.click, 0.12, 1.05)
					createRipple(card, accent)
					springBounce(arrow, "Position", UDim2.new(1, -12, 0.5, 0), 8)
					tw(arrow, 0.12, {TextColor3 = accent})
					task.delay(0.2, function()
						tw(arrow, 0.25, {TextColor3 = C.Dim})
						springAnimate(arrow, "Position", UDim2.new(1, -16, 0.5, 0), 260, 22, 1)
					end)
					if bc.Callback then task.spawn(bc.Callback) end
				end)

				local elemData = {Name = bc.Name or "Button", Tab = Tab.Name, SubTab = subTabName, Group = gc.Name, Type = "Button", _card = card}
				W._elems[#W._elems + 1] = elemData
			end

			function G:CreateInput(ic)
				ic = ic or {}
				local cH = math.floor(44 * SC)
				local card = createCard(cH)

				local nL = Instance.new("TextLabel")
				noHit(nL)
				nL.BackgroundTransparency = 1
				nL.Position = UDim2.new(0, 16, 0, 0)
				nL.Size = UDim2.new(0.4, -16, 1, 0)
				nL.Font = Enum.Font.GothamBold
				nL.TextSize = FONT_ELEM_NAME
				nL.Text = ic.Name or "Input"
				nL.TextColor3 = C.Text
				nL.TextXAlignment = Enum.TextXAlignment.Left
				nL.ZIndex = 10
				nL.Parent = card

				local iBg = Instance.new("Frame")
				noHit(iBg)
				iBg.AnchorPoint = Vector2.new(1, 0.5)
				iBg.BackgroundColor3 = C.AccentSub
				iBg.BackgroundTransparency = 0.3
				iBg.Position = UDim2.new(1, -12, 0.5, 0)
				iBg.Size = UDim2.new(0.55, -8, 0, math.floor(30 * SC))
				iBg.ZIndex = 10
				iBg.Parent = card
				corner(iBg, 10)
				strokeInst(iBg, C.Border, 1, 0.5)

				local iBox = Instance.new("TextBox")
				iBox.BackgroundTransparency = 1
				iBox.Position = UDim2.new(0, 10, 0, 0)
				iBox.Size = UDim2.new(1, -20, 1, 0)
				iBox.Font = Enum.Font.GothamMedium
				iBox.TextSize = FONT_ELEM_VALUE
				iBox.Text = ic.Default or ""
				iBox.PlaceholderText = ic.Placeholder or "Type..."
				iBox.PlaceholderColor3 = C.Dim
				iBox.TextColor3 = C.Text
				iBox.TextXAlignment = Enum.TextXAlignment.Left
				iBox.ClearTextOnFocus = false
				iBox.ZIndex = 12
				iBox.Parent = iBg

				iBox.Focused:Connect(function()
					playSound(Sounds.click, 0.06, 1.2)
					tw(iBg, 0.15, {BackgroundTransparency = 0.1})
					springAnimate(iBg, "Size", UDim2.new(0.55, -4, 0, math.floor(32 * SC)), 300, 20, 0.8)
				end)
				iBox.FocusLost:Connect(function(enter)
					tw(iBg, 0.15, {BackgroundTransparency = 0.3})
					springAnimate(iBg, "Size", UDim2.new(0.55, -8, 0, math.floor(30 * SC)), 260, 22, 1)
					if enter and ic.Callback then
						playSound(Sounds.sel, 0.08, 1.0)
						task.spawn(ic.Callback, iBox.Text)
					end
					if ic.Flag then W.Config:Set(ic.Flag, iBox.Text) end
				end)

				local elemData = {Name = ic.Name or "Input", Tab = Tab.Name, SubTab = subTabName, Group = gc.Name, Type = "Input", _card = card}
				W._elems[#W._elems + 1] = elemData
				local api = {}
				function api:Set(v, noCallback)
					iBox.Text = v
					if ic.Flag then W.Config:Set(ic.Flag, v) end
					if not noCallback and ic.Callback then task.spawn(ic.Callback, v) end
				end
				function api:Get() return iBox.Text end
				api._cb = ic.Callback
				if ic.Flag then W._flags[ic.Flag] = api; W.Config:Register(ic.Flag, api) end
				return api
			end

			function G:CreateKeybind(kc)
				kc = kc or {}
				local currentKey = kc.Default or Enum.KeyCode.E
				local listening = false
				local cH = math.floor(44 * SC)
				local card = createCard(cH)

				local nL = Instance.new("TextLabel")
				noHit(nL)
				nL.BackgroundTransparency = 1
				nL.Position = UDim2.new(0, 16, 0, 0)
				nL.Size = UDim2.new(0.6, -16, 1, 0)
				nL.Font = Enum.Font.GothamBold
				nL.TextSize = FONT_ELEM_NAME
				nL.Text = kc.Name or "Keybind"
				nL.TextColor3 = C.Text
				nL.TextXAlignment = Enum.TextXAlignment.Left
				nL.ZIndex = 10
				nL.Parent = card

				local kBtn = Instance.new("TextButton")
				kBtn.AnchorPoint = Vector2.new(1, 0.5)
				kBtn.BackgroundColor3 = C.AccentSub
				kBtn.BackgroundTransparency = 0.25
				kBtn.Position = UDim2.new(1, -16, 0.5, 0)
				kBtn.Size = UDim2.new(0, math.floor(70 * SC), 0, math.floor(28 * SC))
				kBtn.Font = Enum.Font.GothamBold
				kBtn.TextSize = FONT_ELEM_VALUE
				kBtn.Text = currentKey.Name
				kBtn.TextColor3 = accent
				kBtn.AutoButtonColor = false
				kBtn.ZIndex = 11
				kBtn.Parent = card
				corner(kBtn, 10)
				strokeInst(kBtn, C.Border, 1, 0.5)

				kBtn.MouseButton1Click:Connect(function()
					if listening then return end
					listening = true
					kBtn.Text = "..."
					playSound(Sounds.click, 0.08, 1.1)
					tw(kBtn, 0.15, {BackgroundTransparency = 0.05})
					springBounce(kBtn, "Size", UDim2.new(0, math.floor(74 * SC), 0, math.floor(30 * SC)), 4)

					local conn
					conn = UserInputService.InputBegan:Connect(function(input, gpe)
						if gpe then return end
						if input.UserInputType == Enum.UserInputType.Keyboard then
							currentKey = input.KeyCode
							kBtn.Text = currentKey.Name
							listening = false
							tw(kBtn, 0.15, {BackgroundTransparency = 0.25})
							springAnimate(kBtn, "Size", UDim2.new(0, math.floor(70 * SC), 0, math.floor(28 * SC)), 280, 22, 1)
							playSound(Sounds.sel, 0.08, 1.0)
							if kc.Flag then W.Config:Set(kc.Flag, currentKey.Name) end
							if kc.Callback then task.spawn(kc.Callback, currentKey) end
							conn:Disconnect()
						end
					end)
				end)

				local elemData = {Name = kc.Name or "Keybind", Tab = Tab.Name, SubTab = subTabName, Group = gc.Name, Type = "Keybind", _card = card}
				W._elems[#W._elems + 1] = elemData
				local api = {}
				function api:Set(k, noCallback)
					if type(k) == "string" then
						local ok2, resolved = pcall(function() return Enum.KeyCode[k] end)
						if ok2 and resolved then k = resolved else return end
					end
					if not k then return end
					currentKey = k
					kBtn.Text = k.Name
					if kc.Flag then W.Config:Set(kc.Flag, k.Name) end
					if not noCallback and kc.Callback then task.spawn(kc.Callback, currentKey) end
				end
				function api:Get() return currentKey end
				api._cb = kc.Callback
				if kc.Flag then W._flags[kc.Flag] = api; W.Config:Register(kc.Flag, api) end
				return api
			end

			function G:CreateColorPicker(cc)
				cc = cc or {}
				local color = cc.Default or Color3.fromRGB(180, 180, 195)
				local h, s, v = Color3.toHSV(color)
				local cH = math.floor(44 * SC)
				local card = createCard(cH)
				local expandedCP = false

				local nL = Instance.new("TextLabel")
				noHit(nL)
				nL.BackgroundTransparency = 1
				nL.Position = UDim2.new(0, 16, 0, 0)
				nL.Size = UDim2.new(0.6, -16, 1, 0)
				nL.Font = Enum.Font.GothamBold
				nL.TextSize = FONT_ELEM_NAME
				nL.Text = cc.Name or "Color"
				nL.TextColor3 = C.Text
				nL.TextXAlignment = Enum.TextXAlignment.Left
				nL.ZIndex = 10
				nL.Parent = card

				local preview = Instance.new("Frame")
				noHit(preview)
				preview.AnchorPoint = Vector2.new(1, 0.5)
				preview.BackgroundColor3 = color
				preview.Position = UDim2.new(1, -16, 0.5, 0)
				preview.Size = UDim2.new(0, math.floor(36 * SC), 0, math.floor(24 * SC))
				preview.ZIndex = 11
				preview.Parent = card
				corner(preview, 8)
				strokeInst(preview, C.Border, 1, 0.4)

				local cpFrame = Instance.new("Frame")
				cpFrame.BackgroundColor3 = C.Surface
				cpFrame.BackgroundTransparency = 0.05
				cpFrame.Position = UDim2.new(0, 8, 0, cH)
				cpFrame.Size = UDim2.new(1, -16, 0, 0)
				cpFrame.ClipsDescendants = true
				cpFrame.ZIndex = 50
				cpFrame.Visible = false
				cpFrame.Parent = card
				corner(cpFrame, 14)
				strokeInst(cpFrame, C.Border, 1, 0.4)

				local svBox = Instance.new("Frame")
				svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
				svBox.Position = UDim2.new(0, 12, 0, 12)
				svBox.Size = UDim2.new(1, -60, 0, math.floor(100 * SC))
				svBox.ZIndex = 52
				svBox.Active = true
				svBox.ClipsDescendants = true
				svBox.Parent = cpFrame
				corner(svBox, 10)

				local whiteGrad = Instance.new("UIGradient")
				whiteGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
				})
				whiteGrad.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1),
				})
				whiteGrad.Parent = svBox

				local darkFrame = Instance.new("Frame")
				noHit(darkFrame)
				darkFrame.BackgroundColor3 = Color3.new(0, 0, 0)
				darkFrame.Size = UDim2.new(1, 0, 1, 0)
				darkFrame.ZIndex = 52
				darkFrame.Parent = svBox
				local darkGrad = Instance.new("UIGradient")
				darkGrad.Rotation = 90
				darkGrad.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 0),
				})
				darkGrad.Parent = darkFrame

				local svCursor = Instance.new("Frame")
				noHit(svCursor)
				svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
				svCursor.BackgroundColor3 = Color3.new(1, 1, 1)
				svCursor.Size = UDim2.new(0, 12, 0, 12)
				svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
				svCursor.ZIndex = 54
				svCursor.Parent = svBox
				corner(svCursor, 6)
				strokeInst(svCursor, Color3.new(0, 0, 0), 2, 0.2)

				local hueBar = Instance.new("Frame")
				hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
				hueBar.AnchorPoint = Vector2.new(1, 0)
				hueBar.Position = UDim2.new(1, -12, 0, 12)
				hueBar.Size = UDim2.new(0, math.floor(24 * SC), 0, math.floor(100 * SC))
				hueBar.ZIndex = 52
				hueBar.Active = true
				hueBar.Parent = cpFrame
				corner(hueBar, 8)

				local hueGrad = Instance.new("UIGradient")
				hueGrad.Rotation = 90
				hueGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
					ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
					ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
					ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
					ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
					ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
				})
				hueGrad.Parent = hueBar

				local hueCursor = Instance.new("Frame")
				noHit(hueCursor)
				hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
				hueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
				hueCursor.Size = UDim2.new(1, 6, 0, 8)
				hueCursor.Position = UDim2.new(0.5, 0, h, 0)
				hueCursor.ZIndex = 54
				hueCursor.Parent = hueBar
				corner(hueCursor, 4)
				strokeInst(hueCursor, Color3.new(0, 0, 0), 1.5, 0.3)

				local function updateColor(suppressCallback)
					color = Color3.fromHSV(h, s, v)
					preview.BackgroundColor3 = color
					svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
					svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
					hueCursor.Position = UDim2.new(0.5, 0, h, 0)
					if cc.Flag then
						W.Config:Set(cc.Flag, {
							R = math.floor(color.R * 255),
							G = math.floor(color.G * 255),
							B = math.floor(color.B * 255),
						})
					end
					if cc.Callback and not suppressCallback then task.spawn(cc.Callback, color) end
				end

				local svDrag = false
				local hueDrag = false

				svBox.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						svDrag = true
					end
				end)
				hueBar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						hueDrag = true
					end
				end)

				trackConn(UserInputService.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						if svDrag then
							local ap = svBox.AbsolutePosition
							local as = svBox.AbsoluteSize
							s = math.clamp((input.Position.X - ap.X) / as.X, 0.005, 1)
							v = 1 - math.clamp((input.Position.Y - ap.Y) / as.Y, 0, 1)
							updateColor()
						elseif hueDrag then
							local ap = hueBar.AbsolutePosition
							local as = hueBar.AbsoluteSize
							h = math.clamp((input.Position.Y - ap.Y) / as.Y, 0, 0.995)
							updateColor()
						end
					end
				end))

				trackConn(UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						svDrag = false
						hueDrag = false
					end
				end))

				local cpHeaderBtn = Instance.new("TextButton")
				cpHeaderBtn.BackgroundTransparency = 1
				cpHeaderBtn.Text = ""
				cpHeaderBtn.AutoButtonColor = false
				cpHeaderBtn.Size = UDim2.new(1, 0, 0, cH)
				cpHeaderBtn.Position = UDim2.new(0, 0, 0, 0)
				cpHeaderBtn.ZIndex = 14
				cpHeaderBtn.Parent = card

				cpHeaderBtn.MouseButton1Click:Connect(function()
					expandedCP = not expandedCP
					if expandedCP then

						cpFrame.Parent = card
						cpFrame.Position = UDim2.new(0, 8, 0, cH + 2)
						cpFrame.Size = UDim2.new(1, -16, 0, 0)
						cpFrame.ZIndex = 16
						cpFrame.Visible = true

						for _, child in pairs(cpFrame:GetDescendants()) do
							if child:IsA("GuiObject") then
								child.ZIndex = math.max(child.ZIndex, 17)
							end
						end
						svBox.ZIndex = 202
						hueBar.ZIndex = 202
						svCursor.ZIndex = 204
						hueCursor.ZIndex = 204
						darkFrame.ZIndex = 203

						playSound(Sounds.expand, 0.08, 1.1)
						local expandH = math.floor(130 * SC)
						tw(cpFrame, 0.3, {Size = UDim2.new(1, -16, 0, expandH)}, Enum.EasingStyle.Quint)
						tw(card, 0.3, {Size = UDim2.new(1, 0, 0, cH + expandH + 8)}, Enum.EasingStyle.Quint)

						local closeCon
						closeCon = UserInputService.InputBegan:Connect(function(inp)
							if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
								local mPos = inp.Position
								local cPos = card.AbsolutePosition
								local cSize = card.AbsoluteSize
								if mPos.X < cPos.X or mPos.X > cPos.X + cSize.X
									or mPos.Y < cPos.Y or mPos.Y > cPos.Y + cSize.Y then
									expandedCP = false
									playSound(Sounds.collapse, 0.06, 1.2)
									tw(cpFrame, 0.2, {Size = UDim2.new(1, -16, 0, 0)}, Enum.EasingStyle.Quint)
									tw(card, 0.2, {Size = UDim2.new(1, 0, 0, cH)}, Enum.EasingStyle.Quint)
									task.delay(0.22, function()
										cpFrame.Visible = false
										cpFrame.Parent = card
										cpFrame.Position = UDim2.new(0, 8, 0, cH)
										cpFrame.Size = UDim2.new(1, -16, 0, 0)
										cpFrame.ZIndex = 50
										svBox.ZIndex = 52
										hueBar.ZIndex = 52
										svCursor.ZIndex = 54
										hueCursor.ZIndex = 54
										darkFrame.ZIndex = 52
									end)
									if closeCon then closeCon:Disconnect(); closeCon = nil end
								end
							end
						end)
						trackConn(closeCon)
					else
						playSound(Sounds.collapse, 0.06, 1.2)
						tw(cpFrame, 0.2, {Size = UDim2.new(1, -16, 0, 0)}, Enum.EasingStyle.Quint)
						tw(card, 0.2, {Size = UDim2.new(1, 0, 0, cH)}, Enum.EasingStyle.Quint)
						task.delay(0.22, function()
							cpFrame.Visible = false
							cpFrame.Parent = card
							cpFrame.Position = UDim2.new(0, 8, 0, cH)
							cpFrame.Size = UDim2.new(1, -16, 0, 0)
							cpFrame.ZIndex = 50
							svBox.ZIndex = 52
							hueBar.ZIndex = 52
							svCursor.ZIndex = 54
							hueCursor.ZIndex = 54
							darkFrame.ZIndex = 52
						end)
					end
				end)

				local elemData = {Name = cc.Name or "ColorPicker", Tab = Tab.Name, SubTab = subTabName, Group = gc.Name, Type = "ColorPicker", _card = card}
				W._elems[#W._elems + 1] = elemData
				local api = {}
				function api:Set(c2, noCallback)
					if type(c2) == "table" and c2.R then
						c2 = Color3.fromRGB(c2.R, c2.G, c2.B)
					end
					h, s, v = Color3.toHSV(c2)
					updateColor(noCallback)
				end
				function api:Get() return color end
				api._cb = cc.Callback
				if cc.Flag then W._flags[cc.Flag] = api; W.Config:Register(cc.Flag, api) end
				return api
			end

			-- Compact info line. A left accent tick + muted medium text gives it a
			-- "home" so it reads as an intentional callout instead of bold text
			-- floating in an oversized plate. The card hugs the text via a
			-- scale-based clay shadow (excluded from AutomaticSize), unlike the old
			-- fixed-offset shadow that forced every card to a ~62px minimum.
			function G:CreateLabel(lc)
				lc = lc or {}
				local text = lc.Text or ""
				local iconAsset = lc.Icon and getIconAsset(lc.Icon)

				local lCard = Instance.new("Frame")
				lCard.BackgroundColor3 = C.SurfaceAlt
				lCard.BackgroundTransparency = 0.15
				lCard.Size = UDim2.new(1, 0, 0, math.floor(40 * SC))
				lCard.LayoutOrder = gNext()
				lCard.ZIndex = 9
				lCard.Parent = gContent
				corner(lCard, 12)
				strokeInst(lCard, C.Border, 1, 0.55)
				addClayShadow(lCard, 12)

				local tick = Instance.new("Frame")
				noHit(tick)
				tick.AnchorPoint = Vector2.new(0, 0.5)
				tick.BackgroundColor3 = accent
				tick.Position = UDim2.new(0, 13, 0.5, 0)
				tick.Size = UDim2.new(0, math.floor(3 * SC), 1, -18)
				tick.ZIndex = 11
				tick.Parent = lCard
				corner(tick, 2)
				local tickGrad = Instance.new("UIGradient")
				tickGrad.Rotation = 90
				tickGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, lerpColor(accent, C.Text, 0.4)),
					ColorSequenceKeypoint.new(1, accent),
				})
				tickGrad.Parent = tick

				local textX = 26
				if iconAsset then
					local ic = Instance.new("ImageLabel")
					noHit(ic)
					ic.BackgroundTransparency = 1
					ic.AnchorPoint = Vector2.new(0, 0.5)
					ic.Position = UDim2.new(0, 25, 0.5, 0)
					ic.Size = UDim2.new(0, math.floor(14 * SC), 0, math.floor(14 * SC))
					ic.Image = iconAsset
					ic.ImageColor3 = accent
					ic.ScaleType = Enum.ScaleType.Fit
					ic.ZIndex = 11
					ic.Parent = lCard
					textX = 46
				end

				local l = Instance.new("TextLabel")
				noHit(l)
				l.BackgroundTransparency = 1
				l.Position = UDim2.new(0, textX, 0, 0)
				l.Size = UDim2.new(1, -(textX + 16), 0, 0)
				l.AutomaticSize = Enum.AutomaticSize.Y
				l.Font = Enum.Font.GothamMedium
				l.TextSize = lc.TextSize or math.floor(13 * SC)
				l.Text = text
				l.TextColor3 = lerpColor(C.Text, C.Sub, 0.22)
				l.TextXAlignment = Enum.TextXAlignment.Left
				l.TextYAlignment = Enum.TextYAlignment.Top
				l.TextWrapped = true
				l.LineHeight = 1.12
				l.ZIndex = 10
				l.Parent = lCard
				-- Pad the text (not the card) so the tick keeps its absolute inset.
				local lPad = Instance.new("UIPadding")
				lPad.PaddingTop = UDim.new(0, math.floor(11 * SC))
				lPad.PaddingBottom = UDim.new(0, math.floor(12 * SC))
				lPad.Parent = l

				-- Fixed-height card that tracks the text's measured height, so it always
				-- hugs the content exactly. (Auto-sizing a card that also holds scale/offset
				-- children misbehaves: scale children blow the height up, offset shadows
				-- push the text to the top.)
				local function syncLabelH()
					lCard.Size = UDim2.new(1, 0, 0, math.max(math.floor(34 * SC), math.ceil(l.AbsoluteSize.Y)))
				end
				l:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncLabelH)
				task.defer(syncLabelH)

				return {Set = function(_, t) l.Text = t end, Get = function() return l.Text end, SetTextSize = function(_, s) l.TextSize = s end}
			end

			-- Titled block. A full-height accent stripe + a bold bright title over
			-- muted, line-spaced body text gives a real visual hierarchy (was: title
			-- and body identical bold-white, stacked with a newline).
			function G:CreateParagraph(pc)
				pc = pc or {}
				local content = pc.Content or ""
				local title = pc.Title or ""
				local iconAsset = pc.Icon and getIconAsset(pc.Icon)

				local pCard = Instance.new("Frame")
				pCard.BackgroundColor3 = C.SurfaceAlt
				pCard.BackgroundTransparency = 0.12
				pCard.Size = UDim2.new(1, 0, 0, math.floor(56 * SC))
				pCard.LayoutOrder = gNext()
				pCard.ZIndex = 9
				pCard.Parent = gContent
				corner(pCard, 12)
				strokeInst(pCard, C.Border, 1, 0.5)
				addClayShadow(pCard, 12)

				local stripe = Instance.new("Frame")
				noHit(stripe)
				stripe.AnchorPoint = Vector2.new(0, 0.5)
				stripe.BackgroundColor3 = accent
				stripe.Position = UDim2.new(0, 14, 0.5, 0)
				stripe.Size = UDim2.new(0, math.floor(3 * SC), 1, -22)
				stripe.ZIndex = 11
				stripe.Parent = pCard
				corner(stripe, 2)
				local stripeGrad = Instance.new("UIGradient")
				stripeGrad.Rotation = 90
				stripeGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, lerpColor(accent, C.Text, 0.45)),
					ColorSequenceKeypoint.new(1, accent),
				})
				stripeGrad.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 0.2),
				})
				stripeGrad.Parent = stripe

				local holder = Instance.new("Frame")
				noHit(holder)
				holder.BackgroundTransparency = 1
				holder.Position = UDim2.new(0, 28, 0, 0)
				holder.Size = UDim2.new(1, -46, 0, 0)
				holder.AutomaticSize = Enum.AutomaticSize.Y
				holder.ZIndex = 10
				holder.Parent = pCard
				local hPad = Instance.new("UIPadding")
				hPad.PaddingTop = UDim.new(0, math.floor(13 * SC))
				hPad.PaddingBottom = UDim.new(0, math.floor(14 * SC))
				hPad.Parent = holder
				local hList = Instance.new("UIListLayout")
				hList.FillDirection = Enum.FillDirection.Vertical
				hList.SortOrder = Enum.SortOrder.LayoutOrder
				hList.Padding = UDim.new(0, math.floor(5 * SC))
				hList.Parent = holder

				local titleLabel
				if title ~= "" then
					local titleRow = Instance.new("Frame")
					noHit(titleRow)
					titleRow.BackgroundTransparency = 1
					titleRow.Size = UDim2.new(1, 0, 0, 0)
					titleRow.AutomaticSize = Enum.AutomaticSize.Y
					titleRow.LayoutOrder = 1
					titleRow.ZIndex = 10
					titleRow.Parent = holder

					local tX = 0
					if iconAsset then
						local pIcon = Instance.new("ImageLabel")
						noHit(pIcon)
						pIcon.BackgroundTransparency = 1
						pIcon.AnchorPoint = Vector2.new(0, 0.5)
						pIcon.Position = UDim2.new(0, 0, 0, math.floor(8 * SC))
						pIcon.Size = UDim2.new(0, math.floor(15 * SC), 0, math.floor(15 * SC))
						pIcon.Image = iconAsset
						pIcon.ImageColor3 = accent
						pIcon.ScaleType = Enum.ScaleType.Fit
						pIcon.ZIndex = 11
						pIcon.Parent = titleRow
						tX = math.floor(22 * SC)
					end

					titleLabel = Instance.new("TextLabel")
					noHit(titleLabel)
					titleLabel.BackgroundTransparency = 1
					titleLabel.Position = UDim2.new(0, tX, 0, 0)
					titleLabel.Size = UDim2.new(1, -tX, 0, 0)
					titleLabel.AutomaticSize = Enum.AutomaticSize.Y
					titleLabel.Font = Enum.Font.GothamBold
					titleLabel.TextSize = FONT_ELEM_NAME
					titleLabel.Text = title
					titleLabel.TextColor3 = C.Text
					titleLabel.TextXAlignment = Enum.TextXAlignment.Left
					titleLabel.TextYAlignment = Enum.TextYAlignment.Top
					titleLabel.TextWrapped = true
					titleLabel.ZIndex = 10
					titleLabel.Parent = titleRow
				end

				local cL = Instance.new("TextLabel")
				noHit(cL)
				cL.BackgroundTransparency = 1
				cL.Size = UDim2.new(1, 0, 0, 0)
				cL.AutomaticSize = Enum.AutomaticSize.Y
				cL.Font = Enum.Font.GothamMedium
				cL.TextSize = math.floor(12.5 * SC)
				cL.Text = content
				cL.TextColor3 = C.Sub
				cL.TextXAlignment = Enum.TextXAlignment.Left
				cL.TextYAlignment = Enum.TextYAlignment.Top
				cL.TextWrapped = true
				cL.LineHeight = 1.2
				cL.LayoutOrder = 2
				cL.ZIndex = 10
				cL.Parent = holder

				-- Card tracks the text column's measured height (see CreateLabel).
				local function syncParaH()
					pCard.Size = UDim2.new(1, 0, 0, math.max(math.floor(40 * SC), math.ceil(holder.AbsoluteSize.Y)))
				end
				holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncParaH)
				task.defer(syncParaH)

				local api = {}
				function api:Set(d)
					d = d or {}
					if d.Title ~= nil then
						title = d.Title
						if titleLabel then titleLabel.Text = title end
					end
					if d.Content ~= nil then
						content = d.Content
						cL.Text = content
					end
				end
				function api:Get() return title ~= "" and (title .. "\n" .. content) or content end
				return api
			end

			function G:CreateSeparator()
				local sep = Instance.new("Frame")
				noHit(sep)
				sep.BackgroundColor3 = C.Border
				sep.BackgroundTransparency = 0.55
				sep.Size = UDim2.new(1, -24, 0, 1)
				sep.LayoutOrder = gNext()
				sep.ZIndex = 8
				sep.Parent = gContent

				local sepGrad = Instance.new("UIGradient")
				sepGrad.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.15, 0),
					NumberSequenceKeypoint.new(0.85, 0),
					NumberSequenceKeypoint.new(1, 1),
				})
				sepGrad.Parent = sep
			end

			return G
		end

		function Tab:CreateGroup(gc)
			gc = gc or {}
			return Tab:_createGroupInternal(gc, contentScroll, nil)
		end

		return Tab
	end

	function W:Destroy()
		for _, conn in pairs(W._conns) do
			pcall(function() conn:Disconnect() end)
		end
		hideBlur()
		playSound(Sounds.collapse, 0.12, 0.8)
		tw(main, 0.35, {
			Size = UDim2.new(0, 0, 0, 0),
			GroupTransparency = 1,
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.4, function()
			screenGui:Destroy()
			destroyBlur()
		end)
	end

	local watermarkVisible = true
	local watermarkFrame = Instance.new("Frame")
	watermarkFrame.AnchorPoint = Vector2.new(0, 0)
	watermarkFrame.BackgroundColor3 = C.BG
	watermarkFrame.BackgroundTransparency = 0.08
	watermarkFrame.Position = UDim2.new(0, 16, 0, 48)
	watermarkFrame.Size = UDim2.new(0, 0, 0, math.floor(26 * SC))
	watermarkFrame.AutomaticSize = Enum.AutomaticSize.X
	watermarkFrame.ZIndex = 55
	watermarkFrame.Visible = true
	watermarkFrame.Active = true
	watermarkFrame.Draggable = true
	watermarkFrame.Parent = screenGui
	corner(watermarkFrame, 8)
	strokeInst(watermarkFrame, C.Border, 1, 0.5)
	addClayShadow(watermarkFrame, 8)

	local wmPad = Instance.new("UIPadding")
	wmPad.PaddingLeft = UDim.new(0, 12)
	wmPad.PaddingRight = UDim.new(0, 12)
	wmPad.Parent = watermarkFrame

	local wmText = Instance.new("TextLabel")
	noHit(wmText)
	wmText.BackgroundTransparency = 1
	wmText.Position = UDim2.new(0, 0, 0, 0)
	wmText.Size = UDim2.new(0, 0, 1, 0)
	wmText.AutomaticSize = Enum.AutomaticSize.X
	wmText.Font = Enum.Font.GothamBold
	wmText.TextSize = math.floor(11 * SC)
	wmText.Text = title .. "  |  Loading..."
	wmText.TextColor3 = C.Text
	wmText.TextTransparency = 0
	wmText.TextXAlignment = Enum.TextXAlignment.Left
	wmText.ZIndex = 56
	wmText.Parent = watermarkFrame

	local wmUpdateCounter = 0
	poolAdd(function(dt)
		if not wmText or not wmText.Parent then return false end
		wmUpdateCounter = wmUpdateCounter + dt
		if wmUpdateCounter < 0.5 then return true end
		wmUpdateCounter = 0

		local fps = math.floor(1 / dt)
		local ping = "N/A"
		pcall(function()
			ping = tostring(math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) .. "ms"
		end)
		if ping == "N/A" then
			pcall(function()
				ping = tostring(math.floor(Player:GetNetworkPing() * 1000)) .. "ms"
			end)
		end

		local timeStr = os.date("%H:%M")
		local pName = ""
		pcall(function() pName = Player.DisplayName end)

		wmText.Text = title .. " | " .. tostring(fps) .. " FPS"
			.. " | " .. ping
			.. " | " .. pName
			.. " | " .. timeStr

		return true
	end)

	function W:SetWatermarkVisible(vis)
		watermarkVisible = vis
		watermarkFrame.Visible = vis
	end

	function W:SetWatermarkText(txt)
		wmText.Text = txt
	end

	function W:SetFooterVisible(vis)
		if footer and footer.Parent then footer.Visible = vis end
	end

	function W:SetBGVisible(vis)
		if bgMaster and bgMaster.Parent then bgMaster.Visible = vis end
	end

	function W:SetBlurEnabled(vis)
		blurEnabled = vis
		if vis then showBlur() else hideBlur() end
	end

	function W:SetUIScale(scale)
		scale = math.clamp(scale, 0.5, 1.5)
		tw(uiScaleObj, 0.3, {Scale = scale}, Enum.EasingStyle.Quint)
	end

	function W:SetSoundsEnabled(vis)
		SND_ON = vis
	end

	function W:SetSoundPack(name)
		setSoundPack(name)
	end

	function W:GetSoundPackNames()
		local r = {}
		for k in pairs(SoundPacks) do r[#r + 1] = k end
		table.sort(r)
		return r
	end

	function W:SetToggleKeybind(key)
		if type(key) == "string" then key = Enum.KeyCode[key] end
		if key then keybind = key end
	end

	function W:RegisterKeybind(name, key, callback)
		W._customKeybinds = W._customKeybinds or {}
		if type(key) == "string" then key = Enum.KeyCode[key] end
		W._customKeybinds[name] = {Key = key, Callback = callback, Enabled = true}
	end

	function W:UnregisterKeybind(name)
		if W._customKeybinds then W._customKeybinds[name] = nil end
	end

	function W:SetKeybindEnabled(name, enabled)
		if W._customKeybinds and W._customKeybinds[name] then
			W._customKeybinds[name].Enabled = enabled
		end
	end

	function W:SetKeybindKey(name, key)
		if type(key) == "string" then key = Enum.KeyCode[key] end
		if W._customKeybinds and W._customKeybinds[name] then
			W._customKeybinds[name].Key = key
		end
	end

	function W:GetKeybinds()
		return W._customKeybinds or {}
	end

	trackConn(UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		if W._customKeybinds then
			for _, kb in pairs(W._customKeybinds) do
				if kb.Enabled and kb.Key == input.KeyCode and kb.Callback then
					task.spawn(kb.Callback)
				end
			end
		end
	end))

	local ThemePresets = {
		["Default"] = {
			BG = Color3.fromRGB(14, 14, 20),
			Surface = Color3.fromRGB(24, 24, 32),
			Border = Color3.fromRGB(42, 42, 55),
			Text = Color3.fromRGB(225, 225, 235),
			Sub = Color3.fromRGB(145, 145, 165),
			Accent = Color3.fromRGB(180, 180, 195),
			Ok = Color3.fromRGB(75, 190, 130),
		},
		["Midnight"] = {
			BG = Color3.fromRGB(8, 10, 20),
			Surface = Color3.fromRGB(14, 18, 32),
			Border = Color3.fromRGB(28, 35, 55),
			Text = Color3.fromRGB(200, 210, 230),
			Sub = Color3.fromRGB(100, 115, 150),
			Accent = Color3.fromRGB(75, 120, 200),
			Ok = Color3.fromRGB(60, 150, 170),
		},
		["Rose"] = {
			BG = Color3.fromRGB(16, 10, 12),
			Surface = Color3.fromRGB(26, 18, 22),
			Border = Color3.fromRGB(45, 32, 38),
			Text = Color3.fromRGB(230, 215, 220),
			Sub = Color3.fromRGB(140, 110, 120),
			Accent = Color3.fromRGB(200, 100, 120),
			Ok = Color3.fromRGB(180, 90, 110),
		},
		["Forest"] = {
			BG = Color3.fromRGB(8, 14, 10),
			Surface = Color3.fromRGB(14, 24, 18),
			Border = Color3.fromRGB(28, 44, 34),
			Text = Color3.fromRGB(200, 228, 210),
			Sub = Color3.fromRGB(100, 140, 118),
			Accent = Color3.fromRGB(55, 165, 105),
			Ok = Color3.fromRGB(45, 175, 115),
		},
		["OLED"] = {
			BG = Color3.fromRGB(0, 0, 0),
			Surface = Color3.fromRGB(8, 8, 8),
			Border = Color3.fromRGB(22, 22, 22),
			Text = Color3.fromRGB(220, 220, 220),
			Sub = Color3.fromRGB(100, 100, 100),
			Accent = Color3.fromRGB(160, 160, 160),
			Ok = Color3.fromRGB(80, 170, 80),
		},
		["Neon"] = {
			BG = Color3.fromRGB(6, 3, 12),
			Surface = Color3.fromRGB(12, 8, 24),
			Border = Color3.fromRGB(30, 22, 55),
			Text = Color3.fromRGB(225, 215, 245),
			Sub = Color3.fromRGB(130, 110, 170),
			Accent = Color3.fromRGB(150, 60, 220),
			Ok = Color3.fromRGB(40, 200, 170),
		},
		["Ember"] = {
			BG = Color3.fromRGB(14, 8, 6),
			Surface = Color3.fromRGB(24, 16, 12),
			Border = Color3.fromRGB(45, 30, 24),
			Text = Color3.fromRGB(235, 220, 208),
			Sub = Color3.fromRGB(155, 125, 108),
			Accent = Color3.fromRGB(210, 100, 45),
			Ok = Color3.fromRGB(220, 135, 40),
		},
		["Frost"] = {
			BG = Color3.fromRGB(10, 14, 18),
			Surface = Color3.fromRGB(18, 24, 32),
			Border = Color3.fromRGB(34, 46, 60),
			Text = Color3.fromRGB(210, 225, 240),
			Sub = Color3.fromRGB(120, 145, 168),
			Accent = Color3.fromRGB(90, 175, 230),
			Ok = Color3.fromRGB(75, 190, 215),
		},
		["Void"] = {
			BG = Color3.fromRGB(3, 2, 6),
			Surface = Color3.fromRGB(8, 6, 14),
			Border = Color3.fromRGB(20, 16, 35),
			Text = Color3.fromRGB(190, 185, 215),
			Sub = Color3.fromRGB(95, 88, 135),
			Accent = Color3.fromRGB(110, 65, 210),
			Ok = Color3.fromRGB(85, 50, 200),
		},
		["Crimson"] = {
			BG = Color3.fromRGB(10, 4, 4),
			Surface = Color3.fromRGB(20, 10, 10),
			Border = Color3.fromRGB(40, 22, 22),
			Text = Color3.fromRGB(230, 205, 205),
			Sub = Color3.fromRGB(140, 95, 95),
			Accent = Color3.fromRGB(185, 45, 55),
			Ok = Color3.fromRGB(200, 60, 50),
		},
		["Mint"] = {
			BG = Color3.fromRGB(6, 12, 10),
			Surface = Color3.fromRGB(12, 22, 18),
			Border = Color3.fromRGB(24, 42, 35),
			Text = Color3.fromRGB(200, 235, 222),
			Sub = Color3.fromRGB(105, 155, 135),
			Accent = Color3.fromRGB(45, 190, 150),
			Ok = Color3.fromRGB(35, 205, 160),
		},
		["Gold"] = {
			BG = Color3.fromRGB(10, 9, 6),
			Surface = Color3.fromRGB(20, 18, 12),
			Border = Color3.fromRGB(38, 34, 24),
			Text = Color3.fromRGB(232, 225, 200),
			Sub = Color3.fromRGB(150, 138, 105),
			Accent = Color3.fromRGB(195, 165, 55),
			Ok = Color3.fromRGB(210, 175, 45),
		},
	}

	W.ThemePresets = ThemePresets
	W.CurrentTheme = "Default"

	function W:GetThemeNames()
		local names = {}
		for k, _ in pairs(ThemePresets) do
			names[#names + 1] = k
		end
		table.sort(names)
		return names
	end

	function W:SetTheme(name)
		local preset = ThemePresets[name]
		if not preset then return false end
		W.CurrentTheme = name
		local dur = 0.45
		local newC = {
			BG = preset.BG or C.BG,
			Surface = preset.Surface or C.Surface,
			Border = preset.Border or C.Border,
			Text = preset.Text or C.Text,
			Sub = preset.Sub or C.Sub,
			Accent = preset.Accent or C.Accent,
			Ok = preset.Ok or C.Ok,
		}
		local function safeTw(obj, props)
			if obj and obj.Parent then pcall(function() tw(obj, dur, props, Enum.EasingStyle.Quint) end) end
		end
		safeTw(main, {BackgroundColor3 = newC.BG})
		safeTw(bgMaster, {BackgroundColor3 = newC.BG})
		safeTw(topbar, {BackgroundColor3 = lerpColor(newC.BG, newC.Surface, 0.5)})
		safeTw(sidebar, {BackgroundColor3 = lerpColor(newC.BG, newC.Surface, 0.3)})
		safeTw(footer, {BackgroundColor3 = lerpColor(newC.BG, newC.Surface, 0.5)})
		if logoIcon and logoIcon.Parent then
			safeTw(logoIcon, {ImageColor3 = newC.Accent})
		end
		if logoText and logoText.Parent then
			logoText.Text = string.format(
				'<font color="rgb(%d,%d,%d)">Expensive</font> <font color="rgb(%d,%d,%d)">Hub</font>',
				math.floor(newC.Text.R*255), math.floor(newC.Text.G*255), math.floor(newC.Text.B*255),
				math.floor(newC.Sub.R*255), math.floor(newC.Sub.G*255), math.floor(newC.Sub.B*255))
		end
		for _, ch in pairs(main:GetDescendants()) do
			pcall(function()
				if ch:IsA("Frame") or ch:IsA("CanvasGroup") then
					if ch.BackgroundTransparency < 0.15 then
						local bc = ch.BackgroundColor3
						local dBG = math.abs(bc.R - C.BG.R) + math.abs(bc.G - C.BG.G) + math.abs(bc.B - C.BG.B)
						local dSurf = math.abs(bc.R - C.Surface.R) + math.abs(bc.G - C.Surface.G) + math.abs(bc.B - C.Surface.B)
						if dBG < 0.15 then
							safeTw(ch, {BackgroundColor3 = newC.BG})
						elseif dSurf < 0.15 then
							safeTw(ch, {BackgroundColor3 = newC.Surface})
						end
					end
				end
				if ch:IsA("TextLabel") or ch:IsA("TextButton") or ch:IsA("TextBox") then
					if ch.TextTransparency < 0.5 then
						local tc = ch.TextColor3
						local dText = math.abs(tc.R - C.Text.R) + math.abs(tc.G - C.Text.G) + math.abs(tc.B - C.Text.B)
						local dSub = math.abs(tc.R - C.Sub.R) + math.abs(tc.G - C.Sub.G) + math.abs(tc.B - C.Sub.B)
						local dDim = math.abs(tc.R - C.Dim.R) + math.abs(tc.G - C.Dim.G) + math.abs(tc.B - C.Dim.B)
						local dAcc = math.abs(tc.R - C.Accent.R) + math.abs(tc.G - C.Accent.G) + math.abs(tc.B - C.Accent.B)
						if dAcc < 0.1 then
							safeTw(ch, {TextColor3 = newC.Accent})
						elseif dText < 0.1 then
							safeTw(ch, {TextColor3 = newC.Text})
						elseif dSub < 0.15 or dDim < 0.15 then
							safeTw(ch, {TextColor3 = newC.Sub})
						end
					end
				end
				if ch:IsA("ImageLabel") or ch:IsA("ImageButton") then
					if ch.ImageTransparency < 0.5 then
						local ic = ch.ImageColor3
						local dAcc = math.abs(ic.R - C.Accent.R) + math.abs(ic.G - C.Accent.G) + math.abs(ic.B - C.Accent.B)
						if dAcc < 0.15 then
							safeTw(ch, {ImageColor3 = newC.Accent})
						end
					end
				end
				if ch:IsA("UIStroke") then
					local sc = ch.Color
					local dBrd = math.abs(sc.R - C.Border.R) + math.abs(sc.G - C.Border.G) + math.abs(sc.B - C.Border.B)
					if dBrd < 0.15 then
						safeTw(ch, {Color = newC.Border})
					end
				end
				if ch:IsA("ScrollingFrame") then
					safeTw(ch, {ScrollBarImageColor3 = newC.Border})
				end
			end)
		end
		if activeOverlay and activeOverlay.Parent then
			safeTw(activeOverlay, {BackgroundColor3 = newC.Surface})
		end
		for _, ch in pairs(screenGui:GetDescendants()) do
			pcall(function()
				if ch:IsA("CanvasGroup") and ch.BackgroundTransparency < 0.3 then
					safeTw(ch, {BackgroundColor3 = lerpColor(newC.BG, newC.Surface, 0.4)})
				end
			end)
		end
		C.BG = newC.BG
		C.Surface = newC.Surface
		C.Border = newC.Border
		C.Text = newC.Text
		C.Sub = newC.Sub
		C.Accent = newC.Accent
		C.Ok = newC.Ok
		C.BGAlt = lerpColor(newC.BG, newC.Surface, 0.4)
		C.TopbarBG = lerpColor(newC.BG, newC.Surface, 0.5)
		C.SidebarBG = lerpColor(newC.BG, newC.Surface, 0.3)
		C.FooterBG = lerpColor(newC.BG, newC.Surface, 0.5)
		C.Dim = lerpColor(newC.Sub, newC.BG, 0.3)
		C.AccentLit = lerpColor(newC.Accent, Color3.new(1,1,1), 0.15)
		C.AccentSub = lerpColor(newC.Accent, newC.BG, 0.7)
		return true
	end

	local keybindViewerVisible = false
	local keybindViewerFrame = Instance.new("CanvasGroup")
	noHit(keybindViewerFrame)
	keybindViewerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	keybindViewerFrame.BackgroundColor3 = C.BGAlt
	keybindViewerFrame.BackgroundTransparency = 0.05
	keybindViewerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	keybindViewerFrame.Size = UDim2.new(0, math.floor(320 * SC), 0, math.floor(400 * SC))
	keybindViewerFrame.ZIndex = 90
	keybindViewerFrame.Visible = false
	keybindViewerFrame.Parent = screenGui
	corner(keybindViewerFrame, 18)
	strokeInst(keybindViewerFrame, C.Border, 1, 0.3)
	addClayShadow(keybindViewerFrame, 18)

	local kbvHeader = Instance.new("TextLabel")
	noHit(kbvHeader)
	kbvHeader.BackgroundTransparency = 1
	kbvHeader.Size = UDim2.new(1, 0, 0, math.floor(42 * SC))
	kbvHeader.Font = Enum.Font.GothamBold
	kbvHeader.TextSize = math.floor(15 * SC)
	kbvHeader.Text = "Keybind List"
	kbvHeader.TextColor3 = C.Accent
	kbvHeader.ZIndex = 91
	kbvHeader.Parent = keybindViewerFrame

	local kbvSep = Instance.new("Frame")
	noHit(kbvSep)
	kbvSep.BackgroundColor3 = C.Border
	kbvSep.BackgroundTransparency = 0.5
	kbvSep.Size = UDim2.new(1, -24, 0, 1)
	kbvSep.Position = UDim2.new(0, 12, 0, math.floor(42 * SC))
	kbvSep.ZIndex = 91
	kbvSep.Parent = keybindViewerFrame

	local kbvScroll = Instance.new("ScrollingFrame")
	noHit(kbvScroll)
	kbvScroll.BackgroundTransparency = 1
	kbvScroll.Position = UDim2.new(0, 0, 0, math.floor(48 * SC))
	kbvScroll.Size = UDim2.new(1, 0, 1, -math.floor(48 * SC))
	kbvScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	kbvScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	kbvScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	kbvScroll.ScrollBarThickness = 3
	kbvScroll.ScrollBarImageColor3 = C.Accent
	kbvScroll.ScrollBarImageTransparency = 0.5
	kbvScroll.ZIndex = 91
	kbvScroll.Parent = keybindViewerFrame
	pad(kbvScroll, 8, 8, 14, 14)
	uiList(kbvScroll, 4, Enum.FillDirection.Vertical)

	local kbvClose = Instance.new("TextButton")
	kbvClose.AnchorPoint = Vector2.new(1, 0)
	kbvClose.BackgroundTransparency = 1
	kbvClose.Position = UDim2.new(1, -10, 0, 8)
	kbvClose.Size = UDim2.new(0, math.floor(28 * SC), 0, math.floor(28 * SC))
	kbvClose.Text = "X"
	kbvClose.Font = Enum.Font.GothamBold
	kbvClose.TextSize = math.floor(16 * SC)
	kbvClose.TextColor3 = C.Sub
	kbvClose.AutoButtonColor = false
	kbvClose.ZIndex = 92
	kbvClose.Parent = keybindViewerFrame
	kbvClose.MouseButton1Click:Connect(function()
		keybindViewerVisible = false
		playSound(Sounds.collapse, 0.06, 1.2)
		tw(keybindViewerFrame, 0.25, {Size = UDim2.new(0, math.floor(320 * SC), 0, 0), GroupTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.3, function()
			keybindViewerFrame.Visible = false
			keybindViewerFrame.GroupTransparency = 0
		end)
	end)

	W._keybindEntries = {}

	local function refreshKeybindViewer()
		for _, c in pairs(kbvScroll:GetChildren()) do
			if c:IsA("Frame") then c:Destroy() end
		end

		local entries = W._keybindEntries
		if #entries == 0 then
			local emptyLabel = Instance.new("TextLabel")
			noHit(emptyLabel)
			emptyLabel.BackgroundTransparency = 1
			emptyLabel.Size = UDim2.new(1, 0, 0, 40)
			emptyLabel.Font = Enum.Font.GothamMedium
			emptyLabel.TextSize = math.floor(12 * SC)
			emptyLabel.Text = "No keybinds registered"
			emptyLabel.TextColor3 = C.Sub
			emptyLabel.ZIndex = 92
			emptyLabel.Parent = kbvScroll
			return
		end

		for i, entry in ipairs(entries) do
			local row = Instance.new("Frame")
			noHit(row)
			row.BackgroundColor3 = C.Surface
			row.BackgroundTransparency = 0.4
			row.Size = UDim2.new(1, 0, 0, math.floor(32 * SC))
			row.LayoutOrder = i
			row.ZIndex = 92
			row.Parent = kbvScroll
			corner(row, 8)

			local keyBadge = Instance.new("Frame")
			noHit(keyBadge)
			keyBadge.AnchorPoint = Vector2.new(1, 0.5)
			keyBadge.BackgroundColor3 = C.AccentSub
			keyBadge.Position = UDim2.new(1, -8, 0.5, 0)
			keyBadge.Size = UDim2.new(0, math.floor(60 * SC), 0, math.floor(22 * SC))
			keyBadge.ZIndex = 93
			keyBadge.Parent = row
			corner(keyBadge, 6)
			strokeInst(keyBadge, C.Border, 1, 0.5)

			local keyText = Instance.new("TextLabel")
			noHit(keyText)
			keyText.BackgroundTransparency = 1
			keyText.Size = UDim2.new(1, 0, 1, 0)
			keyText.Font = Enum.Font.Code
			keyText.TextSize = math.floor(10 * SC)
			keyText.Text = entry.Key or "?"
			keyText.TextColor3 = C.Accent
			keyText.ZIndex = 94
			keyText.Parent = keyBadge

			local nameL = Instance.new("TextLabel")
			noHit(nameL)
			nameL.BackgroundTransparency = 1
			nameL.Position = UDim2.new(0, 10, 0, 0)
			nameL.Size = UDim2.new(0.6, 0, 1, 0)
			nameL.Font = Enum.Font.GothamMedium
			nameL.TextSize = math.floor(11 * SC)
			nameL.Text = entry.Name or ""
			nameL.TextColor3 = C.Text
			nameL.TextTransparency = 0.1
			nameL.TextXAlignment = Enum.TextXAlignment.Left
			nameL.TextTruncate = Enum.TextTruncate.AtEnd
			nameL.ZIndex = 93
			nameL.Parent = row
		end
	end

	function W:ShowKeybindViewer()
		keybindViewerVisible = true
		refreshKeybindViewer()
		keybindViewerFrame.Visible = true
		keybindViewerFrame.Size = UDim2.new(0, math.floor(320 * SC), 0, 0)
		playSound(Sounds.expand, 0.08, 1.0)
		tw(keybindViewerFrame, 0.35, {Size = UDim2.new(0, math.floor(320 * SC), 0, math.floor(400 * SC))}, Enum.EasingStyle.Back)
	end

	function W:HideKeybindViewer()
		keybindViewerVisible = false
		playSound(Sounds.collapse, 0.06, 1.2)
		tw(keybindViewerFrame, 0.25, {Size = UDim2.new(0, math.floor(320 * SC), 0, 0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.3, function()
			keybindViewerFrame.Visible = false
		end)
	end

	trackConn(UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Enum.KeyCode.B and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			if keybindViewerVisible then
				W:HideKeybindViewer()
			else
				W:ShowKeybindViewer()
			end
		end
	end))

	W._tabBadges = {}
	W._tabFeatureCounts = {}

	local function updateTabBadges()
		local counts = {}
		for name, val in pairs(W._activeFeatures) do
			if val then
				for _, elem in pairs(W._elems) do
					if elem.Name == name and elem.Tab then
						counts[elem.Tab] = (counts[elem.Tab] or 0) + 1
						break
					end
				end
			end
		end
		W._tabFeatureCounts = counts

		for tabName, badge in pairs(W._tabBadges) do
			local count = counts[tabName] or 0
			if count > 0 then
				badge.Visible = true
				badge._label.Text = tostring(count)
				if badge._lastCount ~= count then
					springBounce(badge, "Size",
						UDim2.new(0, math.floor(18 * SC), 0, math.floor(14 * SC)), 1.2)
					badge._lastCount = count
				end
			else
				badge.Visible = false
			end
		end
	end

	local origUpdateActivePanel = updateActivePanel
	updateActivePanel = function()
		origUpdateActivePanel()
		updateTabBadges()
	end

	local tooltipFrame = Instance.new("Frame")
	noHit(tooltipFrame)
	tooltipFrame.BackgroundColor3 = C.Surface
	tooltipFrame.BackgroundTransparency = 0.05
	tooltipFrame.Size = UDim2.new(0, 0, 0, math.floor(28 * SC))
	tooltipFrame.AutomaticSize = Enum.AutomaticSize.X
	tooltipFrame.ZIndex = 250
	tooltipFrame.Visible = false
	tooltipFrame.Parent = screenGui
	corner(tooltipFrame, 8)
	strokeInst(tooltipFrame, C.Border, 1, 0.4)
	addClayShadow(tooltipFrame, 8)

	local tooltipLabel = Instance.new("TextLabel")
	noHit(tooltipLabel)
	tooltipLabel.BackgroundTransparency = 1
	tooltipLabel.Size = UDim2.new(0, 0, 1, 0)
	tooltipLabel.AutomaticSize = Enum.AutomaticSize.X
	tooltipLabel.Font = Enum.Font.GothamMedium
	tooltipLabel.TextSize = math.floor(11 * SC)
	tooltipLabel.TextColor3 = C.Text
	tooltipLabel.TextTransparency = 0.1
	tooltipLabel.ZIndex = 251
	tooltipLabel.Parent = tooltipFrame
	pad(tooltipLabel, 4, 4, 10, 10)

	local tooltipVisible = false
	local tooltipTarget = nil
	local tooltipDelay = 0.6
	local tooltipTimer = 0

	function W:ShowTooltip(text, frame)
		tooltipLabel.Text = text
		tooltipTarget = frame
		tooltipVisible = true
		tooltipFrame.Visible = true
		tooltipFrame.GroupTransparency = 1
		tw(tooltipFrame, 0.2, {GroupTransparency = 0}, Enum.EasingStyle.Quart)
	end

	function W:HideTooltip()
		tooltipVisible = false
		tw(tooltipFrame, 0.15, {GroupTransparency = 1}, Enum.EasingStyle.Quart)
		task.delay(0.15, function()
			if not tooltipVisible then
				tooltipFrame.Visible = false
			end
		end)
	end

	poolAdd(function(dt)
		if not tooltipFrame or not tooltipFrame.Parent then return false end
		if tooltipVisible and tooltipFrame.Visible then
			local mousePos = UserInputService:GetMouseLocation()
			tooltipFrame.Position = UDim2.new(0, mousePos.X + 12, 0, mousePos.Y - 32)
		end
		return true
	end)

	local miniMode = false
	local miniFrame = Instance.new("CanvasGroup")
	noHit(miniFrame)
	miniFrame.AnchorPoint = Vector2.new(0.5, 0)
	miniFrame.BackgroundColor3 = C.BG
	miniFrame.BackgroundTransparency = 0.1
	miniFrame.Position = UDim2.new(0.5, 0, 0, 16)
	miniFrame.Size = UDim2.new(0, math.floor(160 * SC), 0, math.floor(36 * SC))
	miniFrame.ZIndex = 60
	miniFrame.Visible = false
	miniFrame.Parent = screenGui
	corner(miniFrame, 10)
	strokeInst(miniFrame, C.Border, 1, 0.5)

	local miniAccent = Instance.new("Frame")
	noHit(miniAccent)
	miniAccent.BackgroundColor3 = C.Accent
	miniAccent.BackgroundTransparency = 0.5
	miniAccent.Size = UDim2.new(1, 0, 0, 2)
	miniAccent.ZIndex = 61
	miniAccent.Parent = miniFrame
	corner(miniAccent, 12)

	local miniText = Instance.new("TextLabel")
	noHit(miniText)
	miniText.BackgroundTransparency = 1
	miniText.Position = UDim2.new(0, 12, 0, 0)
	miniText.Size = UDim2.new(1, -48, 1, 0)
	miniText.Font = Enum.Font.GothamBold
	miniText.TextSize = math.floor(12 * SC)
	miniText.Text = title
	miniText.TextColor3 = C.Accent
	miniText.TextXAlignment = Enum.TextXAlignment.Left
	miniText.ZIndex = 62
	miniText.Parent = miniFrame

	local miniExpandBtn = Instance.new("TextButton")
	miniExpandBtn.AnchorPoint = Vector2.new(1, 0.5)
	miniExpandBtn.BackgroundColor3 = C.Surface
	miniExpandBtn.Position = UDim2.new(1, -8, 0.5, 0)
	miniExpandBtn.Size = UDim2.new(0, math.floor(28 * SC), 0, math.floor(22 * SC))
	miniExpandBtn.Text = "+"
	miniExpandBtn.Font = Enum.Font.GothamBold
	miniExpandBtn.TextSize = math.floor(10 * SC)
	miniExpandBtn.TextColor3 = C.Text
	miniExpandBtn.AutoButtonColor = false
	miniExpandBtn.ZIndex = 63
	miniExpandBtn.Parent = miniFrame
	corner(miniExpandBtn, 6)

	miniExpandBtn.MouseButton1Click:Connect(function()
		if miniMode then
			W:ExitMiniMode()
		end
	end)

	makeDrag(miniFrame, miniFrame)

	local miniCountDot = Instance.new("Frame")
	noHit(miniCountDot)
	miniCountDot.AnchorPoint = Vector2.new(0, 0.5)
	miniCountDot.BackgroundColor3 = C.Ok
	miniCountDot.Position = UDim2.new(0, math.floor(130 * SC), 0.5, 0)
	miniCountDot.Size = UDim2.new(0, math.floor(8 * SC), 0, math.floor(8 * SC))
	miniCountDot.ZIndex = 62
	miniCountDot.Visible = false
	miniCountDot.Parent = miniFrame
	corner(miniCountDot, 99)

	local _miniAccum = 0
	poolAdd(function(dt)
		if not miniCountDot or not miniCountDot.Parent then return false end
		if not miniMode then return true end
		_miniAccum = _miniAccum + dt
		if _miniAccum < 0.5 then return true end
		_miniAccum = 0
		local count = 0
		for _, v in pairs(W._activeFeatures) do
			if v then count = count + 1 end
		end
		miniCountDot.Visible = count > 0
	end)

	function W:EnterMiniMode()
		miniMode = true
		playSound(Sounds.collapse, 0.08, 1.0)
		hideBlur()
		tw(main, 0.3, {GroupTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.3, function()
			main.Visible = false
		end)
		miniFrame.Visible = true
		miniFrame.GroupTransparency = 1
		tw(miniFrame, 0.3, {GroupTransparency = 0}, Enum.EasingStyle.Quart)
	end

	function W:ExitMiniMode()
		miniMode = false
		playSound(Sounds.expand, 0.08, 1.0)
		if blurEnabled then showBlur() end
		tw(miniFrame, 0.2, {GroupTransparency = 1}, Enum.EasingStyle.Quint)
		task.delay(0.2, function()
			miniFrame.Visible = false
		end)
		main.Visible = true
		main.GroupTransparency = 1
		tw(main, 0.35, {GroupTransparency = 0}, Enum.EasingStyle.Quart)
	end

	function W:ToggleMiniMode()
		if miniMode then W:ExitMiniMode() else W:EnterMiniMode() end
	end

	local playerHudFrame = Instance.new("Frame")
	noHit(playerHudFrame)
	playerHudFrame.AnchorPoint = Vector2.new(0, 1)
	playerHudFrame.BackgroundColor3 = C.BG
	playerHudFrame.BackgroundTransparency = 0.12
	playerHudFrame.Position = UDim2.new(0, 16, 1, -16)
	playerHudFrame.Size = UDim2.new(0, math.floor(180 * SC), 0, math.floor(75 * SC))
	playerHudFrame.ZIndex = 55
	playerHudFrame.Visible = false
	playerHudFrame.Parent = screenGui
	corner(playerHudFrame, 10)
	strokeInst(playerHudFrame, C.Border, 1, 0.5)

	local hudAccent = Instance.new("Frame")
	noHit(hudAccent)
	hudAccent.BackgroundColor3 = C.Accent
	hudAccent.BackgroundTransparency = 0.6
	hudAccent.Size = UDim2.new(1, 0, 0, 2)
	hudAccent.ZIndex = 56
	hudAccent.Parent = playerHudFrame
	corner(hudAccent, 14)

	local hudName = Instance.new("TextLabel")
	noHit(hudName)
	hudName.BackgroundTransparency = 1
	hudName.Position = UDim2.new(0, 14, 0, 8)
	hudName.Size = UDim2.new(1, -28, 0, math.floor(18 * SC))
	hudName.Font = Enum.Font.GothamBold
	hudName.TextSize = math.floor(13 * SC)
	hudName.Text = "Player"
	hudName.TextColor3 = C.Text
	hudName.TextXAlignment = Enum.TextXAlignment.Left
	hudName.ZIndex = 56
	hudName.Parent = playerHudFrame

	local hudHealthBG = Instance.new("Frame")
	noHit(hudHealthBG)
	hudHealthBG.BackgroundColor3 = C.Surface
	hudHealthBG.Position = UDim2.new(0, 14, 0, math.floor(30 * SC))
	hudHealthBG.Size = UDim2.new(1, -28, 0, math.floor(8 * SC))
	hudHealthBG.ZIndex = 56
	hudHealthBG.Parent = playerHudFrame
	corner(hudHealthBG, 4)

	local hudHealthFill = Instance.new("Frame")
	noHit(hudHealthFill)
	hudHealthFill.BackgroundColor3 = C.Ok
	hudHealthFill.Size = UDim2.new(1, 0, 1, 0)
	hudHealthFill.ZIndex = 57
	hudHealthFill.Parent = hudHealthBG
	corner(hudHealthFill, 4)

	local hudHealthText = Instance.new("TextLabel")
	noHit(hudHealthText)
	hudHealthText.BackgroundTransparency = 1
	hudHealthText.Position = UDim2.new(0, 14, 0, math.floor(42 * SC))
	hudHealthText.Size = UDim2.new(1, -28, 0, math.floor(14 * SC))
	hudHealthText.Font = Enum.Font.GothamMedium
	hudHealthText.TextSize = math.floor(10 * SC)
	hudHealthText.Text = "HP: 100/100"
	hudHealthText.TextColor3 = C.Sub
	hudHealthText.TextXAlignment = Enum.TextXAlignment.Left
	hudHealthText.ZIndex = 56
	hudHealthText.Parent = playerHudFrame

	local hudPosText = Instance.new("TextLabel")
	noHit(hudPosText)
	hudPosText.BackgroundTransparency = 1
	hudPosText.Position = UDim2.new(0, 14, 0, math.floor(58 * SC))
	hudPosText.Size = UDim2.new(1, -28, 0, math.floor(14 * SC))
	hudPosText.Font = Enum.Font.GothamMedium
	hudPosText.TextSize = math.floor(10 * SC)
	hudPosText.Text = "Pos: 0, 0, 0"
	hudPosText.TextColor3 = C.Sub
	hudPosText.TextXAlignment = Enum.TextXAlignment.Left
	hudPosText.ZIndex = 56
	hudPosText.Parent = playerHudFrame

	local hudSpeedText = Instance.new("TextLabel")
	noHit(hudSpeedText)
	hudSpeedText.BackgroundTransparency = 1
	hudSpeedText.Position = UDim2.new(0, 14, 0, math.floor(72 * SC))
	hudSpeedText.Size = UDim2.new(1, -28, 0, math.floor(14 * SC))
	hudSpeedText.Font = Enum.Font.GothamMedium
	hudSpeedText.TextSize = math.floor(10 * SC)
	hudSpeedText.Text = "Speed: 16"
	hudSpeedText.TextColor3 = C.Sub
	hudSpeedText.TextXAlignment = Enum.TextXAlignment.Left
	hudSpeedText.ZIndex = 56
	hudSpeedText.Parent = playerHudFrame

	local _hudAccum = 0
	poolAdd(function(dt)
		if not playerHudFrame or not playerHudFrame.Parent then return false end
		if not playerHudFrame.Visible then return true end
		_hudAccum = _hudAccum + dt
		if _hudAccum < 0.15 then return true end
		_hudAccum = 0

		pcall(function()
			local char = Player.Character
			if char then
				local humanoid = char:FindFirstChildOfClass("Humanoid")
				if humanoid then
					local hp = math.floor(humanoid.Health)
					local maxHp = math.floor(humanoid.MaxHealth)
					local ratio = math.clamp(hp / maxHp, 0, 1)
					hudHealthText.Text = "HP: " .. hp .. "/" .. maxHp
					hudHealthFill.Size = UDim2.new(ratio, 0, 1, 0)

					if ratio > 0.6 then
						hudHealthFill.BackgroundColor3 = C.Ok
					elseif ratio > 0.3 then
						hudHealthFill.BackgroundColor3 = C.Warn
					else
						hudHealthFill.BackgroundColor3 = C.Err
					end

					hudSpeedText.Text = "Speed: " .. math.floor(humanoid.WalkSpeed)
				end

				local rootPart = char:FindFirstChild("HumanoidRootPart")
				if rootPart then
					local pos = rootPart.Position
					hudPosText.Text = "Pos: " .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z)
				end
			end

			hudName.Text = Player.DisplayName
		end)

		return true
	end)

	function W:SetPlayerHudVisible(vis)
		playerHudFrame.Visible = vis
	end

	W._quickActions = {}

	local quickBarFrame = Instance.new("Frame")
	noHit(quickBarFrame)
	quickBarFrame.AnchorPoint = Vector2.new(0.5, 1)
	quickBarFrame.BackgroundColor3 = C.BG
	quickBarFrame.BackgroundTransparency = 0.1
	quickBarFrame.Position = UDim2.new(0.5, 0, 1, -16)
	quickBarFrame.Size = UDim2.new(0, 0, 0, math.floor(36 * SC))
	quickBarFrame.AutomaticSize = Enum.AutomaticSize.X
	local qbSizeC = Instance.new("UISizeConstraint")
	qbSizeC.MaxSize = Vector2.new(math.floor(500 * SC), math.floor(36 * SC))
	qbSizeC.Parent = quickBarFrame
	quickBarFrame.ZIndex = 55
	quickBarFrame.Visible = false
	quickBarFrame.Parent = screenGui
	corner(quickBarFrame, 10)
	strokeInst(quickBarFrame, C.Border, 1, 0.5)
	pad(quickBarFrame, 6, 6, 8, 8)
	uiList(quickBarFrame, 6, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center)

	function W:AddQuickAction(cfg)
		cfg = cfg or {}
		local btn = Instance.new("TextButton")
		btn.BackgroundColor3 = C.Surface
		btn.BackgroundTransparency = 0.2
		btn.Size = UDim2.new(0, math.floor(34 * SC), 0, math.floor(28 * SC))
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.ZIndex = 57
		btn.LayoutOrder = #W._quickActions + 1
		btn.Parent = quickBarFrame
		corner(btn, 8)

		local iconAsset = cfg.Icon and getIconAsset(cfg.Icon)
		if iconAsset then
			local ico = Instance.new("ImageLabel")
			noHit(ico)
			ico.BackgroundTransparency = 1
			ico.AnchorPoint = Vector2.new(0.5, 0.5)
			ico.Position = UDim2.new(0.5, 0, 0.5, 0)
			ico.Size = UDim2.new(0, math.floor(16 * SC), 0, math.floor(16 * SC))
			ico.Image = iconAsset
			ico.ImageColor3 = C.Accent
			ico.ScaleType = Enum.ScaleType.Fit
			ico.ZIndex = 58
			ico.Parent = btn
		else
			btn.Text = cfg.Label or "?"
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = math.floor(14 * SC)
			btn.TextColor3 = C.Accent
		end

		addHoverLift(btn, 2)

		btn.MouseButton1Click:Connect(function()
			playSound(Sounds.click, 0.08, 1.0)
			createRipple(btn, C.Accent)
			if cfg.Callback then
				task.spawn(cfg.Callback)
			end
		end)

		W._quickActions[#W._quickActions + 1] = btn
		quickBarFrame.Visible = #W._quickActions > 0
		return btn
	end

	function W:SetQuickBarVisible(vis)
		quickBarFrame.Visible = vis and #W._quickActions > 0
	end

	local changelogFrame = Instance.new("CanvasGroup")
	noHit(changelogFrame)
	changelogFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	changelogFrame.BackgroundColor3 = C.BGAlt
	changelogFrame.BackgroundTransparency = 0.03
	changelogFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	changelogFrame.Size = UDim2.new(0, math.floor(380 * SC), 0, math.floor(450 * SC))
	changelogFrame.ZIndex = 95
	changelogFrame.Visible = false
	changelogFrame.Parent = screenGui
	corner(changelogFrame, 18)
	strokeInst(changelogFrame, C.Border, 1, 0.3)
	addClayShadow(changelogFrame, 18)

	local clHeader = Instance.new("TextLabel")
	noHit(clHeader)
	clHeader.BackgroundTransparency = 1
	clHeader.Size = UDim2.new(1, 0, 0, math.floor(44 * SC))
	clHeader.Font = Enum.Font.GothamBold
	clHeader.TextSize = math.floor(16 * SC)
	clHeader.Text = "Changelog"
	clHeader.TextColor3 = C.Accent
	clHeader.ZIndex = 96
	clHeader.Parent = changelogFrame

	local clClose = Instance.new("TextButton")
	clClose.AnchorPoint = Vector2.new(1, 0)
	clClose.BackgroundTransparency = 1
	clClose.Position = UDim2.new(1, -10, 0, 8)
	clClose.Size = UDim2.new(0, math.floor(28 * SC), 0, math.floor(28 * SC))
	clClose.Text = "X"
	clClose.Font = Enum.Font.GothamBold
	clClose.TextSize = math.floor(16 * SC)
	clClose.TextColor3 = C.Sub
	clClose.AutoButtonColor = false
	clClose.ZIndex = 97
	clClose.Parent = changelogFrame
	clClose.MouseButton1Click:Connect(function()
		playSound(Sounds.collapse, 0.06, 1.2)
		tw(changelogFrame, 0.25, {GroupTransparency = 1}, Enum.EasingStyle.Quint)
		task.delay(0.25, function()
			changelogFrame.Visible = false
			changelogFrame.GroupTransparency = 0
		end)
	end)

	local clSep = Instance.new("Frame")
	noHit(clSep)
	clSep.BackgroundColor3 = C.Border
	clSep.BackgroundTransparency = 0.5
	clSep.Size = UDim2.new(1, -24, 0, 1)
	clSep.Position = UDim2.new(0, 12, 0, math.floor(44 * SC))
	clSep.ZIndex = 96
	clSep.Parent = changelogFrame

	local clScroll = Instance.new("ScrollingFrame")
	noHit(clScroll)
	clScroll.BackgroundTransparency = 1
	clScroll.Position = UDim2.new(0, 0, 0, math.floor(50 * SC))
	clScroll.Size = UDim2.new(1, 0, 1, -math.floor(50 * SC))
	clScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	clScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	clScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	clScroll.ScrollBarThickness = 3
	clScroll.ScrollBarImageColor3 = C.Accent
	clScroll.ScrollBarImageTransparency = 0.5
	clScroll.ZIndex = 96
	clScroll.Parent = changelogFrame
	pad(clScroll, 8, 8, 16, 16)
	uiList(clScroll, 8, Enum.FillDirection.Vertical)

	function W:ShowChangelog(entries)
		entries = entries or {}
		for _, c in pairs(clScroll:GetChildren()) do
			if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
		end

		for i, entry in ipairs(entries) do
			local versionFrame = Instance.new("Frame")
			noHit(versionFrame)
			versionFrame.BackgroundColor3 = C.AccentSub
			versionFrame.BackgroundTransparency = 0.5
			versionFrame.Size = UDim2.new(1, 0, 0, math.floor(28 * SC))
			versionFrame.LayoutOrder = i * 10
			versionFrame.ZIndex = 97
			versionFrame.Parent = clScroll
			corner(versionFrame, 8)

			local versionLabel = Instance.new("TextLabel")
			noHit(versionLabel)
			versionLabel.BackgroundTransparency = 1
			versionLabel.Position = UDim2.new(0, 10, 0, 0)
			versionLabel.Size = UDim2.new(0.5, 0, 1, 0)
			versionLabel.Font = Enum.Font.GothamBold
			versionLabel.TextSize = math.floor(12 * SC)
			versionLabel.Text = entry.Version or ""
			versionLabel.TextColor3 = C.Accent
			versionLabel.TextXAlignment = Enum.TextXAlignment.Left
			versionLabel.ZIndex = 98
			versionLabel.Parent = versionFrame

			local dateLabel = Instance.new("TextLabel")
			noHit(dateLabel)
			dateLabel.BackgroundTransparency = 1
			dateLabel.AnchorPoint = Vector2.new(1, 0)
			dateLabel.Position = UDim2.new(1, -10, 0, 0)
			dateLabel.Size = UDim2.new(0.4, 0, 1, 0)
			dateLabel.Font = Enum.Font.GothamMedium
			dateLabel.TextSize = math.floor(10 * SC)
			dateLabel.Text = entry.Date or ""
			dateLabel.TextColor3 = C.Sub
			dateLabel.TextXAlignment = Enum.TextXAlignment.Right
			dateLabel.ZIndex = 98
			dateLabel.Parent = versionFrame

			local changes = entry.Changes or {}
			for j, change in ipairs(changes) do
				local changeLabel = Instance.new("TextLabel")
				noHit(changeLabel)
				changeLabel.BackgroundTransparency = 1
				changeLabel.Size = UDim2.new(1, 0, 0, 0)
				changeLabel.AutomaticSize = Enum.AutomaticSize.Y
				changeLabel.Font = Enum.Font.GothamMedium
				changeLabel.TextSize = math.floor(11 * SC)
				changeLabel.Text = "  " .. change
				changeLabel.TextColor3 = C.Text
				changeLabel.TextTransparency = 0.15
				changeLabel.TextXAlignment = Enum.TextXAlignment.Left
				changeLabel.TextWrapped = true
				changeLabel.LayoutOrder = i * 10 + j
				changeLabel.ZIndex = 97
				changeLabel.Parent = clScroll
			end
		end

		changelogFrame.Visible = true
		changelogFrame.GroupTransparency = 1
		playSound(Sounds.expand, 0.08, 1.0)
		tw(changelogFrame, 0.3, {GroupTransparency = 0}, Enum.EasingStyle.Quart)
	end

	local sessionStartTime = tick()
	W._sessionStart = sessionStartTime

	function W:GetSessionTime()
		local elapsed = tick() - sessionStartTime
		local hours = math.floor(elapsed / 3600)
		local minutes = math.floor((elapsed % 3600) / 60)
		local seconds = math.floor(elapsed % 60)
		if hours > 0 then
			return string.format("%dh %dm %ds", hours, minutes, seconds)
		elseif minutes > 0 then
			return string.format("%dm %ds", minutes, seconds)
		else
			return string.format("%ds", seconds)
		end
	end

	W._notifHistory = {}
	local MAX_NOTIF_HISTORY = 50

	local origNotify = W.Notify
	function W:Notify(nc)
		W._notifHistory[#W._notifHistory + 1] = {
			Title = nc.Title or "",
			Content = nc.Content or "",
			Type = nc.Type or "Info",
			Time = os.date("%H:%M:%S"),
		}
		while #W._notifHistory > MAX_NOTIF_HISTORY do
			table.remove(W._notifHistory, 1)
		end
		return origNotify(self, nc)
	end

	function W:GetNotifHistory()
		return W._notifHistory
	end

	local notifHistoryFrame = Instance.new("CanvasGroup")
	noHit(notifHistoryFrame)
	notifHistoryFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	notifHistoryFrame.BackgroundColor3 = C.BGAlt
	notifHistoryFrame.BackgroundTransparency = 0.03
	notifHistoryFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	notifHistoryFrame.Size = UDim2.new(0, math.floor(340 * SC), 0, math.floor(400 * SC))
	notifHistoryFrame.ZIndex = 95
	notifHistoryFrame.Visible = false
	notifHistoryFrame.Parent = screenGui
	corner(notifHistoryFrame, 18)
	strokeInst(notifHistoryFrame, C.Border, 1, 0.3)
	addClayShadow(notifHistoryFrame, 18)

	local nhHeader = Instance.new("TextLabel")
	noHit(nhHeader)
	nhHeader.BackgroundTransparency = 1
	nhHeader.Size = UDim2.new(1, 0, 0, math.floor(42 * SC))
	nhHeader.Font = Enum.Font.GothamBold
	nhHeader.TextSize = math.floor(15 * SC)
	nhHeader.Text = "Notification History"
	nhHeader.TextColor3 = C.Accent
	nhHeader.ZIndex = 96
	nhHeader.Parent = notifHistoryFrame

	local nhClose = Instance.new("TextButton")
	nhClose.AnchorPoint = Vector2.new(1, 0)
	nhClose.BackgroundTransparency = 1
	nhClose.Position = UDim2.new(1, -10, 0, 8)
	nhClose.Size = UDim2.new(0, math.floor(28 * SC), 0, math.floor(28 * SC))
	nhClose.Text = "X"
	nhClose.Font = Enum.Font.GothamBold
	nhClose.TextSize = math.floor(16 * SC)
	nhClose.TextColor3 = C.Sub
	nhClose.AutoButtonColor = false
	nhClose.ZIndex = 97
	nhClose.Parent = notifHistoryFrame
	nhClose.MouseButton1Click:Connect(function()
		playSound(Sounds.collapse, 0.06, 1.2)
		tw(notifHistoryFrame, 0.25, {GroupTransparency = 1}, Enum.EasingStyle.Quint)
		task.delay(0.25, function()
			notifHistoryFrame.Visible = false
			notifHistoryFrame.GroupTransparency = 0
		end)
	end)

	local nhScroll = Instance.new("ScrollingFrame")
	noHit(nhScroll)
	nhScroll.BackgroundTransparency = 1
	nhScroll.Position = UDim2.new(0, 0, 0, math.floor(48 * SC))
	nhScroll.Size = UDim2.new(1, 0, 1, -math.floor(48 * SC))
	nhScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	nhScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	nhScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	nhScroll.ScrollBarThickness = 3
	nhScroll.ScrollBarImageColor3 = C.Accent
	nhScroll.ScrollBarImageTransparency = 0.5
	nhScroll.ZIndex = 96
	nhScroll.Parent = notifHistoryFrame
	pad(nhScroll, 4, 8, 12, 12)
	uiList(nhScroll, 4, Enum.FillDirection.Vertical)

	function W:ShowNotifHistory()
		for _, c in pairs(nhScroll:GetChildren()) do
			if c:IsA("Frame") then c:Destroy() end
		end

		local typeColors = {
			Success = C.Ok,
			Warning = C.Warn,
			Error = C.Err,
			Info = C.Info,
		}

		local history = W._notifHistory
		for i = #history, 1, -1 do
			local entry = history[i]
			local row = Instance.new("Frame")
			noHit(row)
			row.BackgroundColor3 = C.Surface
			row.BackgroundTransparency = 0.4
			row.Size = UDim2.new(1, 0, 0, math.floor(42 * SC))
			row.LayoutOrder = #history - i + 1
			row.ZIndex = 97
			row.Parent = nhScroll
			corner(row, 8)

			local typeStripe = Instance.new("Frame")
			noHit(typeStripe)
			typeStripe.BackgroundColor3 = typeColors[entry.Type] or C.Info
			typeStripe.Position = UDim2.new(0, 0, 0, 0)
			typeStripe.Size = UDim2.new(1, 0, 0, 2)
			typeStripe.ZIndex = 98
			typeStripe.Parent = row
			corner(typeStripe, 8)

			local timeL = Instance.new("TextLabel")
			noHit(timeL)
			timeL.BackgroundTransparency = 1
			timeL.AnchorPoint = Vector2.new(1, 0)
			timeL.Position = UDim2.new(1, -8, 0, 4)
			timeL.Size = UDim2.new(0, 50, 0, 14)
			timeL.Font = Enum.Font.Code
			timeL.TextSize = math.floor(9 * SC)
			timeL.Text = entry.Time
			timeL.TextColor3 = C.Dim
			timeL.TextXAlignment = Enum.TextXAlignment.Right
			timeL.ZIndex = 98
			timeL.Parent = row

			local titleL = Instance.new("TextLabel")
			noHit(titleL)
			titleL.BackgroundTransparency = 1
			titleL.Position = UDim2.new(0, 12, 0, 4)
			titleL.Size = UDim2.new(0.7, 0, 0, 16)
			titleL.Font = Enum.Font.GothamBold
			titleL.TextSize = math.floor(11 * SC)
			titleL.Text = entry.Title
			titleL.TextColor3 = typeColors[entry.Type] or C.Text
			titleL.TextXAlignment = Enum.TextXAlignment.Left
			titleL.TextTruncate = Enum.TextTruncate.AtEnd
			titleL.ZIndex = 98
			titleL.Parent = row

			local contentL = Instance.new("TextLabel")
			noHit(contentL)
			contentL.BackgroundTransparency = 1
			contentL.Position = UDim2.new(0, 12, 0, 22)
			contentL.Size = UDim2.new(1, -24, 0, 16)
			contentL.Font = Enum.Font.GothamMedium
			contentL.TextSize = math.floor(10 * SC)
			contentL.Text = entry.Content
			contentL.TextColor3 = C.Sub
			contentL.TextXAlignment = Enum.TextXAlignment.Left
			contentL.TextTruncate = Enum.TextTruncate.AtEnd
			contentL.ZIndex = 98
			contentL.Parent = row
		end

		notifHistoryFrame.Visible = true
		notifHistoryFrame.GroupTransparency = 1
		playSound(Sounds.expand, 0.08, 1.0)
		tw(notifHistoryFrame, 0.3, {GroupTransparency = 0}, Enum.EasingStyle.Quart)
	end

	W._elementStats = {
		Toggle = 0, Slider = 0, Dropdown = 0,
		Button = 0, Input = 0, Keybind = 0,
		ColorPicker = 0, Label = 0, Paragraph = 0,
		Separator = 0, Tab = 0, SubTab = 0, Group = 0,
	}

	function W:GetStats()
		local total = 0
		for _, v in pairs(W._elementStats) do
			total = total + v
		end
		return {
			Elements = total,
			Tabs = W._elementStats.Tab,
			SubTabs = W._elementStats.SubTab,
			Groups = W._elementStats.Group,
			ActiveFeatures = (function()
				local c = 0
				for _, v in pairs(W._activeFeatures) do
					if v then c = c + 1 end
				end
				return c
			end)(),
			Session = W:GetSessionTime(),
			NotifCount = #W._notifHistory,
		}
	end

	W._accentOverrides = {}

	function W:SetGlobalAccent(color)
		C.Accent = color
		C.AccentLit = Color3.new(
			math.min(color.R + 0.08, 1),
			math.min(color.G + 0.08, 1),
			math.min(color.B + 0.08, 1)
		)
		if false then
			local accentGrad = nil
			accentGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color),
				ColorSequenceKeypoint.new(0.5, C.ElecBlue),
				ColorSequenceKeypoint.new(1, C.Lilac),
			})
		end
	end

	local fpsGraphFrame = Instance.new("Frame")
	noHit(fpsGraphFrame)
	fpsGraphFrame.AnchorPoint = Vector2.new(0, 0)
	fpsGraphFrame.BackgroundColor3 = C.BGAlt
	fpsGraphFrame.BackgroundTransparency = 0.1
	fpsGraphFrame.Position = UDim2.new(0, 16, 0, math.floor(52 * SC))
	fpsGraphFrame.Size = UDim2.new(0, math.floor(120 * SC), 0, math.floor(30 * SC))
	fpsGraphFrame.ZIndex = 55
	fpsGraphFrame.Visible = false
	fpsGraphFrame.ClipsDescendants = true
	fpsGraphFrame.Parent = screenGui
	corner(fpsGraphFrame, 8)
	strokeInst(fpsGraphFrame, C.Border, 1, 0.5)

	local fpsGraphBars = {}
	local FPS_GRAPH_BARS = 30
	local fpsHistory = {}
	for i = 1, FPS_GRAPH_BARS do
		fpsHistory[i] = 60
		local bar = Instance.new("Frame")
		noHit(bar)
		bar.BackgroundColor3 = C.Ok
		bar.BackgroundTransparency = 0.3
		bar.AnchorPoint = Vector2.new(0, 1)
		bar.Position = UDim2.new((i - 1) / FPS_GRAPH_BARS, 0, 1, -2)
		bar.Size = UDim2.new(1 / FPS_GRAPH_BARS, -1, 0.5, 0)
		bar.ZIndex = 56
		bar.Parent = fpsGraphFrame
		fpsGraphBars[i] = bar
	end

	local fpsGraphLabel = Instance.new("TextLabel")
	noHit(fpsGraphLabel)
	fpsGraphLabel.BackgroundTransparency = 1
	fpsGraphLabel.Position = UDim2.new(0, 4, 0, 1)
	fpsGraphLabel.Size = UDim2.new(1, -8, 0, 12)
	fpsGraphLabel.Font = Enum.Font.Code
	fpsGraphLabel.TextSize = math.floor(8 * SC)
	fpsGraphLabel.Text = "FPS"
	fpsGraphLabel.TextColor3 = C.Sub
	fpsGraphLabel.TextXAlignment = Enum.TextXAlignment.Left
	fpsGraphLabel.ZIndex = 57
	fpsGraphLabel.Parent = fpsGraphFrame

	local fpsGraphCounter = 0
	poolAdd(function(dt)
		if not fpsGraphFrame or not fpsGraphFrame.Parent then return false end
		if not fpsGraphFrame.Visible then return true end
		fpsGraphCounter = fpsGraphCounter + dt
		if fpsGraphCounter < 0.25 then return true end
		fpsGraphCounter = 0

		local fps = math.floor(1 / math.max(dt, 0.001))
		table.remove(fpsHistory, 1)
		fpsHistory[FPS_GRAPH_BARS] = fps

		local maxFPS = 1
		for _, v in ipairs(fpsHistory) do
			if v > maxFPS then maxFPS = v end
		end

		for i, bar in ipairs(fpsGraphBars) do
			local ratio = math.clamp(fpsHistory[i] / maxFPS, 0.02, 1)
			bar.Size = UDim2.new(1 / FPS_GRAPH_BARS, -1, ratio * 0.85, 0)
			if fpsHistory[i] >= 50 then
				bar.BackgroundColor3 = C.Ok
			elseif fpsHistory[i] >= 30 then
				bar.BackgroundColor3 = C.Warn
			else
				bar.BackgroundColor3 = C.Err
			end
		end

		fpsGraphLabel.Text = "FPS " .. tostring(fps)
		return true
	end)

	function W:SetFpsGraphVisible(vis)
		fpsGraphFrame.Visible = vis
	end

	local crosshairFrame = Instance.new("Frame")
	noHit(crosshairFrame)
	crosshairFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	crosshairFrame.BackgroundTransparency = 1
	crosshairFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	crosshairFrame.Size = UDim2.new(0, math.floor(40 * SC), 0, math.floor(40 * SC))
	crosshairFrame.ZIndex = 50
	crosshairFrame.Visible = false
	crosshairFrame.Parent = screenGui

	local chSize = math.floor(12 * SC)
	local chThick = math.floor(2 * SC)
	local chGap = math.floor(4 * SC)
	local chColor = Color3.new(1, 1, 1)

	local chTop = Instance.new("Frame")
	noHit(chTop)
	chTop.AnchorPoint = Vector2.new(0.5, 1)
	chTop.BackgroundColor3 = chColor
	chTop.Position = UDim2.new(0.5, 0, 0.5, -chGap)
	chTop.Size = UDim2.new(0, chThick, 0, chSize)
	chTop.ZIndex = 51
	chTop.Parent = crosshairFrame

	local chBot = Instance.new("Frame")
	noHit(chBot)
	chBot.AnchorPoint = Vector2.new(0.5, 0)
	chBot.BackgroundColor3 = chColor
	chBot.Position = UDim2.new(0.5, 0, 0.5, chGap)
	chBot.Size = UDim2.new(0, chThick, 0, chSize)
	chBot.ZIndex = 51
	chBot.Parent = crosshairFrame

	local chLeft = Instance.new("Frame")
	noHit(chLeft)
	chLeft.AnchorPoint = Vector2.new(1, 0.5)
	chLeft.BackgroundColor3 = chColor
	chLeft.Position = UDim2.new(0.5, -chGap, 0.5, 0)
	chLeft.Size = UDim2.new(0, chSize, 0, chThick)
	chLeft.ZIndex = 51
	chLeft.Parent = crosshairFrame

	local chRight = Instance.new("Frame")
	noHit(chRight)
	chRight.AnchorPoint = Vector2.new(0, 0.5)
	chRight.BackgroundColor3 = chColor
	chRight.Position = UDim2.new(0.5, chGap, 0.5, 0)
	chRight.Size = UDim2.new(0, chSize, 0, chThick)
	chRight.ZIndex = 51
	chRight.Parent = crosshairFrame

	local chDot = Instance.new("Frame")
	noHit(chDot)
	chDot.AnchorPoint = Vector2.new(0.5, 0.5)
	chDot.BackgroundColor3 = chColor
	chDot.Position = UDim2.new(0.5, 0, 0.5, 0)
	chDot.Size = UDim2.new(0, chThick + 1, 0, chThick + 1)
	chDot.ZIndex = 52
	chDot.Parent = crosshairFrame
	corner(chDot, 99)

	function W:SetCrosshairVisible(vis)
		crosshairFrame.Visible = vis
	end

	function W:SetCrosshairColor(col)
		chColor = col
		chTop.BackgroundColor3 = col
		chBot.BackgroundColor3 = col
		chLeft.BackgroundColor3 = col
		chRight.BackgroundColor3 = col
		chDot.BackgroundColor3 = col
	end

	function W:SetCrosshairSize(size, gap, thickness)
		local sz = math.floor(size * SC)
		local gp = math.floor(gap * SC)
		local th = math.floor(thickness * SC)
		chTop.Size = UDim2.new(0, th, 0, sz)
		chTop.Position = UDim2.new(0.5, 0, 0.5, -gp)
		chBot.Size = UDim2.new(0, th, 0, sz)
		chBot.Position = UDim2.new(0.5, 0, 0.5, gp)
		chLeft.Size = UDim2.new(0, sz, 0, th)
		chLeft.Position = UDim2.new(0.5, -gp, 0.5, 0)
		chRight.Size = UDim2.new(0, sz, 0, th)
		chRight.Position = UDim2.new(0.5, gp, 0.5, 0)
		chDot.Size = UDim2.new(0, th + 1, 0, th + 1)
	end

	local perfFrame = Instance.new("Frame")
	noHit(perfFrame)
	perfFrame.AnchorPoint = Vector2.new(1, 1)
	perfFrame.BackgroundColor3 = C.BG
	perfFrame.BackgroundTransparency = 0.12
	perfFrame.Position = UDim2.new(1, -16, 1, -16)
	perfFrame.Size = UDim2.new(0, math.floor(160 * SC), 0, math.floor(65 * SC))
	perfFrame.ZIndex = 55
	perfFrame.Visible = false
	perfFrame.Parent = screenGui
	corner(perfFrame, 10)
	strokeInst(perfFrame, C.Border, 1, 0.5)

	local perfTitle = Instance.new("TextLabel")
	noHit(perfTitle)
	perfTitle.BackgroundTransparency = 1
	perfTitle.Position = UDim2.new(0, 10, 0, 4)
	perfTitle.Size = UDim2.new(1, -20, 0, 16)
	perfTitle.Font = Enum.Font.GothamBold
	perfTitle.TextSize = math.floor(10 * SC)
	perfTitle.Text = "Performance"
	perfTitle.TextColor3 = C.Accent
	perfTitle.TextXAlignment = Enum.TextXAlignment.Left
	perfTitle.ZIndex = 56
	perfTitle.Parent = perfFrame

	local perfMemory = Instance.new("TextLabel")
	noHit(perfMemory)
	perfMemory.BackgroundTransparency = 1
	perfMemory.Position = UDim2.new(0, 10, 0, 22)
	perfMemory.Size = UDim2.new(1, -20, 0, 14)
	perfMemory.Font = Enum.Font.Code
	perfMemory.TextSize = math.floor(10 * SC)
	perfMemory.Text = "Memory: 0 MB"
	perfMemory.TextColor3 = C.Sub
	perfMemory.TextXAlignment = Enum.TextXAlignment.Left
	perfMemory.ZIndex = 56
	perfMemory.Parent = perfFrame

	local perfHeartbeat = Instance.new("TextLabel")
	noHit(perfHeartbeat)
	perfHeartbeat.BackgroundTransparency = 1
	perfHeartbeat.Position = UDim2.new(0, 10, 0, 38)
	perfHeartbeat.Size = UDim2.new(1, -20, 0, 14)
	perfHeartbeat.Font = Enum.Font.Code
	perfHeartbeat.TextSize = math.floor(10 * SC)
	perfHeartbeat.Text = "Heartbeat: 0ms"
	perfHeartbeat.TextColor3 = C.Sub
	perfHeartbeat.TextXAlignment = Enum.TextXAlignment.Left
	perfHeartbeat.ZIndex = 56
	perfHeartbeat.Parent = perfFrame

	local perfInstances = Instance.new("TextLabel")
	noHit(perfInstances)
	perfInstances.BackgroundTransparency = 1
	perfInstances.Position = UDim2.new(0, 10, 0, 54)
	perfInstances.Size = UDim2.new(1, -20, 0, 14)
	perfInstances.Font = Enum.Font.Code
	perfInstances.TextSize = math.floor(10 * SC)
	perfInstances.Text = "Instances: 0"
	perfInstances.TextColor3 = C.Sub
	perfInstances.TextXAlignment = Enum.TextXAlignment.Left
	perfInstances.ZIndex = 56
	perfInstances.Parent = perfFrame

	local perfCounter = 0
	poolAdd(function(dt)
		if not perfFrame or not perfFrame.Parent then return false end
		if not perfFrame.Visible then return true end
		perfCounter = perfCounter + dt
		if perfCounter < 1 then return true end
		perfCounter = 0

		pcall(function()
			local mem = math.floor(collectgarbage("count") / 1024 * 10) / 10
			perfMemory.Text = "Memory: " .. tostring(mem) .. " MB"

			local hb = math.floor(dt * 1000 * 10) / 10
			perfHeartbeat.Text = "Heartbeat: " .. tostring(hb) .. "ms"

			local instCount = 0
			pcall(function()
				instCount = #screenGui:GetDescendants()
			end)
			perfInstances.Text = "Instances: " .. tostring(instCount)
		end)

		return true
	end)

	function W:SetPerfMonitorVisible(vis)
		perfFrame.Visible = vis
	end

	function W:GetIconAsset(name)
		return getIconAsset(name)
	end

	function W:HasIcon(name)
		return IconAssets[name] ~= nil
	end

	function W:ListIconCategories()
		return {"action", "navigation", "notification", "home", "hardware", "maps", "device", "alert", "toggle", "editor", "media", "image", "communication", "file", "social", "content", "places"}
	end

	function W:CreateIconImage(parent, iconName, size, color, zIdx)
		return createIconImage(parent, iconName, size, color, zIdx)
	end

	function W:GetIconCount()
		local count = 0
		for _ in pairs(IconAssets) do count = count + 1 end
		return count
	end

	function W:Confirm(opts)
		opts = opts or {}
		local confirmed = false
		local dialogDone = false

		local overlay = Instance.new("TextButton")
		overlay.BackgroundColor3 = Color3.new(0, 0, 0)
		overlay.BackgroundTransparency = 0.4
		overlay.Size = UDim2.new(1, 0, 1, 0)
		overlay.Text = ""
		overlay.ZIndex = 150
		overlay.AutoButtonColor = false
		overlay.Parent = screenGui

		local dialog = Instance.new("Frame")
		dialog.AnchorPoint = Vector2.new(0.5, 0.5)
		dialog.BackgroundColor3 = C.BGAlt
		dialog.BackgroundTransparency = 0.03
		dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
		dialog.Size = UDim2.new(0, math.floor(280 * SC), 0, 0)
		dialog.ZIndex = 151
		dialog.ClipsDescendants = true
		dialog.Parent = screenGui
		corner(dialog, 18)
		strokeInst(dialog, C.Border, 1, 0.3)
		addClayShadow(dialog, 18)

		local dTitle = Instance.new("TextLabel")
		noHit(dTitle)
		dTitle.BackgroundTransparency = 1
		dTitle.Size = UDim2.new(1, 0, 0, math.floor(36 * SC))
		dTitle.Font = Enum.Font.GothamBold
		dTitle.TextSize = math.floor(15 * SC)
		dTitle.Text = opts.Title or "Confirm"
		dTitle.TextColor3 = C.Text
		dTitle.ZIndex = 152
		dTitle.Parent = dialog

		local dMsg = Instance.new("TextLabel")
		noHit(dMsg)
		dMsg.BackgroundTransparency = 1
		dMsg.Position = UDim2.new(0, 16, 0, math.floor(36 * SC))
		dMsg.Size = UDim2.new(1, -32, 0, math.floor(40 * SC))
		dMsg.Font = Enum.Font.GothamMedium
		dMsg.TextSize = math.floor(12 * SC)
		dMsg.Text = opts.Message or "Are you sure?"
		dMsg.TextColor3 = C.Sub
		dMsg.TextWrapped = true
		dMsg.ZIndex = 152
		dMsg.Parent = dialog

		local btnRow = Instance.new("Frame")
		noHit(btnRow)
		btnRow.BackgroundTransparency = 1
		btnRow.Position = UDim2.new(0, 16, 0, math.floor(82 * SC))
		btnRow.Size = UDim2.new(1, -32, 0, math.floor(32 * SC))
		btnRow.ZIndex = 152
		btnRow.Parent = dialog
		uiList(btnRow, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center)

		local cancelBtn = Instance.new("TextButton")
		cancelBtn.BackgroundColor3 = C.Surface
		cancelBtn.Size = UDim2.new(0, math.floor(100 * SC), 0, math.floor(30 * SC))
		cancelBtn.Text = "Cancel"
		cancelBtn.Font = Enum.Font.GothamBold
		cancelBtn.TextSize = math.floor(12 * SC)
		cancelBtn.TextColor3 = C.Sub
		cancelBtn.AutoButtonColor = false
		cancelBtn.ZIndex = 153
		cancelBtn.Parent = btnRow
		corner(cancelBtn, 8)

		local confirmBtn = Instance.new("TextButton")
		confirmBtn.BackgroundColor3 = opts.Type == "danger" and C.Err or C.Ok
		confirmBtn.Size = UDim2.new(0, math.floor(100 * SC), 0, math.floor(30 * SC))
		confirmBtn.Text = opts.ConfirmText or "Confirm"
		confirmBtn.Font = Enum.Font.GothamBold
		confirmBtn.TextSize = math.floor(12 * SC)
		confirmBtn.TextColor3 = Color3.new(1, 1, 1)
		confirmBtn.AutoButtonColor = false
		confirmBtn.ZIndex = 153
		confirmBtn.Parent = btnRow
		corner(confirmBtn, 8)

		playSound(Sounds.expand, 0.08, 1.1)
		tw(dialog, 0.3, {Size = UDim2.new(0, math.floor(280 * SC), 0, math.floor(124 * SC))}, Enum.EasingStyle.Back)

		local function closeDialog(result)
			if dialogDone then return end
			dialogDone = true
			confirmed = result
			playSound(Sounds.collapse, 0.06, 1.2)
			tw(dialog, 0.2, {Size = UDim2.new(0, math.floor(280 * SC), 0, 0)}, Enum.EasingStyle.Quint)
			tw(overlay, 0.2, {BackgroundTransparency = 1})
			task.delay(0.25, function()
				overlay:Destroy()
				dialog:Destroy()
			end)
			if result and opts.OnConfirm then
				task.spawn(opts.OnConfirm)
			elseif not result and opts.OnCancel then
				task.spawn(opts.OnCancel)
			end
		end

		cancelBtn.MouseButton1Click:Connect(function() closeDialog(false) end)
		confirmBtn.MouseButton1Click:Connect(function() closeDialog(true) end)
		overlay.MouseButton1Click:Connect(function() closeDialog(false) end)
	end

	function W:ShowProgress(opts)
		opts = opts or {}
		local duration = opts.Duration or 3
		local text = opts.Text or "Loading..."

		local progFrame = Instance.new("Frame")
		noHit(progFrame)
		progFrame.AnchorPoint = Vector2.new(0.5, 0)
		progFrame.BackgroundColor3 = C.BGAlt
		progFrame.BackgroundTransparency = 0.05
		progFrame.Position = UDim2.new(0.5, 0, 0, 16)
		progFrame.Size = UDim2.new(0, math.floor(260 * SC), 0, math.floor(48 * SC))
		progFrame.ZIndex = 80
		progFrame.Parent = screenGui
		corner(progFrame, 12)
		strokeInst(progFrame, C.Border, 1, 0.4)
		addClayShadow(progFrame, 12)

		local progText = Instance.new("TextLabel")
		noHit(progText)
		progText.BackgroundTransparency = 1
		progText.Position = UDim2.new(0, 14, 0, 4)
		progText.Size = UDim2.new(1, -28, 0, 18)
		progText.Font = Enum.Font.GothamBold
		progText.TextSize = math.floor(11 * SC)
		progText.Text = text
		progText.TextColor3 = C.Text
		progText.TextXAlignment = Enum.TextXAlignment.Left
		progText.ZIndex = 81
		progText.Parent = progFrame

		local progBarBG = Instance.new("Frame")
		noHit(progBarBG)
		progBarBG.BackgroundColor3 = C.Surface
		progBarBG.Position = UDim2.new(0, 14, 0, 28)
		progBarBG.Size = UDim2.new(1, -28, 0, math.floor(8 * SC))
		progBarBG.ZIndex = 81
		progBarBG.Parent = progFrame
		corner(progBarBG, 4)

		local progBarFill = Instance.new("Frame")
		noHit(progBarFill)
		progBarFill.BackgroundColor3 = opts.Color or C.Accent
		progBarFill.Size = UDim2.new(0, 0, 1, 0)
		progBarFill.ZIndex = 82
		progBarFill.Parent = progBarBG
		corner(progBarFill, 4)

		local percentLabel = Instance.new("TextLabel")
		noHit(percentLabel)
		percentLabel.BackgroundTransparency = 1
		percentLabel.AnchorPoint = Vector2.new(1, 0)
		percentLabel.Position = UDim2.new(1, -14, 0, 4)
		percentLabel.Size = UDim2.new(0, 40, 0, 18)
		percentLabel.Font = Enum.Font.Code
		percentLabel.TextSize = math.floor(10 * SC)
		percentLabel.Text = "0%"
		percentLabel.TextColor3 = C.Sub
		percentLabel.TextXAlignment = Enum.TextXAlignment.Right
		percentLabel.ZIndex = 81
		percentLabel.Parent = progFrame

		tw(progBarFill, duration, {Size = UDim2.new(1, 0, 1, 0)}, Enum.EasingStyle.Linear)

		local startTime = tick()
		local progPoolId = poolAdd(function(dt)
			if not progFrame or not progFrame.Parent then return false end
			local elapsed = tick() - startTime
			local pct = math.clamp(elapsed / duration, 0, 1)
			percentLabel.Text = math.floor(pct * 100) .. "%"
			if pct >= 1 then
				return false
			end
			return true
		end)

		task.delay(duration + 0.5, function()
			if progFrame and progFrame.Parent then
				tw(progFrame, 0.25, {BackgroundTransparency = 1})
				task.delay(0.3, function()
					if progFrame and progFrame.Parent then progFrame:Destroy() end
				end)
			end
			if opts.OnComplete then task.spawn(opts.OnComplete) end
		end)

		return {
			SetText = function(_, t) progText.Text = t end,
			SetProgress = function(_, pct)
				progBarFill.Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0)
				percentLabel.Text = math.floor(pct * 100) .. "%"
			end,
			Dismiss = function()
				if progFrame and progFrame.Parent then
					progFrame:Destroy()
				end
			end,
		}
	end

	function W:SetTabBadge(tabName, count)
		if count and count > 0 then
			W._activeFeatures["[" .. tabName .. " Badge]"] = false
		end
		for tName, badge in pairs(W._tabBadges) do
			if tName == tabName then
				if count and count > 0 then
					badge.Visible = true
					badge._label.Text = tostring(count)
				else
					badge.Visible = false
				end
			end
		end
	end

	W._lastPosition = nil

	function W:SavePosition()
		if main then
			W._lastPosition = main.Position
		end
	end

	function W:RestorePosition()
		if W._lastPosition and main then
			main.Position = W._lastPosition
		end
	end

	function W:SetFlags(flagTable)
		for flag, value in pairs(flagTable) do
			local api = W._flags[flag]
			if api and api.Set then
				pcall(api.Set, api, value)
			end
		end
	end

	function W:GetFlags()
		local result = {}
		for flag, api in pairs(W._flags) do
			if api.Get then
				local ok, val = pcall(api.Get, api)
				if ok then result[flag] = val end
			end
		end
		return result
	end

	function W:ResetFlag(flag)
		local api = W._flags[flag]
		if api and api.Set then
			pcall(api.Set, api, false)
		end
	end

	function W:ResetAllFlags()
		for flag, api in pairs(W._flags) do
			if api.Set then
				pcall(api.Set, api, false)
			end
		end
	end

	W._scheduledTasks = {}

	function W:Schedule(name, delay, callback, repeating)
		if W._scheduledTasks[name] then
			W._scheduledTasks[name].cancelled = true
		end

		local taskInfo = {
			name = name,
			delay = delay,
			callback = callback,
			repeating = repeating or false,
			cancelled = false,
		}
		W._scheduledTasks[name] = taskInfo

		task.spawn(function()
			if repeating then
				while not taskInfo.cancelled do
					task.wait(delay)
					if not taskInfo.cancelled then
						pcall(callback)
					end
				end
			else
				task.wait(delay)
				if not taskInfo.cancelled then
					pcall(callback)
				end
			end
		end)

		return taskInfo
	end

	function W:CancelScheduled(name)
		if W._scheduledTasks[name] then
			W._scheduledTasks[name].cancelled = true
			W._scheduledTasks[name] = nil
		end
	end

	function W:CancelAllScheduled()
		for name, info in pairs(W._scheduledTasks) do
			info.cancelled = true
		end
		W._scheduledTasks = {}
	end

	pcall(function()
		if makefolder then
			local dirName = W.Config.HubName
			if isfolder and not isfolder(dirName) then
				makefolder(dirName)
			elseif not isfolder then
				makefolder(dirName)
			end
		end
	end)

	function W:FinishSetup()
		if not W.Config._loaded then
			pcall(function() W.Config:AutoLoad() end)
		end
		if not W.Config:GetAutoSaveStatus() then
			W.Config:EnableAutoSave(30)
		end
		W.AutoSaveEnabled = true
		if updateActivePanel then pcall(updateActivePanel) end

		task.defer(function()
			local autoMin = false
			pcall(function()
				local flag = W.Config.Flags["UIAutoMinimize"]
				if flag and flag.Get then autoMin = flag:Get() end
			end)
			if autoMin and not miniMode then
				W:EnterMiniMode()
			end
		end)
	end

	task.delay(3, function()
		if not W.Config._loaded then
			pcall(function() W:FinishSetup() end)
		end
	end)

	_G.__ExpensiveHub_Cleanup = function()
		for _, conn in pairs(W._conns) do
			pcall(function() conn:Disconnect() end)
		end
		pcall(function() hideBlur(); destroyBlur() end)
		pcall(function() screenGui:Destroy() end)
	end

	function W:SetAnimations(enabled)
		ANIM_ENABLED = enabled
		if not enabled then
			for k in pairs(Pool) do
				Pool[k] = nil
			end
			if bgMaster and bgMaster.Parent then
				for _, container in pairs(bgPresets) do
					container.Visible = false
				end
			end
		else
			if bgMaster and bgMaster.Parent then
				W:SetBackground(activeBG)
			end
		end
	end

	function W:GetAnimations()
		return ANIM_ENABLED
	end

	return W
end

return Library
