function isElBool = is_element(vec,item)
%IS_ELEMENT returns true if item is in array
% vec: str[]
% item: str

    for i=vec
        if i == item
            isElBool = true;
            return
        end
    end
    isElBool = false;
end

