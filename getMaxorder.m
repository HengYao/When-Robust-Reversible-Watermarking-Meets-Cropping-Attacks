% evaluate the Maxorder for the message to be emebed
function [Maxorder,capacity]=getMaxorder(messagelength)

Maxorder=1;
capacity=0;
while(messagelength>capacity)
    capacity=0;
    for i=2:Maxorder+1
        for j=1:2:i
            n=i-1;
            m=-n+j-1;
            if mod(m,4)~=0
                capacity = capacity+1;
            end
        end
    end
    Maxorder=Maxorder+1;
end
Maxorder=Maxorder-1;
end