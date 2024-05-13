--- STEAMODDED HEADER
--- MOD_NAME: Stone Deck
--- MOD_ID: stonedeck
--- MOD_AUTHOR: [WYXkk]
--- MOD_DESCRIPTION: A simple mod with a deck.

local loc_def = {
	name="Stone Deck",
	text={
		"Playing cards always have",
		"stone enhance, cards to",
		"unstone are banned",
	},
}

local stoneDeck = SMODS.Deck:new("Stone Deck","stone",{all_stone = true},{x=5,y=0},loc_def)
stoneDeck:register()

-- Save function ref so we can append some logic to it
local Backapply_to_runRef = Back.apply_to_run
-- Function used to apply new Deck effects
function Back.apply_to_run(arg)
	Backapply_to_runRef(arg)

	if arg.effect.config.all_stone then
		G.E_MANAGER:add_event(Event({
			func = function()
				for i = #G.playing_cards, 1, -1 do
					G.playing_cards[i]:set_ability(G.P_CENTERS.m_stone)
				end
				G.GAME.banned_keys={
					j_vampire=true,
					j_midas_mask=true,
					c_magician=true,
					c_empress=true,
					c_heirophant=true,
					c_lovers=true,
					c_chariot=true,
					c_justice=true,
					c_devil=true,
				}
				G.GAME.forced_stone=true
				return true
			end
		}))
	end
end

local old_create_playing_card=create_playing_card
function create_playing_card(card_init, area, skip_materialize, silent, colours)
	if G.GAME.forced_stone then
		card_init.center = G.P_CENTERS.m_stone
	end
	return old_create_playing_card(card_init, area, skip_materialize, silent, colours)
end

local old_create_card=create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
	local forced_key_new = forced_key
	local _type_new = _type
	if G.GAME.forced_stone and (_type=='Base' or _type == 'Enhanced') then
		forced_key_new = 'm_stone'
		_type_new = 'Enhanced'
	end
	return old_create_card(_type_new, area, legendary, _rarity, skip_materialize, soulable, forced_key_new, key_append)
end