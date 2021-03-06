global size_set
size_set = [ 1E3, 1E4, 1E5, 1E6, 1E7];
len = size(size_set,2);
for i = 3:len
    d = 100;
    n_size = size_set(i);
    ep = 2;
    create_data(i, d, 8, 0.02, ep);
end
function [r] = create_data(sizeIdx,d,k,otl_ratio,ep)
global size_set
n = size_set(sizeIdx);
z = round(otl_ratio*n);
minN = z*ep; %the size of the minimum cluster C*
%generate k clusters with uniform size
avg_num = floor((n-z-minN)/(k-1));
if avg_num<=minN
    fprintf('ep is too big !!\n');
    return;
end
per_num = zeros(1,k) + avg_num;
per_num(1,1)=minN;
per_num(1,k)=n-z-minN-(k-2)*avg_num;

mu = rand(k,d)-0.5;
mu = mu.*400; 
SIGMA = eye(d)*sqrt(1000); %Gaussian distribution with variance 1000
data = zeros(n,d);target = zeros(n,1);
e1 = min(per_num)*k/n;
e2 = z*k/n;
c = 0;
for i=1:k
    D = mvnrnd(mu(i,:),SIGMA,per_num(i));
    data(c+1:c+per_num(i),:) = D;
    c = c+per_num(i);
end
c = 0;
for i=1:k
    target(c+1:c+per_num(i),1) = i;
    c = c+per_num(i);
end
%generate z outliers
r = radius(data(:,1:d),mu,z);
i=0;
while i<z
    Pz=(rand(1,d)-0.5)*400;
    dist = min(pdist2(Pz,mu));
    if dist>r
        data(n-z+1+i,:) = Pz;
        i=i+1;
    end
end

eta = 0.1:0.1:0.9;
eta=eta(eta>sqrt(e2/e1));
eta_len = size(eta,2);
delta = zeros(1,eta_len);
for j = 1:eta_len
    delta(j) = 1-e2/e1/eta(j)-0.01;
end
t = delta>0;
delta = delta(t);
eta = eta(t);
k_standard=k;
filename = ['./datasets_gen_size/n',num2str(sizeIdx), '_data.mat'];
save(filename,'data','target','k','k_standard','e1','e2','r','z','eta','delta','-v7.3');
clear;
end

function[r] = radius(P,mu,z)
D = pdist2(P,mu);
[rs,~] = min(D,[],2); 
[~,index1] = maxk(rs,z);
rs(index1,:) = [];
r = max(rs);
end
