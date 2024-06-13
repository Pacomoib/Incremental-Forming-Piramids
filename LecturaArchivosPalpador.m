clear
clc
close all

%Se incluyen las carpetas 
addpath(genpath(pwd))
% Probeta Digitalizada con Palpador
DataXP1_1I=ReadX('P1AV40801IX.dig'); DataYP1_1I=ReadY('P1AV40801IY.dig');
DataP1_1I=CutDataPal(DataXP1_1I.x,DataXP1_1I.y,DataXP1_1I.z,DataYP1_1I.y,DataYP1_1I.x,DataYP1_1I.z);

figure(1)
hold on ; grid on ; grid minor
xlim([-45,45]); ylim([-22,2]);
plot(DataXP1_1I.x,DataXP1_1I.z,':','Color',"#0072BD",'LineWidth',2)
xlabel('X [mm]'); ylabel('Z [mm]')
ax = gca; ax.FontSize = 16;
title('Pieza Digitalizada con Palpador - 1I - X','FontSize',16)

figure(2)
hold on ; grid on ; grid minor
xlim([-45,45]); ylim([-22,2]);
plot(DataP1_1I.LX,DataP1_1I.LXZ,':','Color',"#0072BD",'LineWidth',2)
xlabel('X [mm]'); ylabel('Z [mm]')
ax = gca; ax.FontSize = 16;
title('Pieza Digitalizada con Palpador - 1I - X','FontSize',16)


function  obj = ReadX(fname)
% obj = ReadX(fname)
%
% This function parses .dig data files from VIWA-CNC
% It reads the feeler coordinates
% Tue output is a .obj file 
% 
%
% INPUT: fname - file full name including extension 
%
% OUTPUT: obj.X - Axis X coordinates 
%       : obj.Y - Axis Y coordinates
%       : obj.Z - Axis Z coordinates
%
% Francisco Moya, Guanajuato University
% May,2023

% Set up field types
X = []; Y = []; Z = [];
f.x = [];f.y = [];f.z = [];
% Open document
fid = fopen(fname);
% Choose the line data to read 
RdON1=0; % Read long lines data
RdON2=0; % Read short lines data
j=0; % Saves the number of lines read
Val=-40; % Feeler initial coordenate 
while 1
    tline = fgetl(fid);
    if ~ischar(tline),   break,   end  % exit at end of file
    ln = sscanf(tline,'%s',1); % line type
    SCP=strcmp(ln,'G1'); %String comparation
    if RdON2 ==1
            X = [X; sscanf(tline(2:end),'%f')'];
            XS = sscanf(tline,'%s',1); 
            ValX=length(XS);
            Y = [Y;Val];
            Z = [Z; sscanf(tline(ValX+3:end),'%f')'];
            j=j+1;
        if j==80
            RdON1 =0;
            RdON2 =0;
            Val=Val+5;
            j=0;
        end
        RdON1=0;
    end
    if RdON1 ==1
        X = [X; sscanf(tline(2:end),'%f')'];
        XS = sscanf(tline,'%s',2); % line type
        ValX=length(XS);
        Y = [Y; sscanf(tline(11:end),'%f')'];
        Z = [Z; sscanf(tline(ValX+4:end),'%f')'];
        RdON2=1;
    end
    % G1, start recording data
    if SCP ==1
        RdON1 =1;
        RdON2 =0;
    end
    %f.x = [f.x; X];f.x = [f.y; Y];f.x = [f.z; Z];
end
fclose(fid);
% set up matlab object 
obj.x=X; obj.y=Y; obj.z=Z; 
end
%--------------------------------------------------------------------------
function obj= ReadY(fname)
% obj = ReadY(fname)
%
% This function parses .dig data files from VIWA-CNC
% It reads the feeler coordinates
% Tue output is a .obj file 
% 
%
% INPUT: fname - file full name including extension 
%
% OUTPUT: obj.X - Axis X coordinates 
%       : obj.Y - Axis Y coordinates
%       : obj.Z - Axis Z coordinates
%
% Francisco Moya, Guanajuato University
% May,2023

% Set up field types
X = []; Y = []; Z = [];f.x = [];f.y = [];f.z = [];
% Open document
fid = fopen(fname);
% Choose the line data to read 
RdON1=0; % Read long lines data
RdON2=0; % Read short lines data
j=0; % Saves the number of lines read
Val=-40; %% Feeler initial coordenate 
while 1
    tline = fgetl(fid);
    if ~ischar(tline),   break,   end  % exit at end of file
    ln = sscanf(tline,'%s',1); % line type
    SCP=strcmp(ln,'G1'); %String comparation
    if RdON2==1
            Y = [Y; sscanf(tline(2:end),'%f')'];
            XS = sscanf(tline,'%s',1); % line type
            ValX=length(XS);
            X = [X;Val];
            Z = [Z; sscanf(tline(ValX+3:end),'%f')'];
            j=j+1;
        if j==80
            RdON1 =0;
            RdON2 =0;
            Val=Val+5;
            j=0;
        end
        RdON1=0;
    end
    if RdON1 ==1
        X = [X; sscanf(tline(2:end),'%f')'];
        XS = sscanf(tline,'%s',2); % line type
        ValX=length(XS);
        Y = [Y; sscanf(tline(ValX-5:end),'%f')'];
        Z = [Z; sscanf(tline(ValX+4:end),'%f')'];
        RdON2=1;
    end
    %G1, start recording data
    if SCP ==1
        RdON1 =1;
        RdON2 =0;
    end
    f.x = [f.x; X];f.x = [f.y; Y];f.x = [f.z; Z];
end
fclose(fid);
% set up matlab object 
obj.x=X; obj.y=Y; obj.z=Z;
end


function obj = CutDataPal(DataXLX,DataXLY,DataXLZ,DataYLY,DataYLX,DataYLZ)
CortLX=[]; CortLXZ=[];CortLY=[]; CortLYZ=[]; 
    for i=1:length(DataXLY)
        if DataXLY(i) == 0
            CortLX=[CortLX,DataXLX(i)];
            CortLXZ=[CortLXZ,DataXLZ(i)];
        end
         if DataYLX(i) == 0
            CortLY=[CortLY,DataYLY(i)];
            CortLYZ=[CortLYZ,DataYLZ(i)];
        end
    end
    obj.LX=CortLX; obj.LXZ=CortLXZ; obj.LY= CortLY ; obj.LYZ=CortLYZ;
end