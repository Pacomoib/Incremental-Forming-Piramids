% Pirámide hecho con dos direcciones
% Dos incrementos 
% Ángulo de Pared Variable
% Ing. Francisco Elías Moya Ibáñez

clear
clc
close all
format short
%% Datos de Entrada 
%Ancho de la Pirámide
AnchoPirade=80;
%Profundiad de la Pirámide
ZFinal=23; %mm
% Radio de la esquina
r=5;
%Cantidad de puntos para dibujar la esquina
ResEsq=7;
%Incremento en profundiad
ValInc=0.25/2; %Valor del incremento
%Ángulo Inicial
AInit=40;%40
%Ángulo Final
AFin=80;
ShowSimulation=1;


%% Calculos 
%Profundidad de la pirámide, inicia en cero y va aumentando en -Z
IncZ=0;
L = AnchoPirade/2;
%Longitud de las líneas 
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

%Ciclo for para generar los valores de los radianes para las esquinas flag2 va de 1 a 5
Angles = [];
for Angle=0:pi/2:2*pi
    Angles = [Angles, Angle];
end
%línea inicial que va del centro al extremo
x=(0:L:L);
ly=length(x);
y=zeros(1,ly);
z=zeros(1,ly);

while (abs(IncZ)<ZFinal)
    DirGiro=1; %Dirección de giro de la copa
    for i=1:4
    [x,y,z] = Corner(x,y,z,r,IncZ,Angles(i),Angles(i+1),ResEsq,LL,DirGiro);
    if i==2
        L=-L;
        [x,y,z,IncZ,L,LL]=IncrementoZ(x,y,z,L,LL,IncZ,ValInc,AnchoAng(D))
        L=-L;
    end
    end
    [x,y,z,IncZ,L,LL]=IncrementoZ(x,y,z,L,LL,IncZ,ValInc,AnchoAng(D));
    DirGiro=-1; %Dirección de giro de la copa
    for j=4:-1:1
    [x,y,z] = Corner(x,y,z,r,IncZ,Angles(j+1),Angles(j),ResEsq,LL,DirGiro);
    if j==3
        L=-L;
        [x,y,z,IncZ,L,LL]=IncrementoZ(x,y,z,L,LL,IncZ,ValInc,AnchoAng(D))
        L=-L;
    end
    end
    [x,y,z,IncZ,L,LL]=IncrementoZ(x,y,z,L,LL,IncZ,ValInc,AnchoAng(D));
    D=D+1;
end

%% Archivo con las coordenadas
%Se crea el archivo con las coordenadas
fileID2 = fopen('PAV2I.txt','w');
fprintf(fileID2,'X         Y         Z\n');
%Se crea el archivo para las coordenadas del CNC
fileID = fopen('GCodePAV2I.nc','w');
LGC=0; % Línea para el código G del CNC
for i=1:1:length(x)
    LGC=LGC+5;
    fprintf(fileID,'N%i G1X%f Y%f Z%f \n',LGC,x(i),y(i),z(i));
    fprintf(fileID2,'%f %f %f\n',x(i),y(i),z(i));
end
%% Figura 
if ShowSimulation ==1
    figure(1)
    h = plot3(NaN,NaN,NaN);
    xlabel('x'); ylabel('y'); zlabel('z');
    title('Pirámide de ángulo variable con 1 Incremento');
    for k=1:length(x)
        set(h,'XData',x(1:k),'YData',y(1:k),'ZData',z(1:k));
        pause(0.1)
    end
end
%% Funciones 
function [x,y,z]=Corner(x,y,z,r,IncZ,Angle1,Angle2,ResEsq,LL,DirGiro)
if DirGiro ==1
    AQ=Angle1+(45*(pi/180));
else
    AQ=Angle1-(45*(pi/180));
end
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

for tetha=Angle1:DirGiro*(pi/2)/ResEsq:Angle2
    x=[x,r*cos(tetha)+LL*D1];
    y=[y,r*sin(tetha)+LL*D2];
    z=[z,IncZ];
end
end

function [x,y,z,IncZ,L,LL]=IncrementoZ(x,y,z,L,LL,IncZ,ValInc,AnchoAng)
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
