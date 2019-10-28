-- Current Author: bluzukk
-- Original Author: modernist (modUI)
-- https://github.com/obble/modui_classic


local ToggleCombat = function(alpha)
	PlayerFrameManaBar.energy.spark:SetAlpha(alpha)
end

local function AddonCommands(msg, editbox)
	if msg == nil or msg ~= '' then
		num = tonumber(string.match(msg, '%d[%d.]*'))
			if (num >= 0 and num <= 1) then
				if string.match(msg, 'fight') then
					alpha_fight = num
					print('|cff00C78C Energytick|r: In fight alpha set to ' ..  alpha_fight)
				elseif string.match(msg, 'normal') then
					alpha_normal = num
					print('|cff00C78C Energytick|r: Normal alpha set to ' ..  alpha_normal)
					ToggleCombat(alpha_normal)
				end
			else
				print('|cff00C78C Energytick|r: Alpha should be between 0.0 and 1.0 ')
		end
	else
		-- Print Usage
		print("|cff00C78C ###################|r")
		print("|cff00C78C # |r   Energy tick options:|cff00C78C     # |r")
		print("|cff00C78C # |r   /et fight    <alpha> |cff00C78C     # |r")
		print("|cff00C78C # |r   /et normal <alpha> |cff00C78C     # |r")
		print("|cff00C78C ###################|r")
	end
end

SLASH_ENERGYTICK1, SLASH_ENERGYTICK2 = '/et', '/energytick'
SlashCmdList["ENERGYTICK"] = AddonCommands


-- local _, ns = ...

local _, class = UnitClass'player'
if not (class == 'ROGUE' or class == 'DRUID') then return end

local events = {
		'PLAYER_LOGIN',
		'PLAYER_REGEN_DISABLED',
		'PLAYER_REGEN_ENABLED',
}

local last_tick  = GetTime()
local last_value = 0

local SetEnergyValue = function(self, value)
	local x      = self:GetWidth()
	local v, max = UnitPower'player', UnitPowerMax'player'
	local type   = UnitPowerType'player'

	if  type ~= Enum.PowerType.Energy then
		self.energy.spark:Hide()
	else
		local position = (x*value)/2
		self.energy.spark:Show()
		self.energy.spark:SetPoint('CENTER', self, 'LEFT', position, 0)
	end
end


local UpdateEnergy = function(self, unit)
	local energy = UnitPower('player', Enum.PowerType.Energy)
	local time  = GetTime()
	local v = time - last_tick

	if  energy > last_value or time >= last_tick + 2 then
		last_tick = time
	end

	SetEnergyValue(self:GetParent(), v)
	last_value = energy
end


local AddEnergy = function()
	PlayerFrameManaBar.energy = CreateFrame('Statusbar', 'PlayerFrameManaBar_modui_energy', PlayerFrameManaBar)
	PlayerFrameManaBar.energy.spark = PlayerFrameManaBar.energy:CreateTexture(nil, 'OVERLAY')
	PlayerFrameManaBar.energy.spark:SetTexture[[Interface\CastingBar\UI-CastingBar-Spark]]
	PlayerFrameManaBar.energy.spark:SetSize(32, 32)
	PlayerFrameManaBar.energy.spark:SetPoint('CENTER', PlayerFrameManaBar, 0, 0)
	PlayerFrameManaBar.energy.spark:SetBlendMode'ADD'
	PlayerFrameManaBar.energy.spark:SetAlpha(alpha_normal)
	PlayerFrameManaBar.energy:RegisterEvent'UNIT_POWER_UPDATE'
	PlayerFrameManaBar.energy:SetScript('OnUpdate', UpdateEnergy)
end


local OnEvent = function(self, event, ...)
	if event == 'PLAYER_LOGIN' then
		if alpha_fight == nil then
			alpha_fight = .8
			-- print("alpha_fight is nil")
		end
		if alpha_normal == nil then
			alpha_normal = .3
			-- print("alpha_normal is nil")
		end
		AddEnergy()
	elseif event == 'PLAYER_REGEN_DISABLED' then
			ToggleCombat(alpha_fight)
	elseif event == 'PLAYER_REGEN_ENABLED' then
			ToggleCombat(alpha_normal)
	end
end

local  e = CreateFrame'Frame'
for _, v in pairs(events) do e:RegisterEvent(v) end
e:SetScript('OnEvent', OnEvent)
