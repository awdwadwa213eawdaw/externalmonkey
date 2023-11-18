local assets = {}
local IdFolder = game:GetService("Workspace"):WaitForChild("Identification")
assets.musicId = {
	ContinueScreen = 13598604239,
}

-- Group Place / Animation / Dev Product / Game Pass / Badge IDs
assets.placeId = {
	Main = IdFolder:WaitForChild("GameId").Value,
	Battle = IdFolder:WaitForChild("BattleId").Value,
	Trade = IdFolder:WaitForChild("TradeId").Value,
}
assets.animationId = {

	--// R6
	absolIdle = 14083739799,
	absolRun = 14083740031,
	absolSniff = 14083740243,
	Carry = 14083740462,
	cmHats = 14083740666,
	cmJump = 14083740884,
	cypressWeee = 14083741128,
	dialgaHover = 14083741384,
	dialgaIdle = 14083741557,
	dialgaRoarAir = 14083741681,
	dialgaRoarGround = 14083741823,
	EatSushi = 14083741989,
	enteiRun = 14083742117,
	FlipSign = 14083742297,
	heatranIdle = 14083742479,
	heatranRoar = 14083742734,
	hoopaAttack = 14083742902,
	hoopaIdle = 14083743050,
	hoopaIdle2 = 14083743275,
	hoopaIdleSlow = 14083743455,
	h_backward = 14083743573,
	h_forward = 14083743691,
	h_hm = 14083743860,
	h_idle = 14083744057,
	h_left = 14083744248,
	h_right = 14083744435,
	h_trick1 = 14083744706,
	h_trick2 = 14083744899,
	h_trick3 = 14083745094,
	IntroSit = 14083745372,
	IntroSleep = 14083745579,
	JakeDive = 14083745793,
	jakeHold = 14083745950,
	jakeLift = 14083746132,
	JakePortal = 14083746319,
	jakeThrow = 14083746524,
	jhatAction = 14083746725,
	jhatIdle = 14083746976,
	NPCBreakDance = 14083747266,
	NPCDance1 = 14083747475,
	NPCDance2 = 14083747640,
	NPCDance3 = 14083747833,
	NPCIdle = 14083747976,
	NPCIdleSwim = 14083748258,
	NPCPoint = 14083748462,
	NPCSwim = 14083748625,
	NPCWalk = 14083748775,
	NPCWave = 14083748971,
	NurseBow = 14083749120,
	palkiaHover = 14083749328,
	palkiaIdle = 14083749567,
	palkiaRoarAir = 14083749795,
	palkiaRoarGround = 14083750077,
	profChange = 14083750224,
	profTurn = 14083750365,
	R15_Carry = 14083750619,
	R15_hm = 14083750902,
	R15_h_backward = 14083751107,
	R15_h_forward = 14083751293,
	R15_h_idle = 14083751435,
	R15_h_left = 14083751562,
	R15_h_right = 14083751745,
	R15_h_trick1 = 14083752001,
	R15_h_trick2 = 14083752158,
	R15_h_trick3 = 14083752344,
	R15_Idle = 14083752591,
	R15_IntroSleep = 14083752799,
	R15_IntroTossClock = 14083752981,
	R15_IntroWake = 14083753110,
	R15_RodCast = 14083753291,
	R15_RodIdle = 14083753541,
	R15_RodReel = 14083753920,
	R15_Run = 14083754224,
	R15_Sit = 14083754509,
	R15_Surf = 14083754789,
	R15_Sushi = 14083755106,
	R15_ThrowBall = 14083755311,
	R15_ZPower = 14083755596,
	raikouRun = 14083755799,
	RodCast = 14083756017,
	RodIdle = 14083756266,
	RodReel = 14083756573,
	Run = 14083756775,
	Sit = 14083756957,
	suicuneRun = 14083757212,
	Surf = 14083757396,
	TessFall = 14083757533,
	ThrowBall = 14083757686,
	ZPower = 14083757888,
}
local function getAnimationID(name)
	local idValue = IdFolder:FindFirstChild(name)
	if idValue and idValue:IsA("IntValue") then
		return idValue.Value
	else
		return 0
	end
end

for animName, _ in pairs(assets.animationId) do
	assets.animationId[animName] = getAnimationID(animName)
end
assets.productId = {
	Starter = 1684621983,               --// 15 R$
	TenBP = 1684621998,                 --// 10 R$
	FiftyBP = 1684622003,               --// 30 R$
	TwoHundredBP = 1684622011,         --// 75 R$
	TwoThousandBP = 1684622020,        --// 200 R$
	UMV1 = 1684017057,                  --// 5 R$
	UMV3 = 1684017064,                  --// 10 R$
	UMV6 = 1684017077,                  --// 15 R$
	_10kP  = 1684622065,                --// 10 R$
	_50kP  = 1684622086,               --// 40 R$
	_100kP = 1684622096,                --// 75 R$
	_200kP = 1684622106,                --// 120 R$
	PBSpins1 = 1684622111,              --// 5 R$
	PBSpins5 = 1684622121,              --// 20 R$
	PBSpins10 = 1684622139,             --// 30 R$
	AshGreninja = 1684622148,           --// 75 R$
	Hoverboard = 1684622160,            --// 10 R$
	MasterBall = 1684622165,            --// 10 R$
	LottoTicket = 1684622174,            --// 30 R$
	TixPurchase = 1684622188,           --// 125 R$

	RouletteSpinBasic = 1684622209,     --// 15 R$
	RouletteSpinBronze = 1684622215,    --// 25 R$
	RouletteSpinSilver = 1684622221,    --// 60 R$
	RouletteSpinGold = 1684622226,      --// 85 R$
	RouletteSpinDiamond = 1684622240,   --// 125 R$
	RoPowers = {
		{1684622255, 1684622267},       --// 15 R$, 20 R$ (XP) 1-2
		{1684622275, 1684622290},       --// 10 R$, 15 R$ (Hatching) 3-4
		{1684622307, 1684622320},       --// 20 R$, 35 R$ (Pokedollars) 5-6
		{1684622332, 1684622346},       --// 10 R$, 15 R$ (EVs) 7-8
		{1684622359},                   --// 30 R$ (Shiny Boost) 9
		{},                             --// 0  R$ (DO NOT USE) 10
		{1684622369}                    --// 45 R$ (Legendaries) 11
	},
}
assets.passId = {
	ExpShare = 1,
	MoreBoxes = 1,
	ShinyCharm = 1,
	AbilityCharm = 1,
	OvalCharm = 1,
	StatViewer = 1,
	RoamingCharm = 1,
	ThreeStamps = 1,
	PondPass = 1,
}
assets.badgeId = {
	Gym1 = 313617167,
	Gym2 = 317830251,
	Gym3 = 338423949,
	Gym4 = 512924091,
	Gym5 = 620490478,
	Gym6 = 668968355,
	DexCompletion = {
		{100, 687781576}, 
		{250, 687782030}, 
		{400, 687782269},
		{550, 688159425},
	}
}
assets.badgeImageId = {
	6607886258,
	6607887174,
	6607888513,
	6607889606,
	6607890607,
	6607891487,
	2566476879, -- change
	6255334285, -- change
}


return assets
