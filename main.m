clc; clear all; clf;

set(0,'DefaultFigureVisible','off');
orient ('landscape');
ax = gca;
ti = ax.TightInset;
outerpos    = ax.OuterPosition;
left        = outerpos(1) + ti(1) ;
bottom      = outerpos(2) + ti(2) + 0.1;
ax_width    = outerpos(3) - ti(1) - ti(3);
ax_height   = outerpos(4) - ti(2) - ti(4) - 0.1;
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
s = 20;
set (fig,'PaperSize',[s s/2]);


%{
 {  .o88o.  .o88o.     .
 {  888 `"  888 `"   .o8
 { o888oo  o888oo  .o888oo
 {  888     888      888
 {  888     888      888
 {  888     888      888 .
 { o888o   o888o     "888"
 %}


paciente = '001cltv1.dat';
[ecg, fs, n_signals, fname, fpath] = leedat ('./Senales/', paciente);

ecg = ecg (1,:);
plot (1:length (ecg), ecg);
fourier = fft (ecg);

fs/length (fourier)

Y = abs (fourier);
X = linspace (0, fs, length (fourier));

plot (X, Y, 'LineWidth', 1.2);
title (paciente);
xlabel ('Frequency (Hz)');
ylabel ('FFT');

print ('./plots/fft.pdf', '-dpdf','-fillpage');

[pks,locs, widths, proms] = findpeaks (Y(X<20), X(X<20),...
	'MinPeakDistance', 2);
plot (X(X<20), Y(X<20), locs, pks, 'o', 'LineWidth', 1.2);
title (paciente);
xlabel ('Frequency (Hz)');
ylabel ('FFT');
for i = 1:length (locs)
text (locs (i) - 0.45, pks (i) + 5.5e4, sprintf ("%.2f Hz\n%.1e",locs(i),pks(i)))
end
text (locs (2) + 0.15, pks (2)/2 , sprintf ("%.2f",widths (2)))

print ('./plots/fft1.pdf', '-dpdf','-fillpage');

fprintf ("%.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f\\\\\n",locs);
fprintf ("%.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f\\\\\n",locs/locs(2));
fprintf ("%d & %d & %d & %d & %d & %d & %d & %d\\\\\n",round (locs/locs(2)));


Y1 = abs (fft (ecg (1:1000)));
X1 = linspace (0, fs, length (Y1));
Y2 = abs (fft (ecg (1001:2000)));
X2 = linspace (0, fs, length (Y2));

Y1 = Y1(X1 < 20);
X1 = X1(X1 < 20);
Y2 = Y2(X2 < 20);
X2 = X2(X2 < 20);

plot (X1, Y1, X2, Y2,'LineWidth', 1.2);
title (paciente);
xlabel ('Frequency (Hz)');
ylabel ('FFT');

print ('./plots/fft2.pdf', '-dpdf','-fillpage');


%{
 {                            oooo            oooo
 {                            `888            `888
 { oooo oooo    ooo  .ooooo.   888   .ooooo.   888 .oo.
 {  `88. `88.  .8'  d88' `88b  888  d88' `"Y8  888P"Y88b
 {   `88..]88..8'   888ooo888  888  888        888   888
 {    `888'`888'    888    .o  888  888   .o8  888   888
 {     `8'  `8'     `Y8bod8P' o888o `Y8bod8P' o888o o888o
 %}

[Y, X] = pwelch (ecg, 4*fs, 2*fs, 8192, fs);

plot (X (X < 20), Y (X < 20), 'LineWidth', 1.2);
title (paciente);
xlabel ('Frequency (Hz)');
ylabel ('WELCH');
print ('./plots/welch.pdf', '-dpdf','-fillpage');


4*fs
length (ecg)/fs

[pks,locs, widths, proms] = findpeaks (Y(X<20), X(X<20),...
	'MinPeakHeight', .05e5);

plot (X(X<20), Y(X<20), locs, pks, 'o', 'LineWidth', 1.2);
title (paciente);
xlabel ('Frequency (Hz)');
ylabel ('WELCH');
for i = 1:length (locs)
text (locs (i) - 0.45, pks (i) + 5.5e4, sprintf ("%.2f Hz\n%.1e",locs(i),pks(i)))
end
text (locs (2) + 0.15, pks (2)/2 , sprintf (" %.2f",widths (2)))
print ('./plots/welch1.pdf', '-dpdf','-fillpage');

[Y, X] = pwelch (ecg, 1*fs, 0.5*fs, 8192, fs);
[pks,locs, widths, proms] = findpeaks (Y(X<20), X(X<20),...
	'MinPeakHeight', .05e5);
plot (X(X<20), Y(X<20), locs, pks, 'o', 'LineWidth', 1.2);
title (paciente);
xlabel ('Frequency (Hz)');
ylabel ('WELCH');
for i = 1:length (locs)
text (locs (i) - 0.25, pks (i) + 1.05e4, sprintf ("%.2f Hz\n%.1e",locs(i),pks(i)))
end
text (locs (1) + 0.7, pks (1)/2 , sprintf (" %.2f",widths (1)))

print ('./plots/welch2.pdf', '-dpdf','-fillpage');
