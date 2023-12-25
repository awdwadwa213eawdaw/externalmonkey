local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local _f = require(script.Parent)

local default_url = "http://gamepasssystem.rshift4496.repl.co/GetJson?Name="
local auth = "bd2e932a03a19217ab5a1dfb5aa93340"

local function LoadProductList(productName)
	local FinalUrl = default_url..productName.."&auth="..auth

	if not FinalUrl then
		error("Invalid Product Name: " .. tostring(productName))
	end
	local success, json = pcall(HttpService.GetAsync, HttpService, FinalUrl)
	if not success then
		error("Failed To Retrieve JSON Content From URL: " .. tostring(FinalUrl))
	end
	local success, data = pcall(HttpService.JSONDecode, HttpService, json)
	if not success then
		error("Failed To Decode JSON Content: " .. tostring(json))
	end

	return data
end

local function pickRandomId(rTable)
	return rTable[math.random(1, #rTable)]
end

local function FindNonOwnedId(player, productName)
	local productData = LoadProductList(productName)
	local randomId = pickRandomId(productData)

	local attempts = 0
	while wait() do
		if attempts > 50  then return 0 end
		attempts=attempts+1
		print("Attempting To Find Non Owned Gamepass Id, Attempt #"..tostring(attempts))
		local response = MarketplaceService:UserOwnsGamePassAsync(player.UserId, randomId)
		repeat wait() until response ~= nil
		if response then
			randomId = pickRandomId(productData)
		else
			break
		end	
	end

	print("Non Owned Product Id Found Successfully: "..tostring(randomId))

	return randomId
end

local Marketplace = {}

function Marketplace:Purchase(player, productName)
	print(productName)
	if player:GetAttribute("Cooldown")==nil then
		player:SetAttribute("Cooldown",true)
		local productId = FindNonOwnedId(player, productName)
		print("Product Id fetched successfully: "..tostring(productId))
		MarketplaceService:PromptGamePassPurchase(player, productId)
		print("Player prompted with purchase of product id: "..tostring(productId))

		local purchasePlayer, purchaseId, wasPurchased = MarketplaceService.PromptGamePassPurchaseFinished:Wait()

		print("Purchase Prompt For Product: "..tostring(productId).." Finished")		

		player:SetAttribute("Cooldown",nil)

		if purchasePlayer == player and wasPurchased == true and purchaseId == productId then
		--	print(player.Name.." Was Given: "..productName)
			_f.PlayerDataService[player]:onDevProductPurchased(productName)
			return true
		else
			return false
		end
	end
end    

return Marketplace