function [moment_modified,index_modified_neg,message,dq]=embedding(moment_original,Maxorder,Step)
% initialize the variable
K = 1000;
moment_modified = moment_original;
index_modified_neg = zeros(size(moment_original));
messlens = 0;
% get the embedding capacity and generate secret message
for i = 2:Maxorder+1
    for j = 1:2:i
        n = i-1;
        m = -n+j-1;
        if mod(m,4)~=0
            messlens = messlens+1;
        end
    end
end
rng(1)
message=round(rand(messlens,1));

dq = zeros(size(moment_original));

% embedding message to the moment matrix(m<0)
count = 1;
for i = 2:Maxorder+1
    for j = 1:2:i

        n = i-1;
        m = -n+j-1;
        M0 = moment_original(1,1);

        if mod(m,4)~=0
            M = moment_original(i,j);
            mag = abs(M);
            nmag = (mag/M0)*K;
            nmag_int = floor(nmag);
            nmag_dec = nmag-nmag_int;
            nmag_quant = nmag_int-mod(nmag_int,Step);
            dq(i,j) = nmag_int-nmag_quant;% the quantization error

            if message(count)==1
                nmag_em = nmag_quant+(3/4)*Step+nmag_dec;
            elseif message(count)==0
                nmag_em = nmag_quant+(1/4)*Step+nmag_dec;
            end

            mag_em = (nmag_em*M0)/K;
            M_em = (mag_em/mag)*M;
            moment_modified(i,j) = M_em;

            count = count+1;
            index_modified_neg(i,j) = m;
        end

    end
end

% modify the moment matrix(m>0)
index_modified = zeros(size(moment_original));

for i = 1:Maxorder+1
    for j = 1:2:2*i-1
        n = i-1;
        m = -n+j-1;
        if mod(m,4)~=0
            index_modified(i,j) = m;
            if index_modified(i,j) > 0
                for k=1:2:2*i-1
                    if index_modified(i,j)==abs(index_modified(i,k))
                        moment_modified(i,j) = conj(moment_modified(i,k));
                        dq(i,j) = dq(i,k);
                        break
                    end
                end
            end
        end
    end
end
end
