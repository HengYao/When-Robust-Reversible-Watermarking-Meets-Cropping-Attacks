function [moment_extracted,message_extracted]=robustextracting(moment_modified,Maxorder,Step)

% note: under the attack situation, no recover image is derived! the message
% is the only thing we can get from attacked image

moment_extracted = moment_modified;
K = 1000;
count = 1;
sigma = mod(Step,4)/4;
for i = 2:Maxorder+1
    for j = 1:2:i

        n = i-1;
        m = -n+j-1;
        M0 = moment_extracted(1,1);

        if mod(m,4)~=0
            M = moment_extracted(i,j);
            mag = abs(M);
            nmag = (mag/M0)*K;
            
            G = floor(nmag-sigma)+sigma;
            G_quant = floor(G)-mod(floor(G),Step);

            if (G-G_quant)>(1/2)*Step
                message_extracted(count,1) = 1;
                nmag = nmag-(3/4)*Step;
                
            elseif (G-G_quant)<=(1/2)*Step
                message_extracted(count,1) = 0;
                nmag = nmag-(1/4)*Step;
            end
            mag_re = (nmag*M0)/K;
            M_re = (mag_re/mag)*M;

            moment_extracted(i,j) = M_re;
            count = count+1;
            
        end
    end
end

for i = 1:Maxorder+1
    for j = 1:2:2*i-1
        n = i-1;
        m = -n+j-1;
        if mod(m,4)~=0
            index_modified(i,j) = m;
            if index_modified(i,j) > 0
                for k=1:2:2*i-1
                    if index_modified(i,j)==abs(index_modified(i,k))
                        moment_extracted(i,j) = conj(moment_extracted(i,k));
                        break
                    end
                end
            end
        end
    end
end
end