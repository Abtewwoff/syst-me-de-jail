local framework = Config.Framework
local ESX = nil

if framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
elseif framework == 'frw' then
    ESX = exports['Framework']:getSharedObject()
else
    print("Votre Framework est spécial ou trop ancian, get le code pour changer l'export")
end

local isInJail, unjail = false, false
local jailTime, fastTimer = 0, 0

local aJail = RageUI.CreateMenu(Config.NameMenu, "vous êtes en jail")
aJail.Closable = false;
aJail.Closed = function()
    touche = false
end


RegisterNetEvent('esx_jail:jailPlayer')
AddEventHandler('esx_jail:jailPlayer', function(_jailTime, message, src)
	jailTime = _jailTime
	msg = message
	lol = src
	local playerPed = PlayerPedId()


	TriggerEvent('skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.prison_wear.male)
		else
			TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.prison_wear.female)
		end
	end)

	SetPedArmour(playerPed, 0)
	ESX.Game.Teleport(playerPed, Config.JailLocation)
	isInJail, unjail = true, false


	touche = true 
		RageUI.Visible(aJail, true)
		CreateThread(function()
			while touche do 

				if jailTime > 0 and isInJail then
					if fastTimer < 0 then
						fastTimer = jailTime 
					end

					fastTimer = fastTimer - 0.007666666 

					RageUI.IsVisible(aJail, function()

						RageUI.Button("Votre ID de jeux :", nil, {RightLabel = GetPlayerServerId(PlayerId())}, true, {}) 

						RageUI.Line()

						RageUI.Separator("↓ Information sur votre jail ↓")

						RageUI.Button("Staff qui vous a jail :", nil, {RightLabel = lol}, true, {}) 
						RageUI.Button("Temps restant :", nil, {RightLabel = ESX.Math.Round(fastTimer).." Secondes"}, true, {}) 
						RageUI.Button("Raison de Votre Jail :", nil, {RightLabel = msg }, true, {}) 

						RageUI.Line()

						RageUI.Separator("↓ Divers ↓")

						RageUI.Button("Se réanimer", nil, {RightLabel = "→→"}, true, {
							onSelected = function()
								ESX.ShowNotification("Vous vous êtes bien réanimer")
								SetEntityHealth(PlayerPedId(), 200)
								ClearPedTasksImmediately(PlayerPedId())
							end
						})

						RageUI.Button("Obtenir de l'aide", nil, {RightLabel = "→→"}, true, {
							onSelected = function()
								ExecuteCommand("report besoin d'aide jail")
							end
						})
						
					end)
				else
				end
				Wait(0)


				DisableControlAction(2, 37, true) -- Select Weapon
				---------------------------------------------------------------
				DisableControlAction(0, 25, true) -- Input Aim
				---------------------------------------------------------------
				DisableControlAction(0, 24, true) -- Input Attack
				---------------------------------------------------------------
				DisableControlAction(0, 257, true) -- Disable melee
				---------------------------------------------------------------
				DisableControlAction(0, 140, true) -- Disable melee
				---------------------------------------------------------------
				DisableControlAction(0, 142, true) -- Disable melee
				---------------------------------------------------------------
				DisableControlAction(0, 143, true) -- Disable melee
			end
	end)



	while not unjail do
		playerPed = PlayerPedId()


		if IsPedInAnyVehicle(playerPed, false) then
			ClearPedTasksImmediately(playerPed)
		end

		Wait(0)


		if #(GetEntityCoords(playerPed) - Config.JailLocation) > 42 then
			ESX.Game.Teleport(playerPed, Config.JailLocation)
		end
	end

	ESX.Game.Teleport(playerPed, Config.UnJailLocation)
	isInJail = false

	RageUI.CloseAll() 
    touche = false

	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
		TriggerEvent('skinchanger:loadSkin', skin)
	end)
end)


RegisterNetEvent('esx_jail:unjailPlayer')
AddEventHandler('esx_jail:unjailPlayer', function()
	unjail, jailTime, fastTimer = true, 0, 0
end)

AddEventHandler('playerSpawned', function(spawn)
	if isInJail then
		ESX.Game.Teleport(PlayerPedId(), Config.JailLocation)
	end
end)
