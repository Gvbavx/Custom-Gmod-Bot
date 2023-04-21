local BOT					=	FindMetaTable( "Player" )
local Ent					=	FindMetaTable( "Entity" )
local Npc					=	FindMetaTable( "NPC" )
local Zone					=	FindMetaTable( "CNavArea" )
local Lad					=	FindMetaTable( "CNavLadder" )
local LOW_PRIORITY			=	0
local MEDIUM_PRIORITY		=	1
local HIGH_PRIORITY			=	2
local MAXIMUM_PRIORITY		=	3
local BotUpdateSkipCount	=	2 -- This is how many upkeep events must be skipped before another update event can be run
local BotUpdateInterval		=	0
util.AddNetworkString( "TRizzleBotFlashlight" )

function TBotCreate( ply , cmd , args ) -- This code defines stats of the bot when it is created.  
	if !args[ 1 ] then error( "[WARNING] Please give a name for the bot!" ) end 
	if game.SinglePlayer() or player.GetCount() >= game.MaxPlayers() then error( "[INFORMATION] Cannot create new bot there are no avaliable player slots!" ) end
	
	local NewBot					=	player.CreateNextBot( args[ 1 ] ) -- Create the bot and store it in a varaible.
	
	NewBot.IsTRizzleBot				=	true -- Flag this as our bot so we don't control other bots, Only ours!
	NewBot.Owner					=	ply -- Make the player who created the bot its "owner"
	NewBot.FollowDist				=	tonumber( args[ 2 ] ) or 200 -- This is how close the bot will follow it's owner
	NewBot.DangerDist				=	tonumber( args[ 3 ] ) or 300 -- This is how far the bot can be from it's owner when in combat
	NewBot.Melee					=	args[ 4 ] or "weapon_crowbar" -- This is the melee weapon the bot will use
	NewBot.Pistol					=	args[ 5 ] or "weapon_pistol" -- This is the pistol the bot will use
	NewBot.Shotgun					=	args[ 6 ] or "weapon_shotgun" -- This is the shotgun the bot will use
	NewBot.Rifle					=	args[ 7 ] or "weapon_smg1" -- This is the rifle/smg the bot will use
	NewBot.Sniper					=	args[ 8 ] or "weapon_crossbow" -- This is the sniper the bot will use
	NewBot.MeleeDist				=	tonumber( args[ 9 ] ) or 80 -- If an enemy is closer than this, the bot will use its melee
	NewBot.PistolDist				=	tonumber( args[ 10 ] ) or 1300 -- If an enemy is closer than this, the bot will use its pistol
	NewBot.ShotgunDist				=	tonumber( args[ 11 ] ) or 300 -- If an enemy is closer than this, the bot will use its shotgun
	NewBot.RifleDist				=	tonumber( args[ 12 ] ) or 900 -- If an enemy is closer than this, the bot will use its rifle
	NewBot.HealThreshold			=	tonumber( args[ 13 ] ) or 100 -- If the bot's health or a teammate's health drops below this and the bot is not in combat the bot will use its medkit
	NewBot.CombatHealThreshold		=	tonumber( args[ 14 ] ) or 25 -- If the bot's health drops below this and the bot is in combat the bot will use its medkit
	NewBot.PlayerModel				=	args[ 15 ] or "kleiner" -- This is the player model the bot will use
	
	TBotSpawnWithPreferredWeapons( ply, cmd, { args[ 1 ], args[ 16 ] } )
	TBotSetPlayerModel( ply, cmd, { args[ 1 ], NewBot.PlayerModel } )
	NewBot:TBotResetAI() -- Fully reset your bots AI.
	
end

function TBotSetFollowDist( ply, cmd, args ) -- Command for changing the bots "Follow" distance to something other than the default.  
	if !args[ 1 ] then return end
	
	local targetbot = args[ 1 ]
	local followdist = tonumber( args[ 2 ] ) or 200
	
	for k, bot in ipairs( player.GetBots() ) do
		
		if bot.IsTRizzleBot and bot:Nick() == targetbot and bot.Owner == ply then
			
			bot.FollowDist = followdist
			break
		end
		
	end

end

function TBotSetDangerDist( ply, cmd, args ) -- Command for changing the bots "Danger" distance to something other than the default. 
	if !args[ 1 ] then return end
	
	local targetbot = args[ 1 ]
	local dangerdist = tonumber( args[ 2 ] ) or 300
	
	for k, bot in ipairs( player.GetBots() ) do
		
		if bot.IsTRizzleBot and bot:Nick() == targetbot and bot.Owner == ply then
			
			bot.DangerDist = dangerdist
			break
		end
		
	end

end

function TBotSetMelee( ply, cmd, args ) -- Command for changing the bots melee to something other than the default. 
	if !args[ 1 ] then return end
	
	local targetbot = args[ 1 ]
	local melee = args[ 2 ] or "weapon_crowbar"
	
	for k, bot in ipairs( player.GetBots() ) do
		
		if bot.IsTRizzleBot and bot:Nick() == targetbot and bot.Owner == ply then
			
			bot.Melee = melee
			break
		end
		
	end

end

function TBotSetPistol( ply, cmd, args ) -- Command for changing the bots pistol to something other than the default. 
	if !args[ 1 ] then return end
	
	local targetbot = args[ 1 ]
	local pistol = args[ 2 ] or "weapon_pistol"
	
	for k, bot in ipairs( player.GetBots() ) do
		
		if bot.IsTRizzleBot and bot:Nick() == targetbot and bot.Owner == ply then
			
			bot.Pistol = pistol
			break
		end
		
	end

end

function TBotSetShotgun( ply, cmd, args ) -- Command for changing the bots shotgun to something other than the default. 
	if !args[ 1 ] then return end
	
	local targetbot = args[ 1 ]
	local shotgun = args[ 2 ] or "weapon_shotgun"
	
	for k, bot in ipairs( player.GetBots() ) do
		
		if bot.IsTRizzleBot and bot:Nick() == targetbot and bot.Owner == ply then
			
			bot.Shotgun = shotgun
			break
		end
		
	end

end

function TBotSetRifle( ply, cmd, args ) -- Command for changing the bots rifle to something other than the default. 
	if !args[ 1 ] then return end
	
	local targetbot = args[ 1 ]
	local rifle = args[ 2 ] or "weapon_smg1"
	
	for k, bot in ipairs( player.GetBots() ) do
		
		if bot.IsTRizzleBot and bot:Nick() == targetbot and bot.Owner == ply then
			
			bot.Rifle = rifle
			break
		end
		
	end

end

function TBotSetSniper( ply, cmd, args ) -- Command for changing the bots sniper to something other than the default. 
	if !args[ 1 ] then return end
	
	local targetbot = args[ 1 ]
	local rifle = args[ 2 ] or "weapon_crossbow"
	
	for k, bot in ipairs( player.GetBots() ) do
		
		if bot.IsTRizzleBot and bot:Nick() == targetbot and bot.Owner == ply then
			
			bot.Sniper = rifle
			break
		end
		
	end

end

function TBotSetMeleeDist( ply, cmd, args )
	if !args[ 1 ] then return end
	
	local targetbot = args[ 1 ]
	local meleedist = tonumber( args[ 2 ] ) or 80
	
	for k, bot in ipairs( player.GetBots() ) do
		
		if bot.IsTRizzleBot and bot:Nick() == targetbot and bot.Owner == ply then
			
			bot.MeleeDist = meleedist
			break
		end
		
	end

end

function TBotSetPistolDist( ply, cmd, args )
	if !args[ 1 ] then return end
	
	local targetbot = args[ 1 ]
	local pistoldist = tonumber( args[ 2 ] ) or 1300
	
	for k, bot in ipairs( player.GetBots() ) do
		
		if bot.IsTRizzleBot and bot:Nick() == targetbot and bot.Owner == ply then
			
			bot.PistolDist = pistoldist
			break
		end
		
	end

end

function TBotSetShotgunDist( ply, cmd, args )
	if !args[ 1 ] then return end
	
	local targetbot = args[ 1 ]
	local shotgundist = tonumber( args[ 2 ] ) or 300
	
	for k, bot in ipairs( player.GetBots() ) do
		
		if bot.IsTRizzleBot and bot:Nick() == targetbot and bot.Owner == ply then
			
			bot.ShotgunDist = shotgundist
			break
		end
		
	end

end

function TBotSetRifleDist( ply, cmd, args )
	if !args[ 1 ] then return end
	
	local targetbot = args[ 1 ]
	local rifledist = tonumber( args[ 2 ] ) or 900
	
	for k, bot in ipairs( player.GetBots() ) do
		
		if bot.IsTRizzleBot and bot:Nick() == targetbot and bot.Owner == ply then
			
			bot.RifleDist = rifledist
			break
		end
		
	end

end

function TBotSetHealThreshold( ply, cmd, args )
	if !args[ 1 ] then return end
	
	local targetbot = args[ 1 ]
	local healthreshold = tonumber( args[ 2 ] ) or 100
	
	for k, bot in ipairs( player.GetBots() ) do
		
		if bot.IsTRizzleBot and bot:Nick() == targetbot and bot.Owner == ply then
			
			if healthreshold > bot:GetMaxHealth() then healthreshold = bot:GetMaxHealth() end
			bot.HealThreshold = healthreshold
			break
		end
		
	end

end

function TBotSetCombatHealThreshold( ply, cmd, args )
	if !args[ 1 ] then return end
	
	local targetbot = args[ 1 ]
	local combathealthreshold = tonumber( args[ 2 ] ) or 25
	
	for k, bot in ipairs( player.GetBots() ) do
		
		if bot.IsTRizzleBot and bot:Nick() == targetbot and bot.Owner == ply then
			
			if combathealthreshold > bot:GetMaxHealth() then combathealthreshold = bot:GetMaxHealth() end
			bot.CombatHealThreshold = combathealthreshold
			break
		end
		
	end

end

function TBotSetPlayerModel( ply, cmd, args )
	if !args[ 1 ] then return end
	
	local targetbot = args[ 1 ]
	local playermodel = args[ 2 ] or "kleiner"
	
	playermodel = player_manager.TranslatePlayerModel( playermodel )
	
	for k, bot in ipairs( player.GetBots() ) do
		
		if bot.IsTRizzleBot and bot:Nick() == targetbot and bot.Owner == ply then
			
			bot:SetModel( playermodel )
			bot.PlayerModel = playermodel
			break
		end
		
	end

end

function TBotSpawnWithPreferredWeapons( ply, cmd, args )
	if !args[ 1 ] then return end
	
	local targetbot = args[ 1 ]
	local spawnwithweapons = tonumber( args[ 2 ] ) or 1
	
	for k, bot in ipairs( player.GetBots() ) do
		
		if bot.IsTRizzleBot and bot:Nick() == targetbot and bot.Owner == ply then
			
			if spawnwithweapons == 0 then bot.SpawnWithWeapons = false
			else bot.SpawnWithWeapons = true end
			break
		end
		
	end

end

function TBotSetDefault( ply, cmd, args )
	if !args[ 1 ] then return end
	if args[ 2 ] then args[ 2 ] = nil end
	
	TBotSetFollowDist( ply, cmd, args )
	TBotSetDangerDist( ply, cmd, args )
	TBotSetMelee( ply, cmd, args )
	TBotSetPistol( ply, cmd, args )
	TBotSetShotgun( ply, cmd, args )
	TBotSetRifle( ply, cmd, args )
	TBotSetSniper( ply, cmd, args )
	TBotSetMeleeDist( ply, cmd, args )
	TBotSetPistolDist( ply, cmd, args )
	TBotSetShotgunDist( ply, cmd, args )
	TBotSetRifleDist( ply, cmd, args )
	TBotSetHealThreshold( ply, cmd, args )
	TBotSetCombatHealThreshold( ply, cmd, args )

end

concommand.Add( "TRizzleCreateBot" , TBotCreate , nil , "Creates a TRizzle Bot with the specified parameters. Example: TRizzleCreateBot <botname> <followdist> <dangerdist> <melee> <pistol> <shotgun> <rifle> <sniper> <meleedist> <pistoldist> <shotgundist> <rifledist> <healthreshold> <combathealthreshold> <playermodel> <spawnwithpreferredweapons> Example2: TRizzleCreateBot Bot 200 300 weapon_crowbar weapon_pistol weapon_shotgun weapon_smg1 weapon_crossbow 80 1300 300 900 100 25 alyx 1" )
concommand.Add( "TBotSetFollowDist" , TBotSetFollowDist , nil , "Changes the specified bot's how close it should be to its owner. If only the bot is specified the value will revert back to the default." )
concommand.Add( "TBotSetDangerDist" , TBotSetDangerDist , nil , "Changes the specified bot's how far the bot can be from its owner while in combat. If only the bot is specified the value will revert back to the default." )
concommand.Add( "TBotSetMelee" , TBotSetMelee , nil , "Changes the specified bot's preferred melee weapon. If only the bot is specified the value will revert back to the default." )
concommand.Add( "TBotSetPistol" , TBotSetPistol , nil , "Changes the specified bot's preferred pistol. If only the bot is specified the value will revert back to the default." )
concommand.Add( "TBotSetShotgun" , TBotSetShotgun , nil , "Changes the specified bot's preferred shotgun. If only the bot is specified the value will revert back to the default." )
concommand.Add( "TBotSetRifle" , TBotSetRifle , nil , "Changes the specified bot's preferred rifle/smg. If only the bot is specified the value will revert back to the default." )
concommand.Add( "TBotSetSniper" , TBotSetSniper , nil , "Changes the specified bot's preferred sniper. If only the bot is specified the value will revert back to the default." )
concommand.Add( "TBotSetMeleeDist" , TBotSetMeleeDist , nil , "Changes the distance for when the bot should use it's melee weapon. If only the bot is specified the value will revert back to the default." )
concommand.Add( "TBotSetPistolDist" , TBotSetPistolDist , nil , "Changes the distance for when the bot should use it's pistol. If only the bot is specified the value will revert back to the default." )
concommand.Add( "TBotSetShotgunDist" , TBotSetShotgunDist , nil , "Changes the distance for when the bot should use it's shotgun. If only the bot is specified the value will revert back to the default." )
concommand.Add( "TBotSetRifleDist" , TBotSetRifleDist , nil , "Changes the distance for when the bot should use it's rifle/smg. If only the bot is specified the value will revert back to the default." )
concommand.Add( "TBotSetHealThreshold" , TBotSetHealThreshold , nil , "Changes the amount of health the bot must have before it will consider using it's medkit on itself and its owner. If only the bot is specified the value will revert back to the default." )
concommand.Add( "TBotSetCombatHealThreshold" , TBotSetCombatHealThreshold , nil , "Changes the amount of health the bot must have before it will consider using it's medkit on itself if it is in combat. If only the bot is specified the value will revert back to the default." )
concommand.Add( "TBotSpawnWithPreferredWeapons" , TBotSpawnWithPreferredWeapons , nil , "Can the bot spawn with its preferred weapons, set to 0 to disable. If only the bot is specified the value will revert back to the default." )
concommand.Add( "TBotSetPlayerModel" , TBotSetPlayerModel , nil , "Changes the bot playermodel to the model shortname specified. If only the bot is specified or the model shortname given is invalid the bot's player model will revert back to the default." )
concommand.Add( "TBotSetDefault" , TBotSetDefault , nil , "Set the specified bot's settings back to the default." )

-------------------------------------------------------------------|



function BOT:TBotResetAI()
	
	self.buttonFlags			=	0 -- These are the buttons the bot is going to press.
	self.Enemy					=	nil -- This is the bot's current enemy.
	self.EnemyList				=	{} -- This is the list of enemies the bot knows about.
	self.AimForHead				=	false -- Should the bot aim for the head?
	self.TimeInCombat			=	0 -- This is how long the bot has been in combat.
	self.LastCombatTime			=	0 -- This is the last time the bot was in combat.
	self.BestWeapon				=	nil -- This is the weapon the bot currently wants to equip.
	self.MinEquipInterval		=	0 -- Throttles how often equipping is allowed.
	self.HealTarget				=	nil -- This is the player the bot is trying to heal.
	self.IsTRizzleBotBlind		=	false -- Is the bot blind?
	self.NextJump				=	0 -- This is the next time the bot is allowed to jump.
	self.HoldAttack				=	0 -- This is how long the bot should hold its attack button.
	self.HoldAttack2			=	0 -- This is how long the bot should hold its attack2 button.
	self.HoldReload				=	0 -- This is how long the bot should hold its reload button.
	self.HoldForward			=	0 -- This is how long the bot should hold its forward button.
	self.HoldRun				=	0 -- This is how long the bot should hold its run button.
	self.HoldWalk				=	0 -- This is how long the bot should hold its walk button.
	self.HoldJump				=	0 -- This is how long the bot should hold its jump button.
	self.HoldCrouch				=	0 -- This is how long the bot should hold its crouch button.
	self.HoldUse				=	0 -- This is how long the bot should hold its use button.
	self.ShouldReset			=	false -- This tells the bot to clear all buttons and movement.
	self.FullReload				=	false -- This tells the bot not to press its attack button until its current weapon is fully reloaded.
	self.FireWeaponInterval		=	0 -- Limits how often the bot presses its attack button.
	self.ReloadInterval			=	0 -- Limits how often the bot can press its reload button.
	self.Light					=	false -- Tells the bot if it should have its flashlight on or off.
	self.LookTarget				=	false -- This is the position the bot is currently trying to look at.
	self.LookTargetTime			=	0 -- This is how long the bot will look at the position the bot is currently trying to look at.
	self.LookTargetPriority		=	LOW_PRIORITY -- This is how important the position the bot is currently trying to look at is.
	self.Goal					=	nil -- The vector goal we want to get to.
	self.NavmeshNodes			=	{} -- The nodes given to us by the pathfinder.
	self.Path					=	nil -- The nodes converted into waypoints by our visiblilty checking.
	self.PathTime				=	CurTime() + 0.5 -- This will limit how often the path gets recreated.
	
	--self:TBotCreateThinking() -- Start our AI
	
end


hook.Add( "StartCommand" , "TRizzleBotAIHook" , function( bot , cmd )
	if !IsValid( bot ) or !bot:IsBot() or !bot:Alive() or !bot.IsTRizzleBot or FrameTime() < 0.00001 then return end
	-- Make sure we can control this bot and its not a player. I also check the frame time to stop the bot from spaming user commands
	
	bot:ResetCommand( cmd )
	bot:UpdateAim()
	
	-- Better make sure they exist of course.
	if IsValid( bot.Enemy ) then
	
		-- Turn and face our enemy!
		if bot.AimForHead and !bot:IsActiveWeaponRecoilHigh() then
		
			-- Can we aim the enemy's head?
			bot:AimAtPos( bot.Enemy:EyePos(), CurTime() + 0.1, HIGH_PRIORITY )
		
		else
		
			-- If we can't aim at our enemy's head aim at the center of their body instead.
			bot:AimAtPos( bot.Enemy:WorldSpaceCenter(), CurTime() + 0.1, HIGH_PRIORITY )
		
		end
		
		if isvector( bot.Goal ) and (bot.Owner:GetPos() - bot.Goal):LengthSqr() > bot.FollowDist * bot.FollowDist or !isvector( bot.Goal ) and (bot.Owner:GetPos() - bot:GetPos()):LengthSqr() > bot.DangerDist * bot.DangerDist then
		
			bot:TBotSetNewGoal( bot.Owner:GetPos() )
		
		else
		
			bot:TBotUpdateMovement( cmd )
		
		end
	
	elseif IsValid( bot.Owner ) and bot.Owner:Alive() then
	
		if isvector( bot.Goal ) and (bot.Owner:GetPos() - bot.Goal):LengthSqr() > bot.FollowDist * bot.FollowDist or !isvector( bot.Goal ) and (bot.Owner:GetPos() - bot:GetPos()):LengthSqr() > bot.FollowDist * bot.FollowDist then
		
			bot:TBotSetNewGoal( bot.Owner:GetPos() )
		
		else
		
			bot:TBotUpdateMovement( cmd )
		
		end
	end
	
	cmd:SetButtons( bot.buttonFlags )
	if IsValid( bot.BestWeapon ) and bot.BestWeapon:IsWeapon() then cmd:SelectWeapon( bot.BestWeapon ) end
	
end)

function BOT:ResetCommand( cmd )
	if !self.ShouldReset then return end

	cmd:ClearButtons() -- Clear the bots buttons. Shooting, Running , jumping etc...
	cmd:ClearMovement() -- For when the bot is moving around.
	local buttons = 0
	
	if self.HoldAttack > CurTime() then buttons = bit.bor( buttons, IN_ATTACK ) end
	if self.HoldAttack2 > CurTime() then buttons = bit.bor( buttons, IN_ATTACK2 ) end
	if self.HoldReload > CurTime() then buttons = bit.bor( buttons, IN_RELOAD ) end
	if self.HoldForward > CurTime() then buttons = bit.bor( buttons, IN_FORWARD ) end
	if self.HoldRun > CurTime() then buttons = bit.bor( buttons, IN_SPEED ) end
	if self.HoldWalk > CurTime() then buttons = bit.bor( buttons, IN_WALK ) end
	if self.HoldJump > CurTime() then buttons = bit.bor( buttons, IN_JUMP ) end
	if self.HoldCrouch > CurTime() then buttons = bit.bor( buttons, IN_DUCK ) end
	if self.HoldUse > CurTime() then buttons = bit.bor( buttons, IN_USE ) end
	
	self.buttonFlags = buttons
	self.ShouldReset = false

end

function BOT:HandleButtons()

	local closeArea		=	navmesh.GetNearestNavArea( self:GetPos() )
	local CanRun		=	true
	local ShouldJump	=	false
	local ShouldCrouch	=	false
	local ShouldRun		=	false
	local ShouldWalk	=	false
	
	if IsValid ( closeArea ) then -- If there is no nav_mesh this will not run to prevent the addon from spamming errors
		
		if self:IsOnGround() and closeArea:HasAttributes( NAV_MESH_JUMP ) then
			
			ShouldJump		=	true
			
		end
		
		if closeArea:HasAttributes( NAV_MESH_CROUCH ) then
			
			ShouldCrouch	=	true
			
		end
		
		if closeArea:HasAttributes( NAV_MESH_RUN ) then
			
			ShouldRun		=	true
			ShouldWalk		=	false
			
		end
		
		if closeArea:HasAttributes( NAV_MESH_WALK ) then
			
			CanRun			=	false
			ShouldWalk		=	true
			
		end
		
		if closeArea:HasAttributes( NAV_MESH_STAIRS ) then -- The bot shouldn't jump while on stairs
		
			ShouldJump		=	false
		
		end
		
	end
	
	-- Run if we are too far from our owner or the navmesh tells us to
	if CanRun and ( ShouldRun or (self.Owner:GetPos() - self:GetPos()):LengthSqr() > self.DangerDist * self.DangerDist ) and self:GetSuitPower() > 20 then 
		
		self:PressRun()
	
	end
	
	-- Walk if the navmesh tells us to
	if ShouldWalk then -- I might make the bot walk if near its owner
		
		self:PressWalk()
	
	end
	
	if ( ShouldCrouch and !ShouldJump ) or ( !self:IsOnGround() and self:WaterLevel() < 2 ) then 
	
		self:PressCrouch( 0.3 )
		
	end
	
	if self:Is_On_Ladder() then
		
		self:PressForward()
		
	end
	
	if ShouldJump then 
	
		self:PressJump()
		
	end
	
	local door = self:GetEyeTrace().Entity
	
	if self.ShouldUse and IsValid( door ) and door:IsDoor() and (door:GetPos() - self:GetPos()):LengthSqr() < 6400 then 
	
		self:PressUse()
		
		self.ShouldUse = false 
		
	end
	
end

function BOT:PressPrimaryAttack( holdTime )
	if self.HoldAttack > CurTime() then return end
	holdTime = holdTime or 0.1

	self.buttonFlags = bit.bor( self.buttonFlags, IN_ATTACK )
	self.HoldAttack = CurTime() + holdTime

end

function BOT:PressSecondaryAttack( holdTime )
	if self.HoldAttack2 > CurTime() then return end
	holdTime = holdTime or 0.1

	self.buttonFlags = bit.bor( self.buttonFlags, IN_ATTACK2 )
	self.HoldAttack2 = CurTime() + holdTime

end

function BOT:PressReload( holdTime )
	if self.HoldReload > CurTime() then return end
	holdTime = holdTime or 0.1

	self.buttonFlags = bit.bor( self.buttonFlags, IN_RELOAD )
	self.HoldReload = CurTime() + holdTime

end

function BOT:PressForward( holdTime )
	if self.HoldForward > CurTime() then return end
	holdTime = holdTime or 0.1

	self.buttonFlags = bit.bor( self.buttonFlags, IN_FORWARD )
	self.HoldForward = CurTime() + holdTime

end

function BOT:PressRun( holdTime )
	if self.HoldRun > CurTime() then return end
	holdTime = holdTime or 0.1

	self.buttonFlags = bit.bor( self.buttonFlags, IN_SPEED )
	self.HoldRun = CurTime() + holdTime

end

function BOT:PressWalk( holdTime )
	if self.HoldWalk > CurTime() then return end
	holdTime = holdTime or 0.1

	self.buttonFlags = bit.bor( self.buttonFlags, IN_WALK )
	self.HoldWalk = CurTime() + holdTime

end

function BOT:PressJump( holdTime )
	if self.NextJump > CurTime() then return end
	holdTime = holdTime or 0.1

	self.buttonFlags = bit.bor( self.buttonFlags, IN_JUMP )
	self.HoldJump = CurTime() + holdTime
	self.NextJump = CurTime() + holdTime + 0.5 -- This cooldown is to prevent the bot from pressing and holding its jump button

end

function BOT:PressCrouch( holdTime )
	if self.HoldCrouch > CurTime() then return end
	holdTime = holdTime or 0.1

	self.buttonFlags = bit.bor( self.buttonFlags, IN_DUCK )
	self.HoldCrouch = CurTime() + holdTime

end

function BOT:PressUse( holdTime )
	if self.HoldUse > CurTime() then return end
	holdTime = holdTime or 0.1

	self.buttonFlags = bit.bor( self.buttonFlags, IN_USE )
	self.HoldUse = CurTime() + holdTime

end

net.Receive( "TRizzleBotFlashlight", function( _, ply) 

	local tab = net.ReadTable()
	if !istable( tab ) or table.IsEmpty( tab ) then return end
	
	for bot, light in pairs( tab ) do
	
		light = Vector(math.Round(light.x, 2), math.Round(light.y, 2), math.Round(light.z, 2))
		
		if light == vector_origin then -- Vector( 0, 0, 0 )
		
			bot.Light	=	true
			
		else
		
			bot.Light	=	false
			
		end
		
	end
end)

function BOT:IsInCombat()

	if IsValid ( self.Enemy ) then
	
		self.LastCombatTime = CurTime() + 5.0
		return true
		
	end
	
	if self.LastCombatTime > CurTime() then return true end
	
	return false
	
end

function BOT:UpdateAim()
	if !isvector( self.LookTarget ) or self.LookTargetTime < CurTime() then return end

	local currentAngles = self:EyeAngles() + self:GetViewPunchAngles()
	local targetPos = ( self.LookTarget - self:GetShootPos() ):GetNormalized()
	
	local lerp = FrameTime() * math.random(10, 20) -- Should this be a lower number?
	
	local angles = LerpAngle( lerp, currentAngles, targetPos:Angle() )
	
	-- back out "punch angle"
	angles = angles - self:GetViewPunchAngles()

	self:SetEyeAngles( angles )

end

function BOT:AimAtPos( Pos, Time, Priority )
	if !isvector( Pos ) or Time < CurTime() or ( self.LookTargetPriority > Priority and CurTime() < self.LookTargetTime ) then return end
	
	self.LookTarget				=	Pos
	self.LookTargetTime			=	Time
	self.LookTargetPriority		=	Priority
	
end

-- Got this from CS:GO Source Code, made some changes so it works for Lua
function BOT:IsActiveWeaponRecoilHigh()

	local angles = self:GetViewPunchAngles()
	local highRecoil = -1.5
	return angles.x < highRecoil
end

-- For some reason IsAbleToSee doesn't work with player bots
function BOT:PointWithinViewAngle( pos, targetpos, lookdir, fov )
	
	pos = targetpos - pos
	local diff = lookdir:Dot(pos)
	
	if diff < 0 then return false end
	if self:IsHiddenByFog( pos:Length() ) then return false end
	
	local length = pos:LengthSqr()
	return diff * diff > length * fov * fov
end

-- This checks if the entered position in the bot's LOS
function BOT:IsAbleToSee( pos )
	if self.IsTRizzleBotBlind then return false end

	local fov = math.cos(0.5 * self:GetFOV() * math.pi / 180) -- I grab the bot's current FOV

	if IsValid( pos ) and IsEntity( pos ) then
		-- we must check eyepos and worldspacecenter
		-- maybe in the future add more points

		if self:PointWithinViewAngle(self:GetShootPos(), pos:WorldSpaceCenter(), self:GetAimVector(), fov) then
			local trace = util.TraceLine( { start = self:GetShootPos(), endpos = pos:WorldSpaceCenter(), filter = self, mask = MASK_VISIBLE_AND_NPCS } )
			
			if trace.Entity == pos then
				return true
		
			end
		end
		if self:PointWithinViewAngle(self:GetShootPos(), pos:EyePos(), self:GetAimVector(), fov) then
			local trace = util.TraceLine( { start = self:GetShootPos(), endpos = pos:EyePos(), filter = self, mask = MASK_VISIBLE_AND_NPCS } )
			
			if trace.Entity == pos then
				return true
			end
		end

	else
		if self:PointWithinViewAngle(self:GetShootPos(), pos, self:GetAimVector(), fov) then 
			local trace = util.TraceLine( { start = self:GetShootPos(), endpos = pos, filter = self, mask = MASK_VISIBLE_AND_NPCS } )
		
			if trace.Fraction <= 1.0 then
				return true
			end
		end
	end
	
	return false
end

-- Blinds the bot for a specified amount of time
function BOT:TBotBlind( time )
	if !IsValid( self ) or !self:Alive() or !self.IsTRizzleBot or !isnumber( time ) or time < 0 then return end
	
	self.IsTRizzleBotBlind = true
	timer.Simple( time , function()
		
		if IsValid( self ) and self:Alive() then self.IsTRizzleBotBlind = false end
		
	end)
	
end

-- Got this from CS:GO Source Code, made some changes so it works for Lua
-- Checks if the bot can see the set range without the fog obscuring it
function BOT:IsHiddenByFog( range )

	if self:GetFogObscuredRatio( range ) >= 1.0 then
		return true
	end

	return false
end

-- Got this from CS:GO Source Code, made some changes so it works for Lua
-- This returns a number based on how obscured a position is, 0.0 not obscured and 1.0 completely obscured
function BOT:GetFogObscuredRatio( range )

	local fog = self:GetFogParams()
	
	if !IsValid( fog ) then 
		return 0.0
	end
	
	local enable = fog:GetInternalVariable( "m_fog.enable" )
	local startDist = fog:GetInternalVariable( "m_fog.start" )
	local endDist = fog:GetInternalVariable( "m_fog.end" )
	local maxdensity = fog:GetInternalVariable( "m_fog.maxdensity" )

	if !enable then
		return 0.0
	end

	if range <= startDist then
		return 0.0
	end

	if range >= endDist then
		return 1.0
	end

	local ratio = (range - startDist) / (endDist - startDist)
	ratio = math.min( ratio, maxdensity )
	return ratio
end

-- Finds and returns the master fog controller
function GetMasterFogController()
	
	for k, fogController in ipairs( ents.FindByClass( "env_fog_controller" ) ) do
		
		if IsValid( fogController ) then return fogController end
		
	end
	
	return nil
	
end

-- Finds the fog entity that is currently affecting a bot
function BOT:GetFogParams()

	local targetFog = nil
	local trigger = self:GetFogTrigger()
	
	if IsValid( trigger ) then
		
		targetFog = trigger
	end
	
	if !IsValid( targetFog ) and IsValid( GetMasterFogController() ) then
	
		targetFog = GetMasterFogController()
	end

	if IsValid( targetFog ) then
	
		return targetFog
	
	else
		
		return nil
		
	end

end

-- Got this from CS:GO Source Code, made some changes so it works for Lua
-- Tracks the last trigger_fog touched by this bot
function BOT:GetFogTrigger()

	local bestDist = 100000 * 100000
	local bestTrigger = nil

	for k, fogTrigger in ipairs( ents.FindByClass( "trigger_fog" ) ) do
	
		if IsValid( fogTrigger ) then
		
			local dist = self:WorldSpaceCenter():DistToSqr( fogTrigger:WorldSpaceCenter() )
			if dist < bestDist then
				bestDist = dist
				bestTrigger = fogTrigger
			end
		end
	end
	
	return bestTrigger
end

-- This will check if the bot's cursor is close the enemy the bot is fighting
function BOT:PointWithinCursor( targetpos )
	
	local EntWidth = self.Enemy:BoundingRadius() * 0.5
	local pos = targetpos - self:GetShootPos()
	local fov = math.cos( math.atan( EntWidth / pos:Length() ) )
	local diff = self:GetAimVector():Dot( pos )
	if diff < 0 then return false end
	
	local length = pos:LengthSqr()
	if diff * diff <= length * fov * fov then return false end
	
	-- This check makes sure the bot won't attempt to shoot through other players and unbreakable windows
	local trace = util.TraceLine( { start = self:GetShootPos(), endpos = targetpos, filter = self, mask = MASK_SHOT } )
	return trace.Entity != self.Enemy

end

function BOT:IsCursorOnTarget()

	if IsValid( self.Enemy ) then
		-- we must check eyepos and worldspacecenter
		-- maybe in the future add more points

		if self:PointWithinCursor( self.Enemy:WorldSpaceCenter() ) then
			return true
		end

		return self:PointWithinCursor( self.Enemy:EyePos() )
	
	end
	
	return false
end

function BOT:SelectBestWeapon()
	if self.MinEquipInterval > CurTime() then return end
	
	-- This will select the best weapon based on the bot's current distance from its enemy
	local enemydistsqr	=	(self.Enemy:GetPos() - self:GetPos()):LengthSqr() -- Only compute this once, there is no point in recomputing it multiple times as doing so is a waste of computer resources
	local bestWeapon
	local oldBestWeapon = self.BestWeapon
	
	if self:HasWeapon( "weapon_medkit" ) and self.CombatHealThreshold > self:Health() then
		
		-- The bot will heal themself if they get too injured during combat
		bestWeapon = "weapon_medkit"
	else
		-- I use multiple if statements instead of elseifs
		if self:HasWeapon( self.Sniper ) and self:GetWeapon( self.Sniper ):HasAmmo() then
			
			-- If an enemy is very far away, the bot should use its sniper
			bestWeapon = self.Sniper
		end
		
		if self:HasWeapon( self.Pistol ) and self:GetWeapon( self.Pistol ):HasAmmo() and enemydistsqr < self.PistolDist * self.PistolDist then
			
			-- If an enemy is far the bot, the bot should use its pistol
			bestWeapon = self.Pistol
		end
		
		if self:HasWeapon( self.Rifle ) and self:GetWeapon( self.Rifle ):HasAmmo() and enemydistsqr < self.RifleDist * self.RifleDist then
		
			-- If an enemy gets too far but is still close, the bot should use its rifle
			bestWeapon = self.Rifle
		end
		
		if self:HasWeapon( self.Shotgun ) and self:GetWeapon( self.Shotgun ):HasAmmo() and enemydistsqr < self.ShotgunDist * self.ShotgunDist then
			
			-- If an enemy gets close, the bot should use its shotgun
			bestWeapon = self.Shotgun
		end
		
		if self:HasWeapon( self.Melee ) and enemydistsqr < self.MeleeDist * self.MeleeDist then

			-- If an enemy gets too close, the bot should use its melee
			bestWeapon = self.Melee
		end
	end
	
	if isstring( bestWeapon ) then self.BestWeapon = self:GetWeapon( bestWeapon ) end
	if ( !IsValid( oldBestWeapon ) or !oldBestWeapon:IsWeapon() or self.BestWeapon != oldBestWeapon ) and IsValid( self.BestWeapon ) and self.BestWeapon:GetClass() != "weapon_medkit" then self.MinEquipInterval = CurTime() + 5.0 end
	
end

function BOT:SelectMedkit()

	if self:HasWeapon( "weapon_medkit" ) then self.BestWeapon = self:GetWeapon( "weapon_medkit" ) end
	
end

function BOT:ReloadWeapons()
	
	-- The bot should reload weapons that need to be reloaded
	if self:HasWeapon( self.Sniper ) and self:GetWeapon( self.Sniper ):Clip1() < self:GetWeapon( self.Sniper ):GetMaxClip1() then
		
		self.BestWeapon = self:GetWeapon( self.Sniper )
		
	elseif self:HasWeapon( self.Pistol ) and self:GetWeapon( self.Pistol ):Clip1() < self:GetWeapon( self.Pistol ):GetMaxClip1() then
		
		self.BestWeapon = self:GetWeapon( self.Pistol )
		
	elseif self:HasWeapon( self.Rifle ) and self:GetWeapon( self.Rifle ):Clip1() < self:GetWeapon( self.Rifle ):GetMaxClip1() then
		
		self.BestWeapon = self:GetWeapon( self.Rifle )
		
	elseif self:HasWeapon( self.Shotgun ) and self:GetWeapon( self.Shotgun ):Clip1() < self:GetWeapon( self.Shotgun ):GetMaxClip1() then
		
		self.BestWeapon = self:GetWeapon( self.Shotgun )
		
	end
	
end

function BOT:RestoreAmmo()
	
	-- This is kind of a cheat, but the bot will only slowly recover ammo when not in combat
	local pistol		=	self:GetWeapon( self.Pistol )
	local rifle			=	self:GetWeapon( self.Rifle )
	local shotgun		=	self:GetWeapon( self.Shotgun )
	local sniper		=	self:GetWeapon( self.Sniper )
	local pistol_ammo
	local rifle_ammo
	local shotgun_ammo
	local sniper_ammo
	
	if IsValid ( pistol ) then pistol_ammo		=	self:GetAmmoCount( pistol:GetPrimaryAmmoType() ) end
	if IsValid ( rifle ) then rifle_ammo		=	self:GetAmmoCount( rifle:GetPrimaryAmmoType() ) end
	if IsValid ( shotgun ) then shotgun_ammo	=	self:GetAmmoCount( shotgun:GetPrimaryAmmoType() ) end
	if IsValid ( sniper ) then sniper_ammo		=	self:GetAmmoCount( sniper:GetPrimaryAmmoType() ) end
	
	if isnumber( pistol_ammo ) and self:HasWeapon( self.Pistol ) and pistol_ammo < 100 then
		
		self:GiveAmmo( 1, pistol:GetPrimaryAmmoType(), true )
		
	end
	
	if isnumber( rifle_ammo ) and self:HasWeapon( self.Rifle ) and rifle_ammo < 250 then
		
		self:GiveAmmo( 1, rifle:GetPrimaryAmmoType(), true )
		
	end
	
	if isnumber( shotgun_ammo ) and self:HasWeapon( self.Shotgun ) and shotgun_ammo < 60 then
		
		self:GiveAmmo( 1, shotgun:GetPrimaryAmmoType(), true )
		
	end
	
	if isnumber( sniper_ammo ) and self:HasWeapon( self.Sniper ) and sniper_ammo < 40 then
		
		self:GiveAmmo( 1, sniper:GetPrimaryAmmoType(), true )
		
	end
	
end

function Ent:IsDoor()

	if (self:GetClass() == "func_door") or (self:GetClass() == "prop_door_rotating") or (self:GetClass() == "func_door_rotating") then
        
		return true
    
	end
	
	return false
	
end


-- When a player leaves the server, every bot "owned" by the player should leave as well
hook.Add( "PlayerDisconnected" , "TRizzleBotPlayerLeave" , function( ply )
	
	if !ply:IsBot() and !ply.IsTRizzleBot then 
		
		for k, bot in ipairs( player.GetBots() ) do
		
			if bot.IsTRizzleBot and bot.Owner == ply then
			
				bot:Kick( "Owner " .. ply:Nick() .. " has left the server" )
			
			end
		end
		
	end
	
end)

-- Just a simple way to respawn a bot.
hook.Add( "PostPlayerDeath" , "TRizzleBotRespawn" , function( ply )
	
	if ply:IsBot() and ply.IsTRizzleBot then 
		
		timer.Simple( 3 , function()
			
			if IsValid( ply ) and !ply:Alive() then
				
				ply:Spawn()
				
			end
			
		end)
		
	end
	
end)

-- This is for certain functions that effect every bot with one call.
hook.Add( "Think" , "TRizzleBotThink" , function()
	
	BotUpdateInterval = ( BotUpdateSkipCount + 1 ) * FrameTime()
	
	timer.Simple( 0.15 , function()
		local tab = player.GetHumans()
		if #tab > 0 then
			local ply = table.Random(tab)
			
			net.Start( "TRizzleBotFlashlight" )
			net.Send( ply )
		end
		
	end)
	
	for k, bot in ipairs( player.GetBots() ) do
	
		if bot.IsTRizzleBot and bot:Alive() then
			
			if ( ( engine:TickCount() + bot:EntIndex() ) % BotUpdateSkipCount ) == 0 then
			
				bot.ShouldReset = true -- Clear all movement and buttons
			
				-- A quick condition statement to check if our enemy is no longer a threat.
				bot:CheckCurrentEnemyStatus()
				bot:TBotFindClosestEnemy()
				bot:TBotCheckEnemyList()
				
				if !bot:IsInCombat() then
				
					-- If the bot is not in combat then the bot should check if any of its teammates need healing
					bot.HealTarget = bot:TBotFindClosestTeammate()
					local botWeapon = bot:GetActiveWeapon()
					if IsValid( bot.HealTarget ) then
					
						bot:SelectMedkit()
						
						if IsValid( botWeapon ) and botWeapon:IsWeapon() and botWeapon:GetClass() == "weapon_medkit" then
							
							if CurTime() > bot.FireWeaponInterval and bot.HealTarget == bot then
							
								bot.FireWeaponInterval = CurTime() + 0.5
								bot:PressSecondaryAttack()
								
							elseif CurTime() > bot.FireWeaponInterval and bot:GetEyeTrace().Entity == bot.HealTarget then
							
								bot.FireWeaponInterval = CurTime() + 0.5
								bot:PressPrimaryAttack()
								
							end
							
							if bot.HealTarget != bot then bot:AimAtPos( bot.HealTarget:WorldSpaceCenter(), CurTime() + 0.1, MEDIUM_PRIORITY ) end
							
						end
						
					else
					
						bot:ReloadWeapons()
						
					end
					
					if IsValid( botWeapon ) and botWeapon:IsWeapon() and CurTime() > bot.ReloadInterval and !botWeapon:GetInternalVariable( "m_bInReload" ) and botWeapon:GetClass() != "weapon_medkit" and botWeapon:Clip1() < botWeapon:GetMaxClip1() then
						bot:PressReload()
						bot.ReloadInterval = CurTime() + 0.5
					end
					
					bot:RestoreAmmo() 
					
				elseif IsValid( bot.Enemy ) then
					
					-- Should I limit how often this runs?
					local trace = util.TraceLine( { start = bot:GetShootPos(), endpos = bot.Enemy:EyePos(), filter = bot, mask = MASK_SHOT } )
					
					if trace.Entity == bot.Enemy then
						
						bot.AimForHead = true
						
					else
						
						bot.AimForHead = false
						
					end
					
					local botWeapon = bot:GetActiveWeapon()
					
					if IsValid( botWeapon ) and botWeapon:IsWeapon() then
					
						if bot.FullReload and ( botWeapon:Clip1() >= botWeapon:GetMaxClip1() or bot:GetAmmoCount( botWeapon:GetPrimaryAmmoType() ) <= botWeapon:Clip1() or botWeapon:GetClass() != bot.Shotgun ) then bot.FullReload = false end -- Fully reloaded :)
						
						if CurTime() > bot.FireWeaponInterval and !botWeapon:GetInternalVariable( "m_bInReload" ) and !bot.FullReload and botWeapon:GetClass() != "weapon_medkit" and bot:IsCursorOnTarget() then
							bot:PressPrimaryAttack()
							bot.FireWeaponInterval = CurTime() + math.Rand( 0.15 , 0.4 )
						end
						
						if CurTime() > bot.FireWeaponInterval and botWeapon:GetClass() == "weapon_medkit" and bot.CombatHealThreshold > bot:Health() then
							bot:PressSecondaryAttack()
							bot.FireWeaponInterval = CurTime() + 0.5
						end
						
						if CurTime() > bot.ReloadInterval and !botWeapon:GetInternalVariable( "m_bInReload" ) and botWeapon:Clip1() == 0 then
							if botWeapon:GetClass() == bot.Shotgun then bot.FullReload = true end
							bot:PressReload()
							bot.ReloadInterval = CurTime() + 0.5
						end
						
					end
					
					bot:SelectBestWeapon()
				
				end
				
				if bot.Owner:InVehicle() and !bot:InVehicle() then
				
					local vehicle = bot:FindNearbySeat()
					
					if IsValid( vehicle ) then bot:EnterVehicle( vehicle ) end -- I should make the bot press its use key instead of this hack
				
				end
				
				if !bot.Owner:InVehicle() and bot:InVehicle() then
				
					bot:ExitVehicle() -- Should I make the bot press its use key instead?
				
				end
				
				if bot.SpawnWithWeapons then
					
					if !bot:HasWeapon( bot.Pistol ) then bot:Give( bot.Pistol )
					elseif !bot:HasWeapon( bot.Shotgun ) then bot:Give( bot.Shotgun )
					elseif !bot:HasWeapon( bot.Rifle ) then bot:Give( bot.Rifle )
					elseif !bot:HasWeapon( bot.Sniper ) then bot:Give( bot.Sniper )
					elseif !bot:HasWeapon( bot.Melee ) then bot:Give( bot.Melee )
					elseif !bot:HasWeapon( "weapon_medkit" ) then bot:Give( "weapon_medkit" ) end
					
				end
				
				-- I have to set the flashlight state because some addons have mounted flashlights and I can't check if they are on or not, "This will prevent the flashlight on and off spam"
				if bot:CanUseFlashlight() and !bot:FlashlightIsOn() and bot.Light and bot:GetSuitPower() > 50 then
					
					bot:Flashlight( true )
					
				elseif bot:CanUseFlashlight() and bot:FlashlightIsOn() and !bot.Light then
					
					bot:Flashlight( false )
					
				end
				
				bot:HandleButtons()
				
			end
		end
	end

	
end)

-- Reset their AI on spawn.
hook.Add( "PlayerSpawn" , "TRizzleBotSpawnHook" , function( ply )
	
	if ply:IsBot() and ply.IsTRizzleBot then
		
		ply:TBotResetAI() -- For some reason running the a timer for 0.0 seconds works, but if I don't use a timer nothing works at all
		timer.Simple( 0.0 , function()
			
			if IsValid( ply ) and ply:Alive() then
				
				ply:SetModel( ply.PlayerModel )
				
			end
			
		end)
		
		timer.Simple( 0.3 , function()
		
			if IsValid( ply ) and ply:Alive() then
				
				if ply.SpawnWithWeapons then
					
					if !ply:HasWeapon( ply.Pistol ) then ply:Give( ply.Pistol ) end
					if !ply:HasWeapon( ply.Shotgun ) then ply:Give( ply.Shotgun ) end
					if !ply:HasWeapon( ply.Rifle ) then ply:Give( ply.Rifle ) end
					if !ply:HasWeapon( ply.Sniper ) then ply:Give( ply.Sniper ) end
					if !ply:HasWeapon( ply.Melee ) then ply:Give( ply.Melee ) end
					if !ply:HasWeapon( "weapon_medkit" ) then ply:Give( "weapon_medkit" ) end
					
				end
				
				-- For some reason the bot's run and walk speed is slower than the default
				--ply:SetRunSpeed( 600 )
				--ply:SetWalkSpeed( 400 )
				hook.Run( "SetPlayerSpeed", ply, 400, 600 )
				
			end
			
		end)
		
	end
	
end)

-- The main AI is here.
-- Deprecated: I have a newer think function, that is more responsive and optimized
--[[function BOT:TBotCreateThinking()
	
	local index		=	self:EntIndex()
	local timer_time	=	math.Rand( 0.08 , 0.15 )
	
	-- I used math.Rand as a personal preference, It just prevents all the timers being ran at the same time
	-- as other bots timers.
	timer.Create( "trizzle_bot_think" .. index , timer_time * 3 , 0 , function()
		
		if IsValid( self ) and self:Alive() and self.IsTRizzleBot then
			
			-- A quick condition statement to check if our enemy is no longer a threat.
			self:CheckCurrentEnemyStatus()
			self:TBotFindClosestEnemy()
			self:TBotCheckEnemyList()
			
			if !self:IsInCombat() then
			
				-- If the bot is not in combat then the bot should check if any of its teammates need healing
				self.HealTarget = self:TBotFindClosestTeammate()
				local botWeapon = self:GetActiveWeapon()
				if IsValid( self.HealTarget ) then
				
					self:SelectMedkit()
					
					if IsValid( botWeapon ) and botWeapon:IsWeapon() and botWeapon:GetClass() == "weapon_medkit" then
						
						if CurTime() > self.FireWeaponInterval and self.HealTarget == self then
						
							self.FireWeaponInterval = CurTime() + 0.5
							self:PressSecondaryAttack()
							
						elseif CurTime() > self.FireWeaponInterval and self:GetEyeTrace().Entity == self.HealTarget then
						
							self.FireWeaponInterval = CurTime() + 0.5
							self:PressPrimaryAttack()
							
						end
						
						if botWeapon:GetClass() == "weapon_medkit" and self.HealTarget != self then self:AimAtPos( self.HealTarget:WorldSpaceCenter(), CurTime() + 0.1, MEDIUM_PRIORITY ) end
						
					end
					
				else
				
					self:ReloadWeapons()
					
				end
				
				if IsValid( botWeapon ) and botWeapon:IsWeapon() and CurTime() > self.ReloadInterval and !botWeapon:GetInternalVariable( "m_bInReload" ) and botWeapon:GetClass() != "weapon_medkit" and botWeapon:Clip1() < botWeapon:GetMaxClip1() then
					self:PressReload()
					self.ReloadInterval = CurTime() + 1.0
				end
				
				self:RestoreAmmo() 
				
			elseif IsValid( self.Enemy ) then
			
				local trace = util.TraceLine( { start = self:GetShootPos(), endpos = self.Enemy:EyePos(), filter = self, mask = MASK_SHOT } )
				
				if trace.Entity == self.Enemy then
					
					self.AimForHead = true
					
				else
					
					self.AimForHead = false
					
				end
				
				-- Turn and face our enemy!
				if self.AimForHead and !self:IsActiveWeaponRecoilHigh() then
				
					-- Can we aim the enemy's head?
					self:AimAtPos( self.Enemy:EyePos(), CurTime() + 0.1, HIGH_PRIORITY )
				
				else
					
					-- If we can't aim at our enemy's head aim at the center of their body instead.
					self:AimAtPos( self.Enemy:WorldSpaceCenter(), CurTime() + 0.1, HIGH_PRIORITY )
				
				end
				
				local botWeapon = self:GetActiveWeapon()
				
				if IsValid( botWeapon ) and botWeapon:IsWeapon() and self.FullReload and ( botWeapon:Clip1() >= botWeapon:GetMaxClip1() or self:GetAmmoCount( botWeapon:GetPrimaryAmmoType() ) <= botWeapon:Clip1() or botWeapon:GetClass() != self.Shotgun ) then self.FullReload = false end -- Fully reloaded :)
				
				if IsValid( botWeapon ) and botWeapon:IsWeapon() and CurTime() > self.FireWeaponInterval and !botWeapon:GetInternalVariable( "m_bInReload" ) and !self.FullReload and botWeapon:GetClass() != "weapon_medkit" and ( self:GetEyeTraceNoCursor().Entity == self.Enemy or self:IsCursorOnTarget() or (self.Enemy:GetPos() - self:GetPos()):LengthSqr() < self.MeleeDist * self.MeleeDist ) then
					self:PressPrimaryAttack()
					self.FireWeaponInterval = CurTime() + math.Rand( 0.15 , 0.4 )
				end
				
				if IsValid( botWeapon ) and botWeapon:IsWeapon() and CurTime() > self.FireWeaponInterval and botWeapon:GetClass() == "weapon_medkit" and self.CombatHealThreshold > self:Health() then
					self:PressSecondaryAttack()
					self.FireWeaponInterval = CurTime() + 0.5
				end
				
				if IsValid( botWeapon ) and botWeapon:IsWeapon() and CurTime() > self.ReloadInterval and !botWeapon:GetInternalVariable( "m_bInReload" ) and botWeapon:Clip1() == 0 then
					if botWeapon:GetClass() == self.Shotgun then self.FullReload = true end
					self:PressReload()
					self.ReloadInterval = CurTime() + 1.0
				end
				
				self:SelectBestWeapon()
			
			end
			
			if self.Owner:InVehicle() and !self:InVehicle() then
			
				local vehicle = self:FindNearbySeat()
				
				if IsValid( vehicle ) then self:EnterVehicle( vehicle ) end -- I should make the bot press its use key instead of this hack
			
			end
			
			if !self.Owner:InVehicle() and self:InVehicle() then
			
				self:ExitVehicle() -- Should I make the bot press its use key instead?
			
			end
			
			if self.SpawnWithWeapons then
				
				if !self:HasWeapon( self.Pistol ) then self:Give( self.Pistol ) end
				if !self:HasWeapon( self.Shotgun ) then self:Give( self.Shotgun ) end
				if !self:HasWeapon( self.Rifle ) then self:Give( self.Rifle ) end
				if !self:HasWeapon( self.Sniper ) then self:Give( self.Sniper ) end
				if !self:HasWeapon( self.Melee ) then self:Give( self.Melee ) end
				if !self:HasWeapon( "weapon_medkit" ) then self:Give( "weapon_medkit" ) end
				
			end
			
			-- I have to set the flashlight state because some addons have mounted flashlights and I can't check if they are on or not, "This will prevent the flashlight on and off spam"
			if self:CanUseFlashlight() and !self:FlashlightIsOn() and self.Light and self:GetSuitPower() > 50 then
				
				self:Flashlight( true )
				
			elseif self:CanUseFlashlight() and self:FlashlightIsOn() and !self.Light then
				
				self:Flashlight( false )
				
			end
			
			self:HandleButtons()
			
		else
			
			timer.Remove( "trizzle_bot_think" .. index ) -- We don't need to think while dead.
			
		end
		
	end)
	
end]]

-- Makes the bot react to damage taken by enemies
hook.Add( "PlayerHurt" , "TRizzleBotPlayerHurt" , function( victim, attacker )

	if !IsValid( attacker ) or !IsValid( victim ) or !victim.IsTRizzleBot or !victim:IsBot() or attacker:IsPlayer() then return end
	
	if attacker:IsNPC() and !victim.EnemyList[ attacker:GetCreationID() ] and attacker:IsAlive() and ( attacker:Disposition( victim ) == D_HT or attacker:Disposition( victim.Owner ) == D_HT ) then

		victim.EnemyList[ attacker:GetCreationID() ]		=	{ Enemy = attacker, LastSeenTime = CurTime() + 10.0 }
	
	end

end)

-- Makes the bot react to sounds made by enemies
hook.Add( "EntityEmitSound" , "TRizzleBotEntityEmitSound" , function( soundTable )
	
	for k, bot in ipairs( player.GetBots() ) do
		
		if !IsValid( bot ) or !bot.IsTRizzleBot or !IsValid( soundTable.Entity ) or soundTable.Entity:IsPlayer() or soundTable.Entity == bot then return end
	
		if soundTable.Entity:IsNPC() and !bot.EnemyList[ soundTable.Entity:GetCreationID() ] and soundTable.Entity:IsAlive() and (soundTable.Entity:Disposition( bot ) == D_HT or soundTable.Entity:Disposition( bot.Owner ) == D_HT) and (soundTable.Entity:GetPos() - bot:GetPos()):LengthSqr() < ( ( 1000 * ( soundTable.SoundLevel / 100 ) ) * ( 1000 * ( soundTable.SoundLevel / 100 ) ) ) then
			
			bot.EnemyList[ soundTable.Entity:GetCreationID() ]		=	{ Enemy = soundTable.Entity, LastSeenTime = CurTime() + 10.0 }
			
		end
		
	end
	
	return
end)

-- Checks if the NPC is alive
function Npc:IsAlive()
	if !IsValid( self ) then return false end
	
	if self:GetNPCState() == NPC_STATE_DEAD then return false
	elseif self:GetInternalVariable( "m_lifeState" ) != 0 then return false end
	
	return true
		
end

-- Checks if its current enemy is still alive and still visible to the bot
function BOT:CheckCurrentEnemyStatus()
	
	if !IsValid( self.Enemy ) then self.Enemy							=	nil
	elseif self.Enemy:IsPlayer() and !self.Enemy:Alive() then self.Enemy				=	nil -- Just incase the bot's enemy is set to a player even though the bot should only target NPCS and "hopefully" NEXTBOTS 
	elseif !self.Enemy:Visible( self ) or self.IsTRizzleBotBlind or self:IsHiddenByFog( self:GetShootPos():Distance( self.Enemy:EyePos() ) ) then self.Enemy						=	nil
	elseif self.Enemy:IsNPC() and ( !self.Enemy:IsAlive() or (self.Enemy:Disposition( self ) != D_HT and self.Enemy:Disposition( self.Owner ) != D_HT) ) then self.Enemy	=	nil
	elseif GetConVar( "ai_ignoreplayers" ):GetInt() != 0 or GetConVar( "ai_disabled" ):GetInt() != 0 then self.Enemy	=	nil end
	
end

-- This checks every enemy on the bot's Known Enemy List and checks to see if they are alive, visible, and valid
function BOT:TBotCheckEnemyList()
	if ( ( engine:TickCount() + self:EntIndex() ) % 5 ) != 0 then return end -- This shouldn't run as often
	--print( table.Count( self.EnemyList ) )
	
	for k, v in pairs( self.EnemyList ) do
		
		-- I don't think I have to use this
		--local enemy = self.EnemyList[ k ][ "Enemy" ]
		--local lastSeenTime = self.EnemyList[ k ][ "LastSeenTime" ]
		
		--print( k )
		--print( v )
		
		if !IsValid( v.Enemy ) then
			
			self.EnemyList[ k ] = nil
			continue
			
		elseif v.Enemy:IsPlayer() and !v.Enemy:Alive() then 
			
			self.EnemyList[ k ] = nil -- Just incase the bot's enemy is set to a player even though the bot should only target NPCS and "hopefully" NEXTBOTS
			continue
			
		elseif v.Enemy:IsNPC() and ( !v.Enemy:IsAlive() or (v.Enemy:Disposition( self ) != D_HT and v.Enemy:Disposition( self.Owner ) != D_HT) ) then 
			
			self.EnemyList[ k ] = nil
			continue
			
		elseif GetConVar( "ai_ignoreplayers" ):GetInt() != 0 or GetConVar( "ai_disabled" ):GetInt() != 0 then 
			
			self.EnemyList[ k ] = nil
			continue
			
		elseif ( !v.Enemy:Visible( self ) or self.IsTRizzleBotBlind or self:IsHiddenByFog( self:GetShootPos():Distance( v.Enemy:EyePos() ) ) ) and v.LastSeenTime < CurTime() then 
			
			self.EnemyList[ k ] = nil
			continue
		
		elseif !self.IsTRizzleBotBlind and v.Enemy:Visible( self ) and !self:IsHiddenByFog( self:GetShootPos():Distance( v.Enemy:EyePos() ) ) then 
		
			self.EnemyList[ k ][ "LastSeenTime" ] = CurTime() + 10.0 
			
		end
		
	end
end

-- Target any hostile NPCS that is visible to us.
function BOT:TBotFindClosestEnemy()
	local VisibleEnemies			=	self.EnemyList -- This is how many enemies the bot can see. Currently not used......yet
	local targetdistsqr			=	100000000 -- This will allow the bot to select the closest enemy to it.
	local target				=	self.Enemy -- This is the closest enemy to the bot.
	
	if ( ( engine:TickCount() + self:EntIndex() ) % 5 ) != 0 then return end -- This shouldn't run as often
	if GetConVar( "ai_ignoreplayers" ):GetInt() != 0 or GetConVar( "ai_disabled" ):GetInt() != 0 then return end
	
	for k, v in ipairs( ents.GetAll() ) do
		
		if IsValid ( v ) and v:IsNPC() and v:IsAlive() and (v:Disposition( self ) == D_HT or v:Disposition( self.Owner ) == D_HT) then -- The bot should attack any NPC that is hostile to them or their owner. D_HT means hostile/hate
			
			local enemydistsqr = (v:GetPos() - self:GetPos()):LengthSqr()
			if self:IsAbleToSee( v ) then
				
				if !VisibleEnemies[ v:GetCreationID() ] then VisibleEnemies[ v:GetCreationID() ]		=	{ Enemy = v, LastSeenTime = CurTime() + 10.0 } end -- We grab the entity's Creation ID because the will never be the same as any other entity.
				
				if enemydistsqr < targetdistsqr then 
					target = v
					targetdistsqr = enemydistsqr
				end
				
			elseif VisibleEnemies[ v:GetCreationID() ] and v:Visible( self ) and !self:IsHiddenByFog( self:GetShootPos():Distance( v:EyePos() ) ) then
				
				if ( !IsValid( target ) or enemydistsqr < 40000 ) and enemydistsqr < targetdistsqr then 
					target = v
					targetdistsqr = enemydistsqr
				end
			
			end
		end
		
	end
	
	self.Enemy			=	target
	self.EnemyList		=	VisibleEnemies
	
end

-- Heal any player or bot that is visible to us.
function BOT:TBotFindClosestTeammate()
	local targetdistsqr			=	6400 -- This will allow the bot to select the closest teammate to it.
	local target				=	nil -- This is the closest teammate to the bot.
	
	--The bot should heal its owner and itself before it heals anyone else
	if IsValid( self.Owner ) and self.Owner:Alive() and self.Owner:Health() < self.HealThreshold and (self.Owner:GetPos() - self:GetPos()):LengthSqr() < 6400 then return self.Owner
	elseif self:Health() < self.HealThreshold then return self end

	for k, v in ipairs( player.GetAll() ) do
		
		if IsValid ( v ) and v:Alive() and v:Health() < self.HealThreshold and !self.IsTRizzleBotBlind and v:Visible( self ) then -- The bot will heal any teammate that needs healing that we can actually see and are alive.
			local teammatedistsqr = (v:GetPos() - self:GetPos()):LengthSqr()
			if teammatedistsqr < targetdistsqr then 
				target = v
				targetdist = teammatedist
			end
		end
	end
	
	return target
	
end

function BOT:FindNearbySeat()
	
	local targetdistsqr			=	40000 -- This will allow the bot to select the closest vehicle to it.
	local target				=	nil -- This is the closest vehicle to the bot.
	
	for k, v in ipairs( ents.GetAll() ) do
		
		if IsValid ( v ) and v:IsVehicle() and !IsValid( v:GetDriver() ) then -- The bot should enter the closest vehicle to it
			
			local vehicledistsqr = (v:GetPos() - self:GetPos()):LengthSqr()
			
			if vehicledistsqr < targetdistsqr then 
				target = v
				targetdistsqr = vehicledistsqr
			end
			
		end
		
	end
	
	return target
	
end

function TRizzleBotRangeCheck( FirstNode , SecondNode , Ladder , Height )
	-- Some helper errors.
	if !IsValid( FirstNode ) then error( "Bad argument #1 CNavArea expected got " .. type( FirstNode ) ) end
	if !IsValid( FirstNode ) then error( "Bad argument #2 CNavArea expected got " .. type( SecondNode ) ) end
	
	if Ladder then return Ladder:GetLength() end
	
	DefaultCost = FirstNode:GetCenter():Distance( SecondNode:GetCenter() )
	
	if isnumber( Height ) and Height > 32 then
		
		DefaultCost		=	DefaultCost * 5
		-- Jumping is slower than ground movement.
		
	end
	
	if isnumber( Height ) and -Height > 32 then
	
		DefaultCost		=	DefaultCost + ( GetApproximateFallDamage( math.abs( Height ) ) * 5 )
		-- Falling is risky and the bot might take fall damage.
		
	end
	
	-- Crawling through a vent is very slow.
	if SecondNode:HasAttributes( NAV_MESH_CROUCH ) then 
		
		DefaultCost	=	DefaultCost * 8
		
	end
	
	-- The bot should avoid this area unless alternatives are too dangerous or too far.
	if SecondNode:HasAttributes( NAV_MESH_AVOID ) then 
		
		DefaultCost	=	DefaultCost * 20
		
	end
	
	-- We will try not to swim since it can be slower than running on land, it can also be very dangerous, Ex. "Acid, Lava, Etc."
	if SecondNode:IsUnderwater() then
	
		DefaultCost		=	DefaultCost * 2
		
	end
	
	return DefaultCost
end

-- Got this from CS:GO Source Code, made some changes so it works for Lua
-- Returns approximately how much damage will will take from the given fall height
function GetApproximateFallDamage( height )
	-- CS:GO empirically discovered height values, this may return incorrect results for Gmod
	local slope = 0.2178
	local intercept = 26.0

	local damage = slope * height - intercept

	if damage < 0.0 then
		return 0.0
	end

	return damage
end

-- This is a hybrid version of pathfollower, it can use ladders and is very optimized
function TRizzleBotPathfinderCheap( StartNode , GoalNode )
	if !IsValid( StartNode ) or !IsValid( GoalNode ) then return false end
	if StartNode == GoalNode then return true end
	
	StartNode:ClearSearchLists()
	
	StartNode:AddToOpenList()
	
	StartNode:SetCostSoFar( 0 )
	
	StartNode:SetTotalCost( TRizzleBotRangeCheck( StartNode , GoalNode ) )
	
	StartNode:UpdateOnOpenList()
	
	local Final_Path		=	{}
	local Trys			=	0 -- Backup! Prevent crashing.
	local GoalCen			=	GoalNode:GetCenter()
	
	while ( !StartNode:IsOpenListEmpty() and Trys < 50000 ) do
		Trys	=	Trys + 1
		
		local Current	=	StartNode:PopOpenList()
		
		if Current == GoalNode then
			
			return TRizzleBotRetracePathCheap( StartNode , GoalNode )
		end
		
		local searchWhere = 0
		
		local NORTH = 0
		local EAST = 1
		local SOUTH = 2
		local WEST = 3
		local NUM_DIRECTIONS = 4
		
		local AHEAD = 0
		local LEFT = 1
		local RIGHT = 2
		local BEHIND = 3
		
		local LADDER_UP = 0
		local LADDER_DOWN = 1
		
		local GO_LADDER_UP = 4
		local GO_LADDER_DOWN = 5
		
		local searchIndex = 1
		local dir = NORTH
		local ladderUp = true
		
		local floorList = Current:GetAdjacentAreasAtSide( NORTH )
		local ladderList = nil
		local ladderTopDir = 0
		
		while ( true ) do
		
			local newArea = nil
			local how = nil
			local ladder = nil
		
			if searchWhere == 0 then
			
				if searchIndex > #floorList then
				
					dir = dir + 1
					
					if dir == NUM_DIRECTIONS then
					
						searchWhere = 1
						ladderList = Current:GetLaddersAtSide( LADDER_UP )
						searchIndex = 1
						ladderTopDir = AHEAD
						
					else
					
						floorList = Current:GetAdjacentAreasAtSide( dir )
						searchIndex = 1
						
					end
					
					continue
					
				end
				
				newArea = floorList[ searchIndex ]
				how = dir
				searchIndex = searchIndex + 1
				
			elseif searchWhere == 1 then
			
				if searchIndex > #ladderList then
					
					if !ladderUp then
						
						searchWhere = 2
						searchIndex = 1
						ladder = nil
						
					else
						
						ladderUp = false
						ladderList = Current:GetLaddersAtSide( LADDER_DOWN )
						searchIndex = 1
						
					end
					
					continue
					
				end
				
				if ladderUp then
				
					ladder = ladderList[ searchIndex ]
				
					if ladderTopDir == AHEAD then
					
						newArea = ladder:GetTopForwardArea()
						
					elseif ladderTopDir == LEFT then
					
						newArea = ladder:GetTopLeftArea()
						
					elseif ladderTopDir == RIGHT then
					
						newArea = ladder:GetTopRightArea()
						
					elseif ladderTopDir == BEHIND then
					
						newArea = ladder:GetTopBehindArea()
						
					else
					
						searchIndex = searchIndex + 1
						ladderTopDir = AHEAD
						continue
						
					end
					
					how = GO_LADDER_UP
					ladderTopDir = ladderTopDir + 1
				
				else
				
					ladder = ladderList[ searchIndex ]
					newArea = ladder:GetBottomArea()
					how = GO_LADDER_DOWN
					searchIndex = searchIndex + 1
					
				end
				
				if !IsValid( newArea ) then
				
					continue
					
				end
			
			else
			
				break
				
			end
		
			if newArea == area then 
			
				continue
				
			end
			
			local Height	=	Current:ComputeAdjacentConnectionHeightChange( newArea )
			-- Optimization,Prevent computing the height twice.
			
			local NewCostSoFar		=	Current:GetCostSoFar() + TRizzleBotRangeCheck( Current , newArea , ladder , Height )
			
			if !IsValid( ladder ) and !Current:IsUnderwater() and !newArea:IsUnderwater() and -Height < 200 and Height > 64 then
				-- We can't jump that high.
				
				continue
			end
			
			
			if ( newArea:IsOpen() or newArea:IsClosed() ) and newArea:GetCostSoFar() <= NewCostSoFar then
				
				continue
				
			else
				
				newArea:SetCostSoFar( NewCostSoFar )
				newArea:SetTotalCost( NewCostSoFar + TRizzleBotRangeCheck( newArea , GoalNode ) )
				
				if newArea:IsClosed() then
					
					newArea:RemoveFromClosedList()
					
				end
				
				if newArea:IsOpen() then
					
					newArea:UpdateOnOpenList()
					
				else
					
					newArea:AddToOpenList()
					
				end
				
				
				newArea:SetParent( Current, how )
			end
			
			
		end
		
		Current:AddToClosedList()
		
	end
	
	
	return false
end

function TRizzleBotRetracePathCheap( StartNode , GoalNode )
	
	local GO_LADDER_UP = 4
	local GO_LADDER_DOWN = 5
	
	local Trys			=	0 -- Backup! Prevent crashing.
	-- I need to check if this works
	--local NewPath	=	{ { area = GoalNode, how = GoalNode:GetParentHow() } }
	local NewPath	=	{ GoalNode }
	
	local Current	=	GoalNode
	
	while( Current:GetParent() != StartNode and Trys < 50001 ) do
	
		Current		=	Current:GetParent()
		Parent		=	Current:GetParentHow()
		
		--print( Current )
		--print( Parent )
		
		if Parent == GO_LADDER_UP or Parent == GO_LADDER_DOWN then
		
			local list = Current:GetLadders()
			--print( "Ladders: " .. #list )
			for k, ladder in ipairs( list ) do
				--print( ladder:GetTopForwardArea() )
				--print( ladder:GetTopLeftArea() )
				--print( ladder:GetTopRightArea() )
				--print( ladder:GetTopBehindArea() )
				--print( ladder:GetBottomArea() )
				if ladder:GetTopForwardArea() == Current or ladder:GetTopLeftArea() == Current or ladder:GetTopRightArea() == Current or ladder:GetTopBehindArea() == Current or ladder:GetBottomArea() == Current then
					local currentIndex = #NewPath
					NewPath[ currentIndex + 1 ] = { area = Current, how = Parent }
					NewPath[ currentIndex + 2 ] = { area = ladder, how = Parent }
					break
					
				end
			end
		
		else
			
			NewPath[ #NewPath + 1 ] = { area = Current, how = Parent }
			
		end
		
	end
	
	NewPath[ #NewPath + 1 ] = { area = StartNode, how = Current:GetParentHow() }
	
	return NewPath
end

function BOT:TBotSetNewGoal( NewGoal )
	if !isvector( NewGoal ) then error( "Bad argument #1 vector expected got " .. type( NewGoal ) ) end
	
	if self.PathTime < CurTime() then
		self.Goal				=	NewGoal
		self.Path				=	{}
		self.PathTime			=	CurTime() + 0.5
		self:TBotCreateNavTimer()
	end
	
end






-- A handy function for range checking.
local function IsVecCloseEnough( start , endpos , dist )
	
	return start:DistToSqr( endpos ) < dist * dist
	
end

local function CheckLOS( val , pos1 , pos2 )
	
	local Trace				=	util.TraceLine({
		
		start				=	pos1 + Vector( val , 0 , 0 ),
		endpos				=	pos2 + Vector( val , 0 , 0 ),
		collisiongroup 		=	COLLISION_GROUP_DEBRIS,
		
	})
	
	if Trace.Hit then return false end
	
	Trace					=	util.TraceLine({
		
		start				=	pos1 + Vector( -val , 0 , 0 ),
		endpos				=	pos2 + Vector( -val , 0 , 0 ),
		collisiongroup 		=	COLLISION_GROUP_DEBRIS,
		
	})
	
	if Trace.Hit then return false end
	
	
	Trace					=	util.TraceLine({
		
		start				=	pos1 + Vector( 0 , val , 0 ),
		endpos				=	pos2 + Vector( 0 , val , 0 ),
		collisiongroup 		=	COLLISION_GROUP_DEBRIS,
		
	})
	
	if Trace.Hit then return false end
	
	Trace					=	util.TraceLine({
		
		start				=	pos1 + Vector( 0 , -val , 0 ),
		endpos				=	pos2 + Vector( 0 , -val , 0 ),
		collisiongroup 		=	COLLISION_GROUP_DEBRIS,
		
	})
	
	if Trace.Hit then return false end
	
	return true
end

local function SendBoxedLine( pos1 , pos2 )
	if !isvector( pos1 ) or !isvector( pos2 ) then return false end
	
	local Trace				=	util.TraceLine({
		
		start				=	pos1 + Vector( 0 , 0 , 15 ),
		endpos				=	pos2 + Vector( 0 , 0 , 15 ),
		
		filter				=	self,
		collisiongroup 		=	COLLISION_GROUP_DEBRIS,
		
	})
	
	if Trace.Hit then return false end
	
	for i = 1, 12 do
		
		if CheckLOS( 3 * i , pos1 , pos2 ) == false then return false end
		
	end
	
	local HullTrace			=	util.TraceHull({
		
		mins				=	Vector( -16 , -16 , 0 ),
		maxs				=	Vector( 16 , 16 , 71 ),
		
		start				=	position,
		endpos				=	position,
		
		filter				=	self,
		collisiongroup 		=	COLLISION_GROUP_DEBRIS,
		
	})
	
	if HullTrace.Hit then return false end
	
	return true
end

-- Creates waypoints using the nodes.
function BOT:ComputeNavmeshVisibility()
	
	local NORTH = 0
	local EAST = 1
	local SOUTH = 2
	local WEST = 3
	
	self.Path				=	{}
	
	local LastVisPos		=	self:GetPos()
	
	for k, v in ipairs( self.NavmeshNodes ) do
		-- I should also make sure that the nodes exist as this is called 0.03 seconds after the pathfind.
		
		local CurrentNode	=	v.area
		local currentIndex	=	#self.Path
		local Drop			=	false
		
		if !self.NavmeshNodes[ k + 1 ] or !self.NavmeshNodes[ k + 1 ].area or !self.NavmeshNodes[ k + 1 ].how then
			
			self.Path[ #self.Path + 1 ]		=	{ Pos = self.Goal, IsLadder = false, IsDropDown = self:ShouldDropDown( LastVisPos, self.Goal ) }
			
			break
		end
		
		local NextNode		=	self.NavmeshNodes[ k + 1 ].area
		local NextHow		=	self.NavmeshNodes[ k + 1 ].how
		
		if NextNode:Node_Get_Type() == 2 then
		
			local CloseToStart, ClimbUp		=	NextNode:Get_Closest_Point( LastVisPos )
			
			LastVisPos		=	CloseToStart
			
			self.Path[ #self.Path + 1 ]		=	{ Pos = CloseToStart, IsLadder = true, LadderUp = ClimbUp }
			
			continue
		end
		
		if CurrentNode:Node_Get_Type() == 2 then
		
			local CloseToEnd, ClimbUp		=	CurrentNode:Get_Closest_Point( NextNode:GetCenter() )
			
			LastVisPos		=	CloseToEnd
			
			self.Path[ #self.Path + 1 ]		=	{ Pos = CloseToEnd, IsLadder = true, LadderUp = ClimbUp }
			
			continue
		end
		
		local connection, area = Get_Blue_Connection( CurrentNode, NextNode )
		
		if self:ShouldDropDown( LastVisPos, connection ) then
		
			local dir = vector_origin
			Drop = true
			
			if NextHow == NORTH then 
				dir.x = 0 
				dir.y = -1
			elseif NextHow == SOUTH then 
				dir.x = 0 
				dir.y = 1
			elseif NextHow == EAST then 
				dir.x = 1 
				dir.y = 0
			elseif NextHow == WEST then 
				dir.x = -1 
				dir.y = 0 
			end
			
			-- Should I use 75 instead?
			connection.x = connection.x + ( 25.0 * dir.x )
			connection.y = connection.y + ( 25.0 * dir.y )
			
			self.Path[ currentIndex + 1 ]			=	{ Pos = connection, IsLadder = false, Check = area, IsDropDown = Drop }
			
			connection.z = NextNode:GetZ( LastVisPos )
			
			self.Path[ currentIndex + 2 ]			=	{ Pos = connection, IsLadder = false, IsDropDown = Drop }
			
			LastVisPos							=	connection
			
			continue
		end
		
		self.Path[ #self.Path + 1 ]			=	{ Pos = connection, IsLadder = false, Check = area, IsDropDown = Drop }
		
		LastVisPos							=	connection
		
	end
	
end


-- The main navigation code ( Waypoint handler )
function BOT:TBotNavigation()
	if !isvector( self.Goal ) then return end -- A double backup!
	
	-- The CNavArea we are standing on.
	self.StandingOnNode			=	navmesh.GetNearestNavArea( self:GetPos() )
	if !IsValid( self.StandingOnNode ) then return end -- The map has no navmesh.
	
	
	if !istable( self.Path ) or !istable( self.NavmeshNodes ) or table.IsEmpty( self.Path ) or table.IsEmpty( self.NavmeshNodes ) then
		
		
		if self.BlockPathFind != true then
			
			
			-- Get the nav area that is closest to our goal.
			local TargetArea		=	navmesh.GetNearestNavArea( self.Goal )
			
			self.Path				=	{} -- Reset that.
			
			-- Pathfollower is not only cheaper, but it can use ladders.
			self.NavmeshNodes		=	TRizzleBotPathfinderCheap( self.StandingOnNode , TargetArea )
			
			-- There is no way we can get there! Remove our goal.
			if self.NavmeshNodes == false then
				
				-- In case we fail. A* will search the whole map to find out there is no valid path.
				-- This can cause major lag if the bot is doing this almost every think.
				-- To prevent this, We block the bots pathfinding completely for a while before allowing them to pathfind again.
				-- So its not as bad.
				self.BlockPathFind		        =	true
				self.Goal				=	nil
				
				timer.Simple( 1.0 , function() -- Prevent spamming the path finder.
					
					if IsValid( self ) then
						
						self.BlockPathFind		=	false
						
					end
					
				end)
				
			else
			
				-- Prevent spamming the pathfinder.
				self.BlockPathFind		=	true
				timer.Simple( 0.50 , function()
					
					if IsValid( self ) then
						
						self.BlockPathFind		=	false
						
					end
					
				end)
				
				
				-- Give the computer some time before it does more expensive checks.
				timer.Simple( 0.03 , function()
					
					-- If we can get there and is not already there, Then we will compute the visiblilty.
					if IsValid( self ) and istable( self.NavmeshNodes ) then
						
						self.NavmeshNodes	=	table.Reverse( self.NavmeshNodes )
						
						self:ComputeNavmeshVisibility()
						
					end
					
				end)
				
			end
			
		end
		
		
	end
	
	
	if istable( self.Path ) then
		
		if self.Path[ 1 ] then
			
			local Waypoint2D		=	Vector( self.Path[ 1 ][ "Pos" ].x , self.Path[ 1 ][ "Pos" ].y , self:GetPos().z )
			-- ALWAYS: Use 2D navigation, It helps by a large amount.
			
			if !self.Path[ 1 ][ "IsLadder" ] and !self.Path[ 1 ][ "IsDropDown" ] and IsVecCloseEnough( self:GetPos() , Waypoint2D , 24 ) then
				
				table.remove( self.Path , 1 )
				
			elseif !self.Path[ 1 ][ "IsLadder" ] and self.Path[ 1 ][ "IsDropDown" ] and !self:ShouldDropDown( self:GetPos(), self.Path[ 1 ][ "Pos" ] ) then
				
				table.remove( self.Path , 1 )
				
			elseif self.Path[ 1 ][ "IsLadder" ] and self.Path[ 1 ][ "LadderUp" ] and ( self:GetPos().z >= self.Path[ 1 ][ "Pos" ].z or IsVecCloseEnough( self:GetPos() , Waypoint2D , 8 ) ) then
				
				if self.Path[ 2 ] and !self.Path[ 2 ][ "IsLadder" ] then
					self:PressJump()
					self.NextJump =	CurTime()
				end
				
				table.remove( self.Path , 1 )
				
			elseif self.Path[ 1 ][ "IsLadder" ] and !self.Path[ 1 ][ "LadderUp" ] and self:GetPos().z <= self.Path[ 1 ][ "Pos" ].z and IsVecCloseEnough( self:GetPos() , Waypoint2D , 8 ) then
			
				if self.Path[ 2 ] and !self.Path[ 2 ][ "IsLadder" ] then
					self:PressJump()
					self.NextJump = CurTime()
				end
				
				table.remove( self.Path , 1 )
			
			end
			--[[elseif IsVecCloseEnough( self:GetPos() , Waypoint2D , 8 ) then -- This is a backup this should never happen
			
				table.remove( self.Path , 1 )
			
			end]]
			
		end
		
	end
	
	
end

-- The navigation and navigation debugger for when a bot is stuck.
function BOT:TBotCreateNavTimer()
	
	local index			=	self:EntIndex()
	local LastBotPos		=	self:GetPos()
	local Attempts			=	0
	
	
	timer.Create( "trizzle_bot_nav" .. index , 0.09 , 0 , function()
		
		if IsValid( self ) and self:Alive() and isvector( self.Goal ) then
			
			self:TBotNavigation()
			
			self:TBotDebugWaypoints()
			
			if self:Is_On_Ladder() then return end
			
			LastBotPos		=	Vector( LastBotPos.x , LastBotPos.y , self:GetPos().z )
			
			if IsVecCloseEnough( self:GetPos() , LastBotPos , 2 ) then
				
				self:PressJump()
				self.ShouldUse	=	true
				
				if Attempts == 10 then self.Path	=	nil end
				if Attempts > 20 then self.Goal =	nil end
				Attempts = Attempts + 1
				
			else
				Attempts = 0
			end
			LastBotPos		=	self:GetPos()
			
		else
			
			timer.Remove( "trizzlebot_nav" .. index )
			
		end
		
	end)
	
end



-- A handy debugger for the waypoints.
-- Requires developer set to 1 in console
function BOT:TBotDebugWaypoints()
	if !istable( self.Path ) then return end
	if table.IsEmpty( self.Path ) then return end
	
	debugoverlay.Line( self.Path[ 1 ][ "Pos" ] , self:GetPos() + Vector( 0 , 0 , 44 ) , 0.08 , Color( 0 , 255 , 255 ) )
	debugoverlay.Sphere( self.Path[ 1 ][ "Pos" ] , 8 , 0.08 , Color( 0 , 255 , 255 ) , true )
	
	for k, v in ipairs( self.Path ) do
		
		if self.Path[ k + 1 ] then
			
			debugoverlay.Line( v[ "Pos" ] , self.Path[ k + 1 ][ "Pos" ] , 0.08 , Color( 255 , 255 , 0 ) )
			
		end
		
		debugoverlay.Sphere( v[ "Pos" ] , 8 , 0.08 , Color( 255 , 200 , 0 ) , true )
		
	end
	
end

-- Make the bot move.
function BOT:TBotUpdateMovement( cmd )
	if !isvector( self.Goal ) then return end
	
	local LookTargetPriorityTemp	=	LOW_PRIORITY
	
	if !istable( self.Path ) or table.IsEmpty( self.Path ) or isbool( self.NavmeshNodes ) then
		
		local MovementAngle		=	( self.Goal - self:GetPos() ):GetNormalized():Angle()
		
		if self:OnGround() then
			local SmartJump		=	util.TraceLine({
				
				start			=	self:GetPos(),
				endpos			=	self:GetPos() + Vector( 0 , 0 , -16 ),
				filter			=	self,
				mask			=	MASK_SOLID,
				collisiongroup	=	COLLISION_GROUP_DEBRIS
				
			})
			
			-- This tells the bot to jump if it detects a gap in the ground
			if !SmartJump.Hit then
				
				self:PressJump()

			end
		end
		
		if self:Is_On_Ladder() then LookTargetPriorityTemp = MAXIMUM_PRIORITY end
		
		cmd:SetViewAngles( MovementAngle )
		cmd:SetForwardMove( self:GetRunSpeed() )
		self:AimAtPos( self.Goal + Vector( 0 , 0 , 64 ), CurTime() + 0.1, LookTargetPriorityTemp )
		
		local GoalIn2D			=	Vector( self.Goal.x , self.Goal.y , self:GetPos().z )
		if IsVecCloseEnough( self:GetPos() , GoalIn2D , 32 ) then
			
			self.Goal			=		nil -- We have reached our goal!
			
		end
		
		return
	end
	
	if self.Path[ 1 ] then
		
		local MovementAngle		=	( self.Path[ 1 ][ "Pos" ] - self:GetPos() ):GetNormalized():Angle()
		
		if isvector( self.Path[ 1 ][ "Check" ] ) then
			MovementAngle = ( self.Path[ 1 ][ "Check" ] - self:GetPos() ):GetNormalized():Angle()
			
			local CheckIn2D			=	Vector( self.Path[ 1 ][ "Check" ].x , self.Path[ 1 ][ "Check" ].y , self:GetPos().z )
			
			if IsVecCloseEnough( self:GetPos() , CheckIn2D , 24 ) then
				
				self.Path[ 1 ][ "Check" ] = nil
				return
			end
			
			if SendBoxedLine( self:GetPos() , CheckIn2D ) == true then
			
				self.Path[ 1 ][ "Check" ] = nil
			end
		end
		
		if self:OnGround() and !self.Path[ 1 ][ "IsLadder" ] and !self.Path[ 1 ][ "IsDropDown" ] then
			local SmartJump		=	util.TraceLine({
				
				start			=	self:GetPos(),
				endpos			=	self:GetPos() + Vector( 0 , 0 , -16 ),
				filter			=	self,
				mask			=	MASK_SOLID,
				collisiongroup	        =	COLLISION_GROUP_DEBRIS
				
			})
			
			-- This tells the bot to jump if it detects a gap in the ground
			if !SmartJump.Hit then
				
				self:PressJump()

			end
		end
		
		if self:Is_On_Ladder() or self.Path[ 1 ][ "IsLadder" ] then LookTargetPriorityTemp = MAXIMUM_PRIORITY end
		
		cmd:SetViewAngles( MovementAngle )
		cmd:SetForwardMove( 1000 )
		self:AimAtPos( self.Path[ 1 ][ "Pos" ] + Vector( 0 , 0 , 64 ), CurTime() + 0.1, LookTargetPriorityTemp )
		
	end
	
end

local function NumberMidPoint( num1 , num2 )
	
	local sum = num1 + num2
	
	return sum / 2
	
end

-- This function techically gets the center crossing point of the smallest area.
-- This is 90% of the time where the blue connection point is.
-- So keep in mind this will rarely give inaccurate results.
function Get_Blue_Connection( CurrentArea , TargetArea )
	if !IsValid( TargetArea ) or !IsValid( CurrentArea ) then return end
	local dir = Get_Direction( CurrentArea , TargetArea )
	
	local NORTH = 0
	local EAST = 1
	local SOUTH = 2
	local WEST = 3
	
	if dir == NORTH or dir == SOUTH then
		
		if TargetArea:GetSizeX() >= CurrentArea:GetSizeX() then
			
			local Vec	=	NumberMidPoint( CurrentArea:GetCorner( NORTH ).y , CurrentArea:GetCorner( EAST ).y )
			
			local NavPoint = Vector( CurrentArea:GetCenter().x , Vec , 0 )
			
			return TargetArea:GetClosestPointOnArea( NavPoint ), Vector( NavPoint.x , CurrentArea:GetCenter().y , CurrentArea:GetZ( NavPoint ) )
		else
			
			local Vec	=	NumberMidPoint( TargetArea:GetCorner( NORTH ).y , TargetArea:GetCorner( EAST ).y )
			
			local NavPoint = Vector( TargetArea:GetCenter().x , Vec , 0 )
			
			
			return TargetArea:GetClosestPointOnArea( CurrentArea:GetClosestPointOnArea( NavPoint ) ), Vector( NavPoint.x , CurrentArea:GetCenter().y , CurrentArea:GetZ( NavPoint ) )
		end	
		
		return
	end
	
	if dir == EAST or dir == WEST then
		
		if TargetArea:GetSizeY() >= CurrentArea:GetSizeY() then
			
			local Vec	=	NumberMidPoint( CurrentArea:GetCorner( NORTH ).x , CurrentArea:GetCorner( WEST ).x )
			
			local NavPoint = Vector( Vec , CurrentArea:GetCenter().y , 0 )
			
			
			return TargetArea:GetClosestPointOnArea( NavPoint ), Vector( CurrentArea:GetCenter().x , NavPoint.y , CurrentArea:GetZ( NavPoint ) )
		else
			
			local Vec	=	NumberMidPoint( TargetArea:GetCorner( NORTH ).x , TargetArea:GetCorner( WEST ).x )
			
			local NavPoint = Vector( Vec , TargetArea:GetCenter().y , 0 )
			
			
			return TargetArea:GetClosestPointOnArea( CurrentArea:GetClosestPointOnArea( NavPoint ) ), Vector( CurrentArea:GetCenter().x , NavPoint.y , CurrentArea:GetZ( NavPoint ) )
		end
		
	end
	
end

function Get_Direction( FirstArea , SecondArea )
	
	if FirstArea:GetSizeX() + FirstArea:GetSizeY() > SecondArea:GetSizeX() + SecondArea:GetSizeY() then
		
		return SecondArea:ComputeDirection( SecondArea:GetClosestPointOnArea( FirstArea:GetClosestPointOnArea( SecondArea:GetCenter() ) ) )
		
	else
		
		return FirstArea:ComputeDirection( FirstArea:GetClosestPointOnArea( SecondArea:GetClosestPointOnArea( FirstArea:GetCenter() ) ) )
		
	end
	
end

-- This checks if we should drop down to reach the next node
function BOT:ShouldDropDown( curentArea, nextArea )
	if !IsValid( curentArea ) or !IsValid( nextArea ) then return false end
	
	return curentArea.z - nextArea.z > self:GetStepSize()
	
end

-- This checks if we should jump to reach the next node
function BOT:ShouldJump( curentArea, nextArea )
	if !IsValid( curentArea ) or !IsValid( nextArea ) then return false end
	
	return nextArea.z - curentArea.z > self:GetStepSize()
	
end

function BOT:Is_On_Ladder()
	
	if self:GetMoveType() == MOVETYPE_LADDER then
		
		return true
	end
	
	return false
end

function Lad:Get_Closest_Point( pos )
	
	local TopArea	=	self:GetTop():Distance( pos )
	local LowArea	=	self:GetBottom():Distance( pos )
	
	if TopArea < LowArea then
		
		return self:GetTop() - self:GetNormal() * 16, true
	end
	
	return self:GetBottom() + self:GetNormal() * 2.0 * 16, false
end

-- See if a node is an area : 1 or a ladder : 2
function Zone:Node_Get_Type()
	
	return 1
end

function Lad:Node_Get_Type()
	
	return 2
end


-- This grabs every internal variable of the specified entity
function Test( ply )
	for k, v in pairs( ply:GetSaveTable( true ) ) do
		
		print( k )
		print( v )
		
	end 
end
