% Pirámide hecha con dos direcciones
% 1 Incremento en Z
% Ángulo de Pared Variable
% Ing. Francisco Elías Moya Ibáñez

clear
clc
close all
format short
%% Datos de Entrada 
AnchoPirade=80; %Ancho de la Pirámide
ZFinal=23;%Profundiad de la Pirámide en mm
r=5; % Radio de la esquina
ResEsq=7;%Cantidad de puntos para dibujar la esquina
ValInc=0.25; %Valor del incremento en profundidad
AInit=40; %Ángulo Inicial
AFin=80; %Ángulo Final

ShowSimulation=1;

%% Calculos 
%Profundidad de la pirámide, inicia en cero y va aumentando en -Z
IncZ=0;
% Distancia del centro a una pared de la pirámide
L = AnchoPirade/2;
%Longitud de las líneas entre las esquinas
LL=L-r; %30
% Divide la diferencia entre Ángulo Inicial y Final en la cantidad de
% incrementos necesarios para llegar al final de la pirámide
Factor=(AFin-AInit)*(ValInc/ZFinal);
%Ciclo para calcular el valor del ángulo de la pared en cada incremento de
%profundidad
AnchoAng=[];
for i=AInit:Factor:AFin
    AnchoAng=[AnchoAng,ValInc/tan(i*pi/180)];
end
D=1; %Se utiliza para señalar que valor de AnchoAng se usará
%%
%Ciclo for para generar los valores de los radianes para las esquinas
Angles = [];
for Angle=0:pi/2:2*pi
    Angles = [Angles, Angle];
end
%% Inicio de la pirámide Truncada 
%línea inicial que va del centro al extremo
x=(0:L:L);
ly=length(x);
y=zeros(1,ly);
z=zeros(1,ly);
% Ciclo Principal 
while (abs(IncZ)<ZFinal)
    DirGiro=1; %Dirección de giro de la copa
    for i=1:4
    [x,y,z] = Corner(x,y,z,r,IncZ,Angles(i),Angles(i+1),ResEsq,LL,DirGiro);
    end
    [x,y,z,IncZ,L,LL]=IncrementoZ(x,y,z,L,LL,IncZ,ValInc,AnchoAng(D));
    DirGiro=-1; %Dirección de giro de la copa
    for j=4:-1:1
    [x,y,z] = Corner(x,y,z,r,IncZ,Angles(j+1),Angles(j),ResEsq,LL,DirGiro);
    end
    [x,y,z,IncZ,L,LL]=IncrementoZ(x,y,z,L,LL,IncZ,ValInc,AnchoAng(D));
    D=D+1;
end
%% Archivo con las coordenadas
%Se crea el archivo con las coordenadas
fileID1 = fopen('PAV1I.txt','w');
fprintf(fileID1,'X         Y         Z\n');
%Se crean archivos para la simulación
fileID2 = fopen('PAV1ISimX.csv','w');
fileID3 = fopen('PAV1ISimY.csv','w');
fileID4 = fopen('PAV1ISimZ.csv','w');
%Tiempo para la simulación el milisegundos
Time = 20000; 
Xl=length(x)-1;
T=[];
for i=0:Time/Xl:Time
    T=[T,i];
end
%Se crea el archivo para las coordenadas del CNC
fileID5 = fopen('GCodePAV1I.nc','w');
LCG=5; % Línea para el código G del CNC
fprintf(fileID5,'N%i G90 G94\n',LCG); % G90 = cotas absolutas
LCG=LCG+5; fprintf(fileID5,'N%i G21\n',LCG); %G21= Unidades en mm
LCG=LCG+5; fprintf(fileID5,'N%i M25 G49\n',LCG); 
LCG=LCG+5; fprintf(fileID5,'N%i T90 M6\n',LCG); %Herramienta 90 y posicion home
LCG=LCG+5; fprintf(fileID5,'N%i G58\n',LCG); %Seleccionar sistema de coordenadas
LCG=LCG+5; fprintf(fileID5,'N%i G43 H90 Z100\n',LCG); %Compensación y herramienta
LCG=LCG+5; fprintf(fileID5,'N%i G0 X0.000   Y0.000   Z40.000 \n',LCG);
LCG=LCG+5; fprintf(fileID5,'N%i G0 X0.000   Y0.000   Z1.000 \n',LCG);
LCG=LCG+5; fprintf(fileID5,'N%i G0 F1000 X0.000   Y0.000   Z0.000 \n',LCG);
%Se guarda la información en los archivos 
for i=1:1:length(x)
    fprintf(fileID1,'%f %f %f\n',x(i),y(i),z(i));
    fprintf(fileID2,'%f %f \n',T(i),x(i));
    fprintf(fileID3,'%f %f \n',T(i),y(i));
    fprintf(fileID4,'%f %f \n',T(i),z(i));
    LCG=LCG+5;
    fprintf(fileID5,'N%i G1X%f Y%f Z%f \n',LCG,x(i),y(i),z(i));
end
%% Figura 
if ShowSimulation ==1
    figure(1)
    h = plot3(NaN,NaN,NaN);
    xlabel('X'); ylabel('Y'); zlabel('Z');
    ax = gca; ax.FontSize = 16;
    title('Pirámide de ángulo variable con 1 Incremento','FontSize',17);
    for k=1:length(x)
        set(h,'XData',x(1:k),'YData',y(1:k),'ZData',z(1:k));
        pause(0.01)
    end
end
%% Funciones 
function [x,y,z]=Corner(x,y,z,r,IncZ,Angle1,Angle2,ResEsq,LL,DirGiro)
    % Función para crear cada una de las esquinas 
    %De acuerdo a la dirección de giro se elige entre el cuadrante 1 y 4 para
    %iniciar la creación de esquinas. 
    if DirGiro ==1
        AQ=Angle1+(45*(pi/180));
    else
        AQ=Angle1-(45*(pi/180));
    end
    %utilizando el signo del seno y coseno se identifica en que cuadrante se
    %dibujará la esquina 
    Q1 = cos(AQ); Q2 = sin(AQ);
    if Q1 > 0
        D1=1;
    else
        D1=-1; 
    end
    if Q2 > 0
        D2=1;
    else
        D2=-1; 
    end
    %Ciclo for para crear una esquina
    for tetha=Angle1:DirGiro*(pi/2)/ResEsq:Angle2
        x=[x,r*cos(tetha)+LL*D1];
        y=[y,r*sin(tetha)+LL*D2];
        z=[z,IncZ];
    end
end

function [x,y,z,IncZ,L,LL]=IncrementoZ(x,y,z,L,LL,IncZ,ValInc,AnchoAng)
%Función para el incremento vertical
    x=[x,L];
    y=[y,0]; 
    z=[z,IncZ];
    IncZ=IncZ-ValInc;
    L=L-AnchoAng;
    x=[x,L]; 
    y=[y,0]; 
    z=[z,IncZ];
    LL=LL-AnchoAng;
end