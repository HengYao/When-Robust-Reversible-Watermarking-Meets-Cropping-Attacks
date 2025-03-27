function result=getNOP(points)
result=[];
for i=1:length(points)
    if points(i).radius ~= 0
        current_point = points(i);
        overlapping = false;
        for j = 1:length(result)
            if Overlap(current_point,result(j))
                overlapping = true;
                break;
            end
        end
        if ~overlapping
            result=[result;current_point];
        end
    end
end
end
