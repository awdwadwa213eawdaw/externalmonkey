local date = {}

local RELEASE_DATE = os.time({
	month = 10,
	day   = 24,
	year  = 2015,
	hour  = 0,
})

local SECONDS_PER_MINUTE = 60
local SECONDS_PER_HOUR = 60 * SECONDS_PER_MINUTE
local SECONDS_PER_DAY = 24 * SECONDS_PER_HOUR
local DAYS_PER_WEEK = 7
local DAYS_PER_YEAR = 365
local Debug, forcedWeather, forcedForecast = false, 'aurora', {
	{'', 0, 'thunder'}, --Not Used, Not Used, weather
	{'', 0, 'spacial'},
	{'', 0, 'sandstorm'},
	{'', 0, 'smog'},
	{'', 0, 'blood'},
	--First 2 sets are't use except for testing + skipping "Clear" in forecast
}
--local getTimeRemote = game:GetService('ReplicatedStorage').Remote.GetWorldTime
local function now()
	return os.time() - 5*SECONDS_PER_HOUR -- CDT
end

local months = {
	--{name,   ndays, no-longer-used},
	{'January',   31, 6},
	{'February',  28, 2},
	{'March',     31, 2},
	{'April',     30, 5},
	{'May',       31, 0},
	{'June',      30, 3},
	{'July',      31, 5},
	{'August',    31, 1},
	{'September', 30, 4},
	{'October',   31, 6},
	{'November',  30, 2},
	{'December',  31, 4},
}

local weekdays = {[0]='Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'}
local weatherNames = {
	--2 Variants for Rain
	rain = 'Heavy Rainfall',
	wind = 'Strong Gusts',
	hail = 'Pelting Hailstorm',
	fog = 'Thick Fog',
	snow = 'Blinding Snowstorm',
	meteor = 'Meteor Shower',	
	aurora = 'Northern Lights',

	[''] = 'Clear', --pretty sure this'll count all of them

	--ToDo
	spacial = 'Spacial Anomalies',
	thunder = 'Explosive Thunderstorms',
	smog = 'Toxic Smog',
	sun = 'Extreme Heat',
	blood = 'Blood Moon'
}
--[[
Old:
Clear: 37%
Rain: 11%
Wind: 14%
Snow: 10%
Hail: 8%
Fog: 10%
Meteor: 4%
Aurora: 6%
-------
CURRENT:
--Clear: 50%
--Rain: 7% 
--Wind: 8.5%
--Snow: 7%
--Hail: 6%
--Fog: 6.5%
--Meteor: 2.5%
--Aurora: 3.5%
--Thunder: 4.5%
--Smog: 4.5%

-------
TODO:
Blood Moon (Make appear)
Spacial
Thunder
Smog
Sun
]]
local weathers = {
	'', 'rain', 'fog', 'hail', 'snow', '', '', '', 'snow', '', 
	'', 'rain', '', '', '', 'wind', '', '', '', 'rain', 
	'', 'aurora', '', '', 'wind', '', '', '', '', '', 
	'smog', 'thunder', '', '', 'snow', 'smog', '', 'thunder', 'wind', 'wind', 
	'fog', 'rain', 'smog', '', '', 'wind', 'snow', '', '', 'rain', 
	'wind', '', 'snow', '', 'rain', '', 'wind', 'rain', 'aurora', '', 
	'', '', 'aurora', '', 'hail', 'rain', 'wind', 'thunder', '', 'wind', 
	'', '', '', 'aurora', 'aurora', 'rain', '', 'hail', 'hail', '', 
	'', '', 'wind', 'thunder', 'aurora', 'rain', 'rain', 'smog', 'hail', '', 
	'', '', '', '', 'smog', 'hail', '', 'aurora', '', '', 
	'', '', '', 'snow', 'hail', 'wind', 'wind', '', '', '', 
	'hail', '', '', 'wind', 'rain', 'hail', 'wind', 'fog', '', 'snow', 
	'rain', 'meteor', '', 'hail', 'snow', 'hail', 'rain', 'wind', '', 'fog', 
	'', 'fog', '', '', '', 'snow', 'fog', '', '', '', 
	'', '', '', '', 'wind', 'aurora', 'smog', 'thunder', '', '', 
	'', '', 'wind', '', 'rain', 'smog', '', '', '', 'wind', 
	'', '', '', 'rain', '', 'wind', '', '', 'rain', '', 
	'snow', '', '', 'wind', 'hail', 'smog', 'meteor', '', '', '', 
	'', 'rain', 'hail', 'smog', 'rain', 'rain', 'rain', '', 'wind', 'snow', 
	'thunder', 'fog', 'smog', 'meteor', '', '', '', 'snow', 'thunder', 'aurora', 
	'snow', 'snow', 'snow', 'hail', '', '', '', 'thunder', 'wind', '', 
	'rain', 'wind', '', 'fog', 'thunder', '', 'thunder', '', 'meteor', '', 
	'thunder', '', 'hail', '', 'wind', 'aurora', 'fog', 'aurora', '', '', 
	'', '', 'thunder', '', '', 'smog', '', 'hail', 'smog', '', 
	'fog', 'smog', 'snow', 'hail', '', 'snow', '', 'fog', '', '', 
	'', '', '', '', 'hail', '', 'smog', 'hail', '', 'rain', 
	'', 'rain', '', 'thunder', 'rain', 'rain', 'fog', 'thunder', 'fog', 'fog', 
	'wind', '', '', 'thunder', '', '', '', 'meteor', 'aurora', 'fog', 
	'', '', 'hail', 'snow', '', '', '', '', '', '', 
	'snow', 'meteor', '', '', 'rain', 'smog', '', '', '', '', 
	'snow', '', 'wind', 'fog', 'wind', 'smog', 'fog', '', 'aurora', 'wind', 
	'meteor', 'wind', '', '', 'smog', 'fog', 'snow', 'snow', 'hail', 'hail', 
	'', 'snow', 'fog', 'rain', 'snow', '', '', '', 'fog', '', 
	'', 'rain', '', 'snow', '', 'wind', '', '', 'smog', 'wind', 
	'fog', 'wind', '', '', 'wind', 'rain', '', 'rain', '', 'hail', 
	'fog', '', 'smog', '', '', 'wind', '', 'wind', 'snow', 'smog', 
	'', '', '', '', 'hail', '', '', '', 'thunder', 'rain', 
	'smog', '', 'rain', '', '', 'hail', '', 'rain', '', '', 
	'wind', '', 'snow', '', 'snow', '', 'meteor', 'meteor', 'snow', '', 
	'wind', '', '', '', '', '', 'snow', '', 'aurora', 'fog', 
	'', '', 'smog', '', '', '', '', 'smog', 'aurora', '', 
	'', 'smog', 'aurora', '', '', '', 'wind', 'fog', 'aurora', 'wind', 
	'aurora', 'aurora', 'hail', 'smog', '', 'hail', 'fog', 'meteor', '', 'wind', 
	'', '', '', '', 'rain', 'snow', 'aurora', '', '', '', 
	'thunder', 'thunder', '', 'aurora', 'snow', 'snow', 'wind', '', '', '', 
	'', '', '', '', '', '', '', '', '', '', 
	'wind', 'wind', '', '', '', 'rain', 'rain', '', '', '', 
	'snow', '', 'hail', 'wind', 'thunder', 'wind', 'fog', '', 'wind', '', 
	'', '', '', '', 'snow', '', 'rain', 'hail', 'wind', '', 
	'thunder', '', 'wind', '', '', 'wind', 'aurora', 'snow', '', 'snow', 
	'', '', '', 'snow', 'meteor', '', 'smog', '', '', '', 
	'', 'snow', 'snow', 'snow', '', 'snow', '', '', '', 'aurora', 
	'', '', '', '', '', 'rain', '', 'thunder', 'hail', 'meteor', 
	'', 'snow', 'thunder', '', '', 'wind', 'wind', 'wind', '', 'wind', 
	'', 'snow', '', '', 'thunder', '', 'aurora', 'snow', 'aurora', '', 
	'', 'thunder', 'fog', 'wind', '', '', '', 'thunder', 'rain', 'wind', 
	'', '', '', '', '', '', 'hail', '', '', '', 
	'', '', '', '', '', 'hail', 'meteor', '', 'hail', 'fog', 
	'', '', 'rain', 'wind', '', '', 'smog', '', 'hail', '', 
	'', '', '', 'rain', 'fog', '', '', '', 'snow', '', 
	'wind', '', 'snow', '', '', '', '', 'fog', 'snow', 'snow', 
	'', '', 'fog', 'smog', 'rain', '', '', 'snow', 'snow', '', 
	'hail', '', 'hail', '', '', 'hail', 'aurora', 'fog', 'smog', '', 
	'rain', '', 'wind', 'thunder', '', '', '', '', 'rain', '', 
	'', '', 'hail', '', 'rain', '', '', '', '', 'thunder', 
	'', 'fog', '', 'fog', '', '', 'snow', '', '', '', 
	'', '', '', '', '', '', '', 'rain', 'meteor', '', 
	'wind', 'thunder', '', '', '', 'hail', '', 'meteor', '', 'aurora', 
	'rain', '', '', '', 'snow', 'hail', '', '', '', 'wind', 
	'smog', '', 'meteor', 'hail', '', '', 'hail', 'wind', 'hail', 'thunder', 
	'fog', '', 'rain', '', 'wind', 'fog', 'fog', 'rain', '', '', 
	'', 'smog', 'rain', 'snow', 'thunder', '', 'meteor', 'smog', 'aurora', 'hail', 
	'snow', '', '', '', 'rain', 'thunder', '', 'thunder', '', 'fog', 
	'fog', '', 'rain', 'wind', '', 'meteor', '', '', '', 'smog', 
	'aurora', 'aurora', 'rain', '', 'fog', 'fog', '', 'hail', '', 'thunder', 
	'smog', 'rain', '', '', '', '', 'rain', '', '', '', 
	'fog', '', 'wind', 'thunder', '', '', '', 'wind', '', '', 
	'hail', '', '', '', 'rain', '', '', 'hail', '', 'fog', 
	'', 'thunder', '', '', '', '', 'rain', '', '', '', 
	'rain', 'thunder', 'snow', 'snow', '', '', 'rain', 'fog', 'snow', 'wind', 
	'hail', 'snow', 'snow', 'hail', 'snow', 'wind', '', 'meteor', 'wind', 'thunder', 
	'', 'fog', '', 'smog', '', 'thunder', 'rain', '', '', '', 
	'', 'snow', 'hail', '', 'smog', '', '', 'hail', '', 'fog', 
	'snow', '', 'fog', '', 'hail', '', 'fog', 'aurora', '', 'meteor', 
	'', 'snow', '', '', 'thunder', 'thunder', '', '', '', 'wind', 
	'rain', 'fog', 'rain', 'wind', 'thunder', '', '', '', '', 'fog', 
	'', 'wind', '', 'snow', '', 'wind', '', 'smog', 'rain', '', 
	'', '', 'wind', '', 'wind', 'fog', 'meteor', 'thunder', 'aurora', '', 
	'', 'fog', '', '', '', '', '', '', '', '', 
	'snow', '', 'rain', '', 'wind', 'fog', '', 'fog', 'smog', '', 
	'', 'fog', 'wind', 'hail', 'smog', 'fog', '', 'hail', 'wind', 'rain', 
	'meteor', 'smog', '', 'fog', '', '', 'hail', 'fog', '', 'smog', 
	'wind', '', 'wind', 'snow', '', 'snow', 'meteor', 'meteor', '', '', 
	'', 'smog', '', 'snow', '', 'rain', '', 'fog', 'fog', 'thunder', 
	'', '', '', '', '', '', 'fog', 'wind', '', '', 
	'', 'smog', '', 'aurora', 'hail', '', '', 'meteor', '', 'hail', 
	'smog', 'hail', '', 'thunder', '', 'rain', 'wind', '', 'wind', 'fog', 
	'', '', 'smog', '', '', '', '', 'fog', '', '', 
	'', 'wind', '', 'snow', 'wind', 'aurora', 'thunder', 'rain', '', 'wind', 
	'', 'rain', '', 'hail', '', '', 'aurora', 'fog', 'hail', '', 	
}--'' = clear 100 total

local WeatherTypes = #weathers
function getWeather(hour, day, dayOfWeek, Month)
	local weather = ''
	local maxUnit = 999999999 --as High as roblox allows you
	if dayOfWeek == 0 then dayOfWeek = 1 end
	local in1 = (((hour*day)/dayOfWeek)+hour)
	local in2 = (((day*dayOfWeek)/hour)+Month^2)
	local in3 = ((((in1*in2)/day))*hour)
	local seed = Random.new((math.round(in3)%WeatherTypes)+in1-(hour+dayOfWeek))--Better randomness
	in3 = (seed:NextInteger(1, maxUnit))%WeatherTypes
	if (day == 19 and Month == 9) and (hour >= 15 and hour <= 17) then 
		if hour == 15 then
			weather = 'smog'
		elseif hour == 16 then
			weather = 'aurora'
		else
			weather = 'thunder'
		end
	else
		weather = weathers[in3]
	end
	return weather--weathers[in3]--[((math.round(in3)%WeatherTypes)+1)]
end
function isLeapYear(yr)
	if yr % 400 == 0 then
		return true
	elseif yr % 100 == 0 then
		return false
	elseif yr % 4 == 0 then
		return true
	end
	return false
end

function twodigit(num)
	num = math.floor(num)
	if num < 10 then
		return '0'..tostring(num)
	end
	return tostring(num)
end

function date:getWeekdayName(currenttime)
	if not currenttime then currenttime = now() end
	return weekdays[(math.floor(currenttime/SECONDS_PER_DAY)+4)%7]
end

function date:getWeekId(currenttime) -- 12b
	if not currenttime then currenttime = now() end
	return math.floor(((currenttime - RELEASE_DATE) / SECONDS_PER_DAY + 6) / DAYS_PER_WEEK)
end

function date:getDayId(currenttime) -- 15b
	if not currenttime then currenttime = now() end
	return math.floor((currenttime - RELEASE_DATE) / SECONDS_PER_DAY)
end

function date:getDate(currenttime)
	if not currenttime then currenttime = now() end
	local monthS, monthN, weekday, day, hour, minute, sec, year = '', 0, '', 0, 0, 0, 0, 1970

	local days = math.ceil(currenttime/SECONDS_PER_DAY)
	local dpy = DAYS_PER_YEAR + (isLeapYear(year) and 1 or 0)
	while days > dpy do
		days = days - dpy
		year = year + 1
		dpy = DAYS_PER_YEAR + (isLeapYear(year) and 1 or 0)
	end

	if isLeapYear(year) then
		months[2][2] = 29
	end
	for i, j in ipairs(months) do
		if days > j[2] then
			days = days - j[2]
		else
			monthS = j[1]
			monthN = i
			day = days
			break
		end
	end
	months[2][2] = 28
	local t = currenttime % SECONDS_PER_DAY
	hour = math.floor(t/SECONDS_PER_HOUR)
	minute = math.floor((t%SECONDS_PER_HOUR)/SECONDS_PER_MINUTE)
	sec = t % SECONDS_PER_MINUTE

	--	local dayFig = year%100
	--	dayFig = dayFig + math.floor(dayFig/4)
	--	dayFig = dayFig + day + months[monthN][3]
	--	dayFig = dayFig % 7
	local dayFig = (math.floor(currenttime/SECONDS_PER_DAY)+4)%7

	weekday = weekdays[dayFig]
	--warn(weathers[((day*hour)%(hour+day)%WeatherTypes)+1])
	local stringed = weekday..', '..monthS..' '..twodigit(day)..', '..tostring(year)..'; '..twodigit(hour)..':'..twodigit(minute)..':'..twodigit(sec)
	--	print(stringed)
	local predictedWeather = {}
	local hr, dy, mnth, dyf = hour, day, monthN, dayFig
	for i=1, 5 do -- change if I wanna display more than the upcoming 4 weather + current
		if Debug then
			predictedWeather = forcedForecast	
		else
			if hr >= 24 then
				hr = 0
				dy += 1
				if dyf >= 7 then
					dyf = 1
				end
			end
			local wb = getWeather(hr, dy, dyf, mnth)
			predictedWeather[i] = {
				(weatherNames[wb]) or '',
				hr%24,
				wb or ''
			} --{weather, hour}
			hr += 1
		end
	end
	return {
		MonthName = monthS,
		MonthNum = monthN,
		DayOfMonth = day,
		Year = year,
		WeekdayName = weekday,
		WeekdayNum = dayFig,
		Hour = hour,
		Minute = minute,
		Second = sec,
		TimeString = stringed,
		Weather = (Debug and forcedWeather or getWeather(hour, day, dayFig, monthN)),
		predictedWeather = predictedWeather
	}
end



return date