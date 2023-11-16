local DataTypesHandler = {}

local ABBREVIATIONS = require(script.Abbreviations)
local USE_SUFFIX_AFTER = 999 --9999999

export type DataTypesHandler = {
	Length: (Dictionary: {}) -> number,
	SortDictionary: (Dictionary: {}, SortFunction: (a: any, b: any) -> boolean) -> {},
	Suffix: (Number: number, Deciamals: number) -> string,
	Comma: (Number: number) -> string,
	AdaptiveNumberFormat: (Number: number, Deciamals: number) -> string,
	StringToNumber: (Value: string) -> number,
	Round: (Number: number, DecimalPlaces: number) -> number,
	BiggerThan : (Number1: number, Number2: number) -> boolean,
	RemoveCommas: (Value: string) -> string,
	DHMS: (Seconds: number) -> string,
	HMS: (Seconds: number) -> string,
	ConvertToHMS: (Seconds: number) -> {Hours: number, Minutes: number, Seconds: number},
	ConvertToDHMS: (Seconds: number) -> {Days: number, Hours: number, Minutes: number, Seconds: number},
	AdaptiveTimer: (Seconds: number) -> string,
	GetTimeBetween: (Time1: number, Time2: number) -> string,
}

function DataTypesHandler:Length(Dictionary)
	local counter = 0
	for _, _ in Dictionary  do
		counter = counter + 1
	end
	return counter
end

function DataTypesHandler:SortDictionary(Dictionary, SortFunction)
	local array = {}
	for key, value in pairs(Dictionary) do
		array[#array + 1] = { key = key, value = value }
	end
	table.sort(array, SortFunction)
	return array
end

function DataTypesHandler:Suffix(Number, Deciamals)
	if not Number then
		return "0"
	end

	if Number > -1000 and Number < 1000 then
		return tostring(math.floor(Number))
	end

	local IsNegative = Number < 0
	Number = math.abs(math.floor(Number))
	for Index = #ABBREVIATIONS, 1, -1 do
		local Unit = ABBREVIATIONS[Index]
		local Size = 10 ^ (Index * 3)
		if Size <= Number then
			Number = self:Round(Number / Size, Deciamals)
			if Number == 1000 and Index < #ABBREVIATIONS then
				Number = 1
				Unit = ABBREVIATIONS[Index][Index + 1]
			end
			Number = string.format("%.2f", Number) .. Unit
			break
		end
	end

	return (IsNegative and "-" .. Number) or Number

end

function DataTypesHandler:Comma(Number)
	if Number > -1000 and Number < 1000 then
		return tostring(math.floor(Number))
	end
	Number = tostring(math.floor(Number))
	return Number:reverse():gsub("...", "%0.", math.floor((#Number - 1) / 3)):reverse()
end

function DataTypesHandler:AdaptiveNumberFormat(Number, Deciamals)
	if not Number then
		return "0"
	end
	if Number > -1000 and Number < 1000 then
		return tostring(Number)
	end
	return (Number > USE_SUFFIX_AFTER and self:Suffix(Number, Deciamals)) or self:Comma(Number)
end

function DataTypesHandler:StringToNumber(Value)
	if typeof(Value) == "number" then
		return Value
	end
	if string.find(Value, ",") then
		Value = self:RemoveCommas(Value)
	end
	local TotalMagnitude = 1
	for Key, Suffix in ipairs(ABBREVIATIONS) do
		Value = string.gsub(Value, Suffix, function()
			TotalMagnitude *= (10 ^ (Key * 3))
			return ""
		end)
	end
	local numberValue = tonumber(Value)
	if numberValue == nil then
		return nil
	end
	return TotalMagnitude * numberValue
end

function DataTypesHandler:Round(Number, DecimalPlaces)
	DecimalPlaces = DecimalPlaces or 0
	return math.floor(Number * (10 ^ DecimalPlaces)) / 10 ^ DecimalPlaces
end

function DataTypesHandler:BiggerThan(Number1, Number2)
	if Number1 then
		print(Number1, Number2)
		if Number1 == "0" then
			return false
		end
		local _Number1 = self:StringToNumber(Number1)
		local _Number2 = self:StringToNumber(Number2)
		if _Number1 > _Number2 then
			return true
		end
	end
	return false
end

function DataTypesHandler:RemoveCommas(Value)
	Value = string.split(Value, ",") or string.split(Value, ".")
	local ReturnedValue = ""
	for _, V in ipairs(Value) do
		if V == "," then
			continue
		end
		ReturnedValue ..= V
	end
	return tonumber(ReturnedValue)
end

function DataTypesHandler:DHMS(Seconds)
	return string.format("%d:%02d:%02d:%02d", Seconds / 86400, Seconds / 3600 % 24, Seconds / 60 % 60, Seconds % 60)
end

function DataTypesHandler:HMS(Seconds)
	local Hours = math.floor(Seconds / 3600)
	local Minutes = math.floor(Seconds / 60) % 60
	Seconds = math.floor(Seconds) % 60
	return string.format("%d:%02d:%02d", Hours, Minutes, Seconds)
end

function DataTypesHandler:MS(Seconds)
	local Minutes = math.floor(Seconds / 60)
	Seconds = math.floor(Seconds) % 60
	return string.format("%s:%02s", Minutes, Seconds)
end

function Format(Int)
	return string.format("%02i", Int)
end

function DataTypesHandler:ConvertToHMS(Seconds)
	local Minutes = (Seconds - Seconds % 60) / 60
	Seconds = Seconds - Minutes * 60
	local Hours = (Minutes - Minutes % 60) / 60
	Minutes = Minutes - Hours * 60
	return Format(Hours) .. ":" .. Format(Minutes) .. ":" .. Format(Seconds)
end

function DataTypesHandler:ConvertToDHMS(Seconds)
	local Minutes = (Seconds - Seconds % 60) / 60
	Seconds = Seconds - Minutes * 60
	local Hours = (Minutes - Minutes % 60) / 60
	Minutes = Minutes - Hours * 60
	local Days = (Hours - Hours % 24) / 24
	Hours = Hours - Days * 24
	return Format(Days) .. ":" .. Format(Hours) .. ":" .. Format(Minutes) .. ":" .. Format(Seconds)
end

function DataTypesHandler:AdaptiveTimer(Seconds)
	return (Seconds >= 86400 and self:DHMS(Seconds)) or (Seconds >= 3600 and self:HMS(Seconds)) or self:MS(Seconds)
end

function DataTypesHandler:GetTimeBetween(ActiveTime, StartTime)
	return ActiveTime - (os.time() - StartTime)
end

return DataTypesHandler
