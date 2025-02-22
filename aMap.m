function [actMap1] = aMap(data,stat,endp,Fs,cmap)
%% aMap is the central function for creating conduction velocity maps
% [actMap1] = aMap(data,stat,endp,Fs,bg) calculates the activation map
% for a single action potential upstroke.

% INPUTS
% data = cmos data (voltage, calcium, etc.) from the micam ultima system.
% 
% stat = start of analysis (in msec)
%
% endp = end of analysis (in msec)
%
% Fs = sampling frequency
%
% bg = black and white background image from the CMOS camera.  This is a
% 100X100 pixel image from the micam ultima system. bg is stored in the
% handles structure handles.bg.
%
% cmap = a colormap input that facilites the potential inversion of the
% colormap. cmap is stored in the handles structure as handles.cmap.
%
%
% OUTPUT
% actMap1 = activation map
%
% METHOD
% An activation map is calculated by finding the time of the maximum derivative 
% of each pixel in the specified time-windowed data.
%
% REFERENCES
%
% ADDITIONAL NOTES
%
% RELEASE VERSION 1.0.1
%
% AUTHOR: Qing Lou, Jacob Laughner (jacoblaughner@gmail.com)
%
% MAINTAINED BY: Christopher Gloschat - (cgloschat@gmail.com) - [Jan. 2015 - Present] 
%
% MODIFICATION LOG:
%
% Jan. 26, 2015 - The input cmap was added to input the colormap and code
% was added at the end of the function to set the colormap to the user
% determined values. In this case the most immediate purpose is to
% facilitate inversion of the default colormap.
%
%

%% Code
% Create initial variables
stat=round(stat*Fs);
endp=round(endp*Fs);
% Code not used in current version %
% % actMap = zeros(size(data,1),size(data,2));
% % mask2 = zeros(size(data,1),size(data,2));

% identify channels that have been zero-ed out due to noise
if size(data,3) == 1
    temp = data(:,stat:endp);       % Windowed signal
    temp = normalize_data(temp);    % Re-normalize data in case of drift
    mask = max(temp,[],2) > 0;      % Generate mask
else
    temp = data(:,:,stat:endp);     % Windowed signal
    temp = normalize_data(temp);    % Re-normalize data in case of drift
    mask = max(temp,[],3) > 0;      % Generate mask
end

% Code not used in current version %
% % % % Remove non-connected artifacts
% % % CC = bwconncomp(mask,4);
% % % numPixels = cellfun(@numel,CC.PixelIdxList);
% % % [~,idx] = max(numPixels);
% % % mask_id = CC.PixelIdxList{idx};
% % % mask2(mask_id) = 1;

% Find First Derivative and time of maxium
if size(data,3) == 1
    temp2 = diff(temp,1,2);
    [~,max_i] = max(temp2,[],2);
else
    temp2 = diff(temp,1,3); % first derivative
    [~,max_i] = max(temp2,[],3); % find location of max derivative
end

% Activation Map Matrix
actMap1 = max_i.*mask;
actMap1(actMap1 == 0) = nan;
offset1 = min(min(actMap1));
actMap1 = actMap1 - offset1*ones(size(actMap1,1),size(actMap1,2));
actMap1 = actMap1/Fs*1000; %% time in ms

% Plot Map
if size(data,3) ~= 1
    zz = figure('Name','Activation Map');
    contourf(flipud(actMap1),endp-stat,'LineColor','none')
    title('Activation Map')
    axis image
    axis off
    colormap(cmap);
    colorbar;
end


end




