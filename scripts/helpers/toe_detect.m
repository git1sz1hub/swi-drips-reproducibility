function toeLoc = toe_detect(salinity)
%TOE_DETECT Detect the toe location from the bottom salinity profile.

profile = salinity(end, :);
dProfile = abs(diff(profile));
[~, frontIndex] = max(dProfile);
toeLoc = frontIndex / size(profile, 2);
end
