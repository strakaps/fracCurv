function [C2,C1,C0] = barlow

s = log(8)/log(3);
%r_1 = r_2 = r_3 = 1/2;
r = power(1-3*power(2,-s),1/s); %the inner triangle's size

eta = -3*(power(1/2,s)*log(1/2))-power(r,s)*log(r);


xi = @(x) exp(i*x);
v  = @(x) 1/4 * xi(-2*pi/3) + x*xi(2*pi/3);
x0 = fzero(@(x) abs(v(x)-x)-r, 0.1);

w = x0 - v(x0);
alpha = imag(log(w)); % the most pointed angle in the picture

% auxiliary angles

beta = pi/6 + alpha/2;




%R = @(a) [[cos(a),-sin(a)];[sin(a),cos(a)]]; %Rotationsmatrix

% the global curvatures of the equilateral triangle with length 1

t2 = sqrt(3)/4;
t1 = 3; t0 = 1;

%calculate the area of the biggest wedge-shaped gaps (W) now
% the longest side of it has length x0 + 0.25
w2 = ((1/4) - power(r,2)) * t2 /3;
W2 = @(x) power((x/(x0+0.25)),2) * w2;

%calculate the incircle omega of W. its sides have length
% x0+0.25, 0.25-x0, r
omega = 2*w2/(0.5+r);



u0 = 0;
u1 = omega;
u2 = r;
u3 = 1/2;
u4 = 1;

% calculating C_2 now

a00 = 0;                    a01 = 0;        
a02 = -3*(1/sin(alpha)+1/(2*tan(alpha))+w2/(power(sin(alpha)*(x0+1/4),2))+1-tan(pi/6-alpha)/2+(pi/2+alpha)/2)-2*pi-3*sqrt(3);

a10 =(1-3/4-power(r,2))*t2; a11 =(1-3*0.5-r)*t1;        a12 = -3 * t0;
a20 =(1-3/4)*t2;            a21 =(1-3*0.5)*t1;          a22 = -2 * t0;
a30 = t2;                   a31 = t1;                   a32 = t0;
a40 = 0;                    a41 = 0;                    a42 = 0;

stuff1 = (a00-a10)*u1^(s-2) + (a10-a20)*u2^(s-2) + (a20-a30)*u3^(s-2) + (a30-a40)*u4^(s-2);
stuff2 = (a01-a11)*u1^(s-1) + (a11-a21)*u2^(s-1) + (a21-a31)*u3^(s-1) + (a31-a41)*u4^(s-1);
stuff3 = (a02-a12)*u1^s     + (a12-a22)*u2^s     + (a22-a32)*u3^s     + (a32-a42)*u4^s;

stuff = stuff1 /(s-2) + stuff2 / (s-1) + stuff3 / s;

C2 =  stuff / eta;

% calculating C_1 now

a00 = 0;                    a01 = -3*(tan(beta)+tan(pi/2-alpha/2))-pi - 3/2*(4+pi);
a10 = -3/4 - 3*r/2;         a11 = -3*pi;
a20 = (3 - 9/2)/2;          a21 = (2*pi - 6*pi)/2;
a30 = 3 / 2;                a31 = pi;
a40 = 0;                    a41 = 0;

stuff0 = (a00-a10)*u1^(s-1) + (a10-a20)*u2^(s-1) + (a20-a30)*u3^(s-1) + (a30-a40)*u4^(s-1);
stuff1 = (a01-a11)*u1^s + (a11-a21)*u2^s + (a21-a31)*u3^s + (a31-a41)*u4^s;

stuff  = stuff0 / (s-1) + stuff1 / s;

C1 = stuff / eta;

% calculating C_0 now

a00 = -6;                  
a10 = -3; 
a20 = -2;           
a30 = 1;                
a40 = 0;                  

stuff = (a00-a10)*u1^s + (a10-a20)*u2^s + (a20-a30)*u3^s + (a30-a40)*u4^s;

stuff = stuff / s;

C0 =  stuff / eta;


end
