case
    when rating >= 4 then 'promoter'
    when rating = 3 then 'passive'
    when rating <= 2 then 'detractor'
    else null
end
