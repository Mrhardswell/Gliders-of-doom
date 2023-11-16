local UtilityModule = {}
type Array = {[number]: any}
function UtilityModule.filtertable(Table,Callback) : Array
    local newTable = {}
    for Index,object in Table do
        local valid = Callback(Index,object)
        local _type = typeof(valid)

        -- added _type "Instance" Incase the callback returns an instance
        if _type ~= "boolean" and _type == "Instance" or _type == "table" then
            table.insert(newTable,valid)
        elseif _type == "boolean" and valid then
            table.insert(newTable,object)
        end
    end
    return newTable
end

return UtilityModule