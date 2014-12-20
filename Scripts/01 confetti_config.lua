local default_config= {
	amount= 500,
	min_size= 8,
	max_size= 8,
	min_fall= 4,
	max_fall= 16,
	lumax= 4,
	spin= 360,
	perm_on= false,
	combo_reward= 1000,
	colors= {
		color("#b58900"),
		color("#cb4b16"),
		color("#dc322f"),
		color("#d33682"),
		color("#6c71c4"),
		color("#268bd2"),
		color("#2aa198"),
		color("#859900"),
	},
	text_color= color("#93a1a1"),
	text_stroke= color("#002b36"),
}

confetti_config= create_setting("Drunk confetti", "drunken_confetti.lua", default_config, -1)
confetti_config:load()


local confetti_data= confetti_config:get_data()
drunk_text_color= confetti_data.text_color
drunk_text_stroke= confetti_data.text_stroke

function color_text(self)
	self:diffuse(drunk_text_color)
	self:strokecolor(drunk_text_stroke)
end

local real_rand= math.random
local function maybe_rand(a, b)
	if a < b then return real_rand(a, b) end
	return a
end

function confetti_count()
	return confetti_data.amount
end

function confetti_size()
	return maybe_rand(confetti_data.min_size, confetti_data.max_size)
end

function confetti_fall_time()
	local ret= scale(
		math.random(), 0, 1, confetti_data.min_fall, confetti_data.max_fall)
	if ret <= .1 then return .1 end
	return ret
end

function confetti_hibernate()
	return confetti_fall_time() - confetti_data.min_fall
end

local xmin= 0
local xmax= _screen.w
function set_confetti_side(side)
	if side == "left" then
		xmin= 0
		xmax= _screen.w * .5
	elseif side == "full" then
		xmin= 0
		xmax= _screen.w
	else
		xmin= _screen.w * .5
		xmax= _screen.w
	end
end

function confetti_x()
	return math.random(xmin, xmax)
end

function confetti_fall_start()
	return confetti_data.max_size * -2
end

function confetti_fall_end()
	return _screen.h + (confetti_data.max_size * 2)
end

function confetti_spin()
	return maybe_rand(-confetti_data.spin, confetti_data.spin)
end

local function rand_lum()
	if confetti_data.lumax < 1 then return 1 end
	if math.random(2) == 1 then
		return scale(math.random(), 0, 1, 1, confetti_data.lumax)
	end
	return 1 / scale(math.random(), 0, 1, 1, confetti_data.lumax)
end

function adjust_luma(from_color, adjustment)
	local res_color= {}
	for i, v in pairs(from_color) do
		if i == 4 then
			res_color[i]= v
		else
			res_color[i]= (v^2.2 * adjustment)^(1/2.2)
		end
	end
	return res_color
end

local color_set= confetti_config:get_data().colors
local default_color= color("#000000")

function color_in_set(set, index, wrap)
	if index ~= index then
		return default_color
	end
	if wrap then
		index= ((index-1) % #set) + 1
	end
	if index < 1 then return set[1] or default_color end
	if index > #set then return set[#set] or default_color end
	return set[index] or default_color
end

function confetti_color()
	local cindex= math.floor((math.random() * #color_set) + 1)
	return adjust_luma(color_in_set(color_set, cindex), rand_lum())
end
