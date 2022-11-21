function [angle_out] = adjust_angle_difference(angle_in)

angle_out = angle_in;

while ( abs(angle_out) > 90 )
    if(angle_out > 90)
        angle_out = angle_out - 180;
    elseif(angle_out < 0)
        angle_out = angle_out + 180;
    end
end

end