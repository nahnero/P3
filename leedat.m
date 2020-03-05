%LEEDAT   Lee ficheros de datos .DAT
%
%	[ecg,fs,n_signals,fname,fpath]=leedat(def_path);
%	- ecg: se�ales de ecg (cada columna es una derivaci�n)
%	- fs: frecuencia de muestreo de 'ecg'
%	- n_signals: n�mero de derivaciones presentes en la se�al
%	- fname: string con el nombre del fichero
%	- fpath: string con el directorio del fichero
%	- def_path: si se incluye esta variable, al abrir vamos directamente a este directorio
%------------------------------------------------------------------------------------------------------------
%Programado por:
%		�lvaro Mart�nez Romero
%		almarro1@teleco.upv.es
%		Febrero 2001


function [ecg, fs, n_signals, fname, fpath]=leedat(fpath, fname);

%Iniciamos las variables contenidas en el fichero .HEA

%L�nea de registro
wd = pwd;
r_name='';  %Nombre del registro
n_signals=[]; %N�mero de se�ales;
fs=[]; %Frecuencia de muestreo
cf=[]; %Frecuencia de contador
bcv=[]; %Valor del contador base
n_muestras=[]; %N�mero de muestras por se�al
base_time=''; %Hora de inicio de la se�al
base_date=''; %Fecha del comienzo del registro

%L�neas espec�ficas de la se�al
f_name={}; %Nombre del fichero que contiene la se�al
format=[]; %Formato de almacenamiento de la se�al
byte_offset=[]; %Bytes ocupados por el pre�mbulo
ADC_gain=[]; %Ganancia del ADC
baseline=[]; %Valor de la l�nea base
units=''; %Unidades de las se�ales
ADC_res=[]; %Bits del ADC
ADC_zero=[]; %Valor que saca el ADC para una entrada igual a la mitad del rango del mismo
initial_value=[]; %Valor de la muestra n�mero 1
checksum=[];
block_size=[]; %Especifica el tama�o de bloques a usar para leer el fichero. Por defecto=0
description=''; %Descripci�n de la se�al

%==========================================================
%Cambiamos al directorio de trabajo:
   cd(pwd);

%Lo primero que leemos es el el fichero .HEA

% switch nargin
% case 0
   % [fname,fpath] = uigetfile('*.dat', 'Load ECG File');
   % if (fname == 0) & (fpath == 0) % si cancelo me salgo
		% return;
	% end
% case 1
   % antes = pwd;
   % if def_path(1:2) == '.\'
       % def_path = [pwd def_path(2:end)];
   % elseif def_path(1:3) == '..\'
       % str = pwd;
       % pos = find(str == '\');
       % def_path = [str(1:pos(end)) def_path(4:end)];
   % end

   % if ((def_path(end-3:end) == '.dat')|(def_path(end-3:end) == '.DAT'))
       % pos = find(def_path == '\');
       % fpath = def_path(1:pos(end));
       % fname = def_path(pos(end)+1:end);
   % else
       % cd(def_path)
       % [fname,fpath] = uigetfile('*.dat', 'Load ECG File');
       % cd(antes);
       % if (fname == 0) & (fpath == 0) % si cancelo me salgo
		  % return;
       % end
   % end

% end


hname=[fpath strtok(fname,'.') '.hea']; %Nombre del fichero .HEA
if exist(hname) == 0 %Comprobamos que exita el fichero
   	errordlg('El fichero de cabecera no existe!!!. No es posible cargar la se�al de ECG'...
         , 'Error');
      return;
   end


   %Abrimos los ficheros
   heafid=fopen(hname,'r');
   l_reg=fgetl(heafid);
   %header = char(fread(heafid, inf, 'uchar')');	%matriz con el fichero
   %fclose(heafid); %Ya no es necesario tenerlo abierto


   %Procesamos la informaci�n del fichero
   %L�nea de registro

   [r_name,l_reg]=strtok(l_reg); %Nombre del registro
   [n_signals,l_reg]=strtok(l_reg); %N�mero de derivaciones
   n_signals=str2num(n_signals); %Para tenerlo como entero
   %A partir de ahora, los campos son opcionales
   if isempty(l_reg)
   else
      [fs,l_reg]=strtok(l_reg,'/');
      if isempty(l_reg) %No existe el campo cf
         [fs,l_reg]=strtok(fs);
      else
         [cf,lreg]=strtok(l_reg,'(');
         if isempty(l_reg)
            [cf,l_reg]=strtok(cf);
         else
            [bcv,l_reg]=strtok(l_reg,') ');
            bcv=str2num(bcv);
         end
         cf=str2num(cf);
      end
      fs=str2num(fs);
   end
   if isempty(l_reg)
   else
      [n_muestras,l_reg]=strtok(l_reg);
      n_muestras=str2num(n_muestras);
   end

   if isempty(l_reg)
      [base_time,l_reg]=strtok(l_reg);
   end
   if isempty(l_reg)
      base_date=strtok(l_reg);
   end

   %L�neas de se�al
   for i=1:n_signals
      l_reg=fgetl(heafid);

      [f_name_b,l_reg]=strtok(l_reg);
      [format_b,l_reg]=strtok(l_reg,'+');
      if isempty(l_reg)
         [format_b,l_reg]=strtok(format_b);
      else
         [byte_offset,l_reg]=strtok(l_reg);
         byte_offset=str2num(byte_offset);
      end
      format_b=str2num(format_b);
      %A partir de ahora par�metro opcionales


      %======================
      %Terminar esto
      %Por ahora no me hace falta m�s info
      %======================
      %f_name=setfield(f_name,num2str(i),f_name_b);
      format(i)=format_b;
   end




   %Pasamos a leer el fichero de datos

   %Abrimos el fichero .DAT
   datfid=fopen([fpath fname],'r'); %asumimos que existe
   %Dependiendo del formato:
   switch format(1) %Suponemos que todas la se�ales poseen el mismo formato
   case 8
      ecgfile = fread(datfid, inf, 'int8')';
   case 16
      ecgfile = fread(datfid, inf, 'int16')';
      % h=waitbar(0,'Cargardo fichero');
	   for n=1:n_signals
              % waitbar(n/n_signals);
      	ecg(n,:)=ecgfile(n:n_signals+1:(n_signals+1)*n_muestras);%Derivaciones por columnas
   	end
	   % close(h);

	case 61
      %Este caso es an�logo al anterior
      ecgfile = fread(datfid, inf, 'int8')';
      disp(length(ecgfile))
      % h=waitbar(0,'Cargardo fichero');
	   for n=1:n_signals
         % waitbar(n/n_signals);
         high=ecgfile(2*n-1:2*(n_signals+1):2*(n_signals+1)*n_muestras);
         low=ecgfile(2*n:2*(n_signals+1):2*(n_signals+1)*n_muestras);
         ecg(n,:)=high*256+low;
     	end
	   % close(h);

   case 80
      tipo='';
   case 160
   case 212
      ecgfile = fread(datfid, inf, 'bit12')';
      % h=waitbar(0,'Cargardo fichero');
	   for n=1:n_signals
         ecg(n,:)=ecgfile(n:n_signals:n_signals*n_muestras);%Derivaciones por columnas
         % waitbar(n/n_signals);
   	end
      % close(h);

   case 310
      ecgfile = fread(datfid, inf, 'bit10')';
   end  %Switch format(1)
   for i=1:n_signals
       ecg(i,:)=ecg(i,:)-mean(ecg(i,:));
   end
   fclose(datfid);
   fclose(heafid);

% Restauramos la ruta de trabajo
cd(wd);













