local abbreviation = {}
local Suffixes = {"k","M","B","T","qd","Qn","sx","Sp","O","N","de","Ud","DD","tdD","qdD","QnD","sxD","SpD","OcD","NvD","Vgn","UVg","DVg","TVg","qtV","QnV","SeV","SPG","OVG","NVG","TGN","UTG","DTG","tsTG","qtTG","QnTG","ssTG","SpTG","OcTG","NoTG","QdDR","uQDR","dQDR","tQDR","qdQDR","QnQDR","sxQDR","SpQDR","OQDDr","NQDDr","qQGNT","uQGNT","dQGNT","tQGNT","qdQGNT","QnQGNT","sxQGNT","SpQGNT", "OQQGNT","NQQGNT","SXGNTL"}                                              



--[[
    Another Abrreviation type @Covert Function
    if numeral then
		local left,num,right = string.match(numeral,'^([^%d]*%d)(%d*)(.-)$')
		return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right -- returns for example 1,000, it gets every 3 zeros and adds a  comma
	end
]]

function abbreviation.Convert(number : number) : string
    if typeof(number) == "string"  then
        number = tonumber(number)
        if typeof(number) ~= "number" then
            return warn("Couldn't convert the string to the number")
        end
    end


    local Negative = number < 0
    number = math.abs(number)

    local Paired = false
    for i,v in pairs(Suffixes) do
        if not (number >= 10^(3*i)) then
            number = number / 10^(3*(i-1))
            local isComplex = (string.find(tostring(number),".") and string.sub(tostring(number),4,4) ~= ".")
            number = string.sub(tostring(number),1,(isComplex and 4) or 3) .. (Suffixes[i-1] or "")
            Paired = true
            break;
        end
    end
    if not Paired then
        local Rounded = math.floor(number)
        number = tostring(Rounded)
    end
    if Negative then
        return "-"..number
    end
    
    return number 
end

-- need some method to revert back the abbreviations
function abbreviation.Revert(numeral : string) : string

end



return abbreviation