function getPlayerMedicineAmount(medicine)
    if(myMedicines and myMedicines[medicine]) then
        return myMedicines[medicine]
    else
        return false
    end
end