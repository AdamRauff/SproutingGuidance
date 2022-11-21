%This function gets the angle from x an y

function a=get_angle(x,y)

if x>=0 && y>=0 % first quadrant
    a = atan(y/x)*180/pi;
elseif x<=0 && y >= 0 % second quadrant
    a = 180 + atan(y/x)*180/pi;
elseif x <= 0 && y <= 0 % third quadrant
    a=180+atan(y/x)*180/pi;
elseif x>=0 && y<= 0 % fourth quadrant
    a= 360 + atan(y/x)*180/pi;
else
    a = .111;
end

if x==0 && y>0
    a = 90;
elseif x == 0 && y< 0
    a = 270;
elseif y== 0 && x>0
    a = 0;
elseif y==0 && x<0
    a = 180;
end


end