Config = {
	Framework = 'esx'; --Si vous êtes sur un framework, mettez 'frw', et si vous êtes sur un 'es_extended', mettez 'esx'.
	UnJailLocation = vector3(215.3101, -805.9603, 30.80556) ; -- Postions de téléportation du joueur une fois le jail finit ou le Unjail
	JailLocation = vector3(-2168.438, 5192.307, 16.50243) ;	-- Postions de téléportation du joueur une fois la commande jail effectuer  
	NameMenu = "Ascript"; -- Le nom qui apparait sur le menu
	TimeUnit = "H" -- SI vous voulez changer la valeur du jail en Heure Utilisez "H" en secondes Utilisez "S" et "M" pour minutes.
	}	

Config.Uniforms = {
	prison_wear = {
		male = {
			['tshirt_1'] = 55,  ['tshirt_2'] = 0,

			['torso_1']  = 14, ['torso_2']  = 0,

			['decals_1'] = 0,   ['decals_2'] = 0,

			['arms']     = 0, 

			['pants_1']  = 22,   ['pants_2']  = 0,
			
			['shoes_1']  = 6,  ['shoes_2']  = 0,
			
			['chain_1']  = -1,  ['chain_2']  = 0
		},
		female = {
			['tshirt_1'] = 3,   ['tshirt_2'] = 0,
			['torso_1']  = 38,  ['torso_2']  = 3,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms']     = 2,   ['pants_1']  = 3,
			['pants_2']  = 15,  ['shoes_1']  = 66,
			['shoes_2']  = 5,   ['chain_1']  = 0,
			['chain_2']  = 2
		}
	}
}
