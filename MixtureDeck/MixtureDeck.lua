--- STEAMODDED HEADER
--- MOD_NAME: Mixture Deck
--- MOD_ID: mixturedeck
--- MOD_AUTHOR: [WYXkk]
--- MOD_DESCRIPTION: A simple mod with a deck.

--- TODO: balance it a little bit more

local loc_def = {
	name="Mixture Deck",
	text={
		"All 15 vanilla deck",
		"effects combined",
		"{C:red}X(Ante+1){} Blind size",
		"{C:red}X1.2^Ante{} Blind size",
	},
}
local deckConfig={
	dollars=10,
	discards=1,
	extra_hand_bonus=2,
	extra_discard_bonus=1,
	no_interest=true,
	vouchers={
		'v_crystal_ball',
		'v_telescope',
		'v_tarot_merchant',
		'v_planet_merchant',
		'v_overstock_norm',
	},
	consumables={
		'c_fool',
		'c_fool',
		'c_hex',
	},
	consumable_slot=-1,
	spectral_rate=2,
	hand_size=2,
	ante_scaling=2,
	randomize_rank_suit_mixture=true,
	no_faces=true,
}
local mixturedeck = SMODS.Deck:new("Mixture Deck","mixture",deckConfig,{x=5,y=2},loc_def)
mixturedeck:register()

local old_Backtrigger_effect=Back.trigger_effect
function Back:trigger_effect(args)
	old_Backtrigger_effect(self,args)

	if self.name == 'Mixture Deck' then
		if args.context == 'eval' and G.GAME.last_blind and G.GAME.last_blind.boss then
			G.E_MANAGER:add_event(Event({
					func = (function()
						add_tag(Tag('tag_double'))
						play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
						play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
						return true
					end)
			}))
		end

		if args.context == 'blind_amount' then
			return
		end

		if args.context == 'final_scoring_step' then
			local tot = args.chips + args.mult
			args.chips = math.floor(tot/2)
			args.mult = math.floor(tot/2)
			update_hand_text({delay = 0}, {mult = args.mult, chips = args.chips})

			G.E_MANAGER:add_event(Event({
					func = (function()
						local text = localize('k_balanced')
						play_sound('gong', 0.94, 0.3)
						play_sound('gong', 0.94*1.5, 0.2)
						play_sound('tarot1', 1.5)
						ease_colour(G.C.UI_CHIPS, {0.8, 0.45, 0.85, 1})
						ease_colour(G.C.UI_MULT, {0.8, 0.45, 0.85, 1})
						attention_text({
							scale = 1.4, text = text, hold = 2, align = 'cm', offset = {x = 0,y = -2.7},major = G.play
						})
						G.E_MANAGER:add_event(Event({
							trigger = 'after',
							blockable = false,
							blocking = false,
							delay =  4.3,
							func = (function() 
										ease_colour(G.C.UI_CHIPS, G.C.BLUE, 2)
										ease_colour(G.C.UI_MULT, G.C.RED, 2)
									return true
							end)
						}))
						G.E_MANAGER:add_event(Event({
							trigger = 'after',
							blockable = false,
							blocking = false,
							no_delete = true,
							delay =  6.3,
							func = (function() 
									G.C.UI_CHIPS[1], G.C.UI_CHIPS[2], G.C.UI_CHIPS[3], G.C.UI_CHIPS[4] = G.C.BLUE[1], G.C.BLUE[2], G.C.BLUE[3], G.C.BLUE[4]
									G.C.UI_MULT[1], G.C.UI_MULT[2], G.C.UI_MULT[3], G.C.UI_MULT[4] = G.C.RED[1], G.C.RED[2], G.C.RED[3], G.C.RED[4]
									return true
							end)
						}))
						return true
					end)
			}))

			delay(0.6)
			return args.chips, args.mult
		end
	end
end

local Backapply_to_runRef = Back.apply_to_run
function Back.apply_to_run(arg)
	Backapply_to_runRef(arg)

	if arg.effect.config.randomize_rank_suit_mixture then
		G.GAME.starting_params.no_faces = true
		G.GAME.mixture_deck_dynamic_ante_scaling = 1
		G.E_MANAGER:add_event(Event({
			func = function()
				local pool={}
				local suit={'S','H'}
				local rank={'2','3','4','5','6','7','8','9','T','A'}
				for _,v in pairs(suit) do
					for __,vv in pairs(rank) do
						pool[#pool+1]=G.P_CARDS[v..'_'..vv]
					end
				end
				for _,v in pairs(G.playing_cards) do
					local k,_=pseudorandom_element(pool, pseudoseed('mixture'))
					v:set_base(k)
				end
				return true
			end
		}))
	end
end

local old_get_blind_amount=get_blind_amount
function get_blind_amount(ante)
	local v=old_get_blind_amount(ante)
	if G.GAME.mixture_deck_dynamic_ante_scaling then
		v=v*(ante+1)*(1.2^ante)
	end
	return v
end

if DV and DV.SIM then
	local oldbalance=DV.SIM.simulate_deck_effects
	function DV.SIM.simulate_deck_effects()
		if G.GAME.selected_back.name == 'Mixture Deck' then
			local function plasma(data)
				local sum = data.chips + data.mult
				local half_sum = math.floor(sum/2)
				data.chips = mod_chips(half_sum)
				data.mult = mod_mult(half_sum)
			end

			plasma(DV.SIM.running.min)
			plasma(DV.SIM.running.exact)
			plasma(DV.SIM.running.max)
		else
			oldbalance()
		end
	end
end