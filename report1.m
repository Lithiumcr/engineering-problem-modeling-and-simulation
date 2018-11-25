S=10000;           %repeating grouop number
n=5;                %variable, the number of nodes which decides the reliability of the system
unt =zeros(2*n,3);  %simulating every unreliable unit A & B of every node
gn=zeros(n,1);      %dexcribing the condition of every node(0,1,2,3,4,5)
MAXTIME=75000;
w=25000;
total_time = 0;
S0=0;

ta=95000;
tb=2900000;
lmda=1/ta;
lmdb=1/tb;
%main cycle
for i=1:S
    unt =zeros(2*n,3);  %simulating every unreliable unit A & B of every node
    gn=zeros(n,1);      %dexcribing the condition of every node(0,1,2,3,4,5)
    %mark every unit from 1 to 2n
    for j=1:2*n
        unt(j,1)=j;
    end
    for k=1:n
        unt(2*k-1,2) = min(MAXTIME,exprnd(ta));
        unt(2*k,2) = min(MAXTIME,exprnd(tb));
    end
    gsys=2;     %dexcribing the condition of every system(1,2,3,4)
    break_time = 0;
    tf=MAXTIME;
    for j=1:2*n
        unt=sortrows(unt,+2);
        tmp=unt(j,1);
        break_time = unt(j,2);
        unt(j,3)=errcnfm(tmp);
        no=ceil(tmp/2);
        unt=sortrows(unt,+1);
        
        gn(no,1)=ndcnfm([unt(2*no-1,3),unt(2*no,3)]);
        gsys=syscnfm(gn(:,:));
        if gsys==1||gsys==4
            tf=break_time;
            break
        end
    end
    
    total_time= total_time+tf;
    if tf>w
        S0=S0+1;
    end
end
MTTF=total_time/S;
Rw=S0/S;

%finally output the results
disp(MTTF);
disp(Rw);



%deciding the error type of unit A & B
function out =errcnfm(t)
rndnum=rand();
if mod(t,2)==0
    if rndnum<0.73
        out=1;
    else
        out=2;
    end
else
    if rndnum>0.5
        out = 3;
    elseif rndnum>0.23
        out = 2;
    else
        out = 1;
    end
end
end

%deciding the condition of node
function gn =ndcnfm(in)
if in(1)==3
    gn=4;
elseif in(1)==0
    if in(2)==0
        gn=0;
    elseif in(2)==1
        gn=3;
    else
        gn=1;
    end
elseif in(1)==1
    if in(2)==1
        gn=5;
    else
        gn=1;
    end
elseif in(1)==2
    if in(2)==0
        gn=2;
    elseif in(2)==1
        gn=3;
    else
        gn=4;
    end
end
end

%deciding the condition of a system
%PF,SO,DM,MO,DN,FB
%0, 1, 2, 3, 4, 5,
function gs = syscnfm(nd)
k=4;
c1=logical(sum(nd(:,:)==5)>=1);
c2=logical(sum(nd(:,:)==3)>=2);
c3=logical(sum(nd(:,:)==0)+sum(nd(:,:)==2)+sum(nd(:,:)==3)==0);
c4=logical(sum(nd(:,:)==0)+sum(nd(:,:)==1)+logical(sum(nd(:,:)==2)+sum(nd(:,:)==3)>0)<k);
c5=logical(sum(nd(:,:)==5)==0);
c6=logical((sum(nd(:,:)==3)==1)&&(sum(nd(:,:)==0)+sum(nd(:,:)==1)>=k-1));
c70=logical(sum(nd(:,:)==3)==0&&sum(nd(:,:)==0)>=1&&sum(nd(:,:)==0)+sum(nd(:,:)==1)>=k);
c71=logical(sum(nd(:,:)==3)==0&&sum(nd(:,:)==0)==0&&sum(nd(:,:)==2)>=1&&sum(nd(:,:)==1)>=k-1);
c7=c70||c71;
c8=logical(sum(nd(:,:)==3)+sum(nd(:,:)==5)==0);
c9=logical(sum(nd(:,:)==0)>=1&&sum(nd(:,:)==0)+sum(nd(:,:)==1)==k-1&&sum(nd(:,:)==2)>=1);

if c1||c2||c3||c4
    gs=1;
elseif c5&&(c6||c7)
    gs=2;
elseif c8&&c9
    crt=sum(nd(:,:)==2)/(sum(nd(:,:)==2)+sum(nd(:,:)==0));
    if rand()<crt
        gs=3;
    else
        gs=4;
    end
end
end