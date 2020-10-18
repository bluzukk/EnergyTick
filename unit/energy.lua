-- author: bluzukk
-- thanks to modernist (modUI, github.com/obble/modui_classic)


local _, class = UnitClass('player')
-- if not (class == 'ROGUE' or class == 'DRUID') then return end

local last_tick  = GetTime()
local last_value = 0

local function UpdateAlpha(alpha)
  PlayerFrameManaBar.mana.spark:SetAlpha(alpha)
end

local function AddonCommands(msg, editbox)
  if msg == nil or msg ~= '' then
    num = tonumber(string.match(msg, '%d[%d.]*'))
  if (num >= 0 and num <= 1) then
    if string.match(msg, 'fight') then
      alpha_fight = num
      print('|cff00C78C EnergytickOptions|r: In fight alpha set to ' ..  alpha_fight)
    elseif string.match(msg, 'normal') then
      alpha_normal = num
      print('|cff00C78C EnergytickOptions|r: Normal alpha set to ' ..  alpha_normal)
      UpdateAlpha(alpha_normal)
    end
    else
      print('|cff00C78C EnergytickOptions|r: Alpha should be between 0.0 and 1.0 ')
    end
  else
  -- Print Usage
  print('|cff00C78C Energy tick options:')
  print('   /et fight  <alpha>')
  print('   /et normal <alpha>')
  end
end

SLASH_EnergytickOptions1, SLASH_EnergytickOptions2 = '/et', '/EnergytickOptions'
SlashCmdList['EnergytickOptions'] = AddonCommands

local function SetEnergyValue(self, value)
  local width = self:GetWidth()
  local type  = UnitPowerType('player')

  -- can be used for disabling if full energy
  local energy    = UnitPower('player')
  local maxEnergy = UnitPowerMax('player')

  -- if type == Enum.PowerType.Mana then
  -- -- for druids
  --   self.mana.spark:Hide()
  -- else
  local position = ((width * value) / 2)
  if (position < width) then
    self.mana.spark:SetPoint('CENTER', self, 'LEFT', position, 0)
    self.mana.spark:Show()
    -- end
  end
end


local function UpdateEnergy(self, unit)
  local energy = UnitPower('player')
  local time  = GetTime()
  local v = time - last_tick

  if energy > last_value or time >= last_tick + 1.95 then -- should be +2 (seconds)
    last_tick = time
  end

  SetEnergyValue(self:GetParent(), v)
  last_value = energy
end


local function Init()
  PlayerFrameManaBar.mana = CreateFrame('Statusbar', nil, PlayerFrameManaBar)
  PlayerFrameManaBar.mana.spark = PlayerFrameManaBar.mana:CreateTexture(nil, 'OVERLAY')
  PlayerFrameManaBar.mana.spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
  PlayerFrameManaBar.mana.spark:SetSize(32, 32)
  PlayerFrameManaBar.mana.spark:SetPoint('CENTER', PlayerFrameManaBar, 0, 0)
  PlayerFrameManaBar.mana.spark:SetBlendMode('ADD')
  PlayerFrameManaBar.mana.spark:SetAlpha(alpha_normal)
  PlayerFrameManaBar.mana:RegisterEvent('UNIT_POWER_UPDATE')
  PlayerFrameManaBar.mana:SetScript('OnUpdate', UpdateEnergy)
end

local function HandleEvent(self, event)
  if event == 'PLAYER_LOGIN' then
    print('KEKEKEKEEK Saved variables:')

    if alpha_fight == nil then
      alpha_fight = .8
      print('Alpha fight  nil')
    else
      print('Alpha fight  ' .. alpha_fight)
    end

    if alpha_normal == nil then
      alpha_normal = .3
      print('Alpha nil  ')
    else
      print('Alpha normal  ' .. alpha_normal)
    end
  Init()

  elseif event == 'PLAYER_REGEN_DISABLED' then
    UpdateAlpha(alpha_fight)
  elseif event == 'PLAYER_REGEN_ENABLED' then
    UpdateAlpha(alpha_normal)
  end
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('PLAYER_LOGIN')
frame:RegisterEvent('PLAYER_REGEN_DISABLED')
frame:RegisterEvent('PLAYER_REGEN_ENABLED')
frame:SetScript('OnEvent', HandleEvent)


-- math.round api not working
function round(number, precision)
   local fmtStr = string.format('%%0.%sf',precision)
   number = string.format(fmtStr,number)
   return number
end


--   #######  ########  ######## ####  #######  ##    ##  ######
--  ##     ## ##     ##    ##     ##  ##     ## ###   ## ##    ##
--  ##     ## ##     ##    ##     ##  ##     ## ####  ## ##
--  ##     ## ########     ##     ##  ##     ## ## ## ##  ######
--  ##     ## ##           ##     ##  ##     ## ##  ####       ##
--  ##     ## ##           ##     ##  ##     ## ##   ### ##    ##
--   #######  ##           ##    ####  #######  ##    ##  ######

EnergytickOptions = {};
EnergytickOptions.panel = CreateFrame( 'Frame', 'EnergytickOptions', InterfaceOptionsPanelContainer);
EnergytickOptions.panel.name = 'Energytick';
InterfaceOptions_AddCategory(EnergytickOptions.panel);

local function createSlider(name, parent, low, high, label, description, stepsize)
  local slider = CreateFrame('slider', name, parent, 'OptionsSliderTemplate')
  slider:SetWidth(200)
  slider:SetObeyStepOnDrag(false)
  slider:SetMinMaxValues(low, high)

  slider.label = parent:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
  slider.label:SetPoint('TOP', slider, 'BOTTOM', 0, 0)
  slider.minValue, slider.maxValue = slider:GetMinMaxValues()
  slider.textLow = _G[name..'Low']
  slider.textHigh = _G[name..'High']
  slider.text = _G[name..'Text']
  slider.textLow:SetText(slider.minValue)
  slider.textHigh:SetText(slider.maxValue)
  slider.value = slider:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
  slider.value:SetPoint('BOTTOM', slider, 'TOP')
  slider.value:SetFontObject(GameFontNormalBig)
  slider.value:SetText(label)
  slider.tooltipText = label
  slider.tooltipRequirement = description
  return slider
end

function createCheckbox(label, description, x, y, parent, checked, onClick)
  local checkbox = CreateFrame('CheckButton', nil, parent, 'InterfaceOptionsCheckButtonTemplate')
  checkbox:SetPoint('CENTER', x, y)
  checkbox.label = parent:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
  checkbox.label:SetPoint('LEFT', checkbox, 'RIGHT', 0, 0)
  checkbox.label:SetText(label)
  checkbox.tooltipText = label
  checkbox.tooltipRequirement = description
  checkbox:SetChecked(checked)
  checkbox:SetScript('OnClick', onClick)
  return checkbox
end

local CHECKBOX createCheckbox(
      'Disable on max energy \n(Not fully implemented yet. Available soon)',
      'Disable energy ticks if player has full energy',
      0,
      -150,
      EnergytickOptions.panel,
      disableOnMaxEnergy,
      function(self)
          -- print(self:GetChecked())
          disableOnMaxEnergy = self:GetChecked()
      end
)

local SLIDER_NORMAL = createSlider('Slider', EnergytickOptions.panel, 0, 100, 'Visibility out of combat', 'Change the visibility of energy ticks out of combat', 0.5)
SLIDER_NORMAL:SetPoint('CENTER', 0, 100)
SLIDER_NORMAL:SetValueStep(0.5)
SLIDER_NORMAL:SetScript(
  'OnValueChanged',
  function(self, value)
    alpha_normal = round(value/100, 2)
    --print(alpha_normal)
    UpdateAlpha(alpha_normal)
    self.label:SetText(alpha_normal*100 .. ' %')
  end
)

local SLIDER_FIGHT = createSlider('CombatSlider', EnergytickOptions.panel, 0, 100, 'Visibility in combat', 'Change the visibility of energy ticks in combat', 0.5)
SLIDER_FIGHT:SetPoint('CENTER', 0, 0)
SLIDER_FIGHT:SetValueStep(0.5)
SLIDER_FIGHT:SetScript(
  'OnValueChanged',
  function(self, value)
    alpha_fight = round(value/100, 2)
    --print(alpha_fight)
    UpdateAlpha(alpha_fight)
    self.label:SetText(alpha_fight*100 .. ' %')
  end
)

EnergytickOptions.panel.refresh = function()
	SLIDER_FIGHT:SetValue(alpha_fight*100)
  SLIDER_NORMAL:SetValue(alpha_normal*100)
end
