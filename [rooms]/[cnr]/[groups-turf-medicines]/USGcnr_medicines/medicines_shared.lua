medicines = {
--    Ritalin = {id = 1580, key = "ritalin"},
--  LSD = {id = 1575},
    Adderall = {id = 1576, key = "adderall"},
    Steroid = {id = 1577, key = "steroid"},
    Aspirin = {id = 1578, key = "aspirin"}

}

local types = {}
for medicine, _ in pairs(medicines) do
    table.insert(types, medicine)
end

function getMedicineTypes()
    return types
end