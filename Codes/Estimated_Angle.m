clear;
clc;
close all;

f0 = 77e9;
c = 3e8;
lambda = c / f0; 
theta_true = 38 * pi / 180; % True angular position in radians

dx = lambda / 4; % Spacing between antennas
delta_theta = 2 * pi / 180;
L = lambda / delta_theta;
N = floor(L / dx + 1); % Number of antennas in the array
n = -N/2:N/2-1; 
n_space = n * dx;

fs = 4 * f0;
Nfft = 2^10;
f_axis = linspace(-1/(2*dx), 1/(2*dx), Nfft);
dt = 1 / fs;

fx = 2 * sin(theta_true) / lambda; % Spatial frequency due to target angle
sR_demod = exp(1j * 2 * pi * fx * dx * n);

% FFT for Direction of Arrival (DoA) Estimation
S_R = fftshift(fft(sR_demod, Nfft)) * dx;
[peak, idx_f_peak] = max(abs(S_R)); % Find FFT peak and its index
f_peak = f_axis(idx_f_peak);

% Verify spatial frequency range
if abs(f_peak) > 2 / lambda
    error('Spatial frequency exceeds unambiguous range. Check antenna spacing or target angle.');
end

% Map spatial frequencies to angles
theta_estimate = asin((lambda * f_peak) / 2);
angles = asin(f_axis * lambda / 2);
angles_deg = rad2deg(angles);

threshold = 0.005;
idx_min_peak = find(abs(S_R(idx_f_peak:end)) < threshold, 1); % First zero index after peak
delta_fx = abs(f_axis(idx_f_peak) - f_axis(idx_f_peak + idx_min_peak)); % Spatial frequency resolution
Estimated_Resolution = (delta_fx * lambda / 2) * (180 / pi); % Angular resolution in degrees

fprintf('True Angle (degrees): %.2f\n', rad2deg(theta_true));
fprintf('Estimated Angle (degrees): %.2f\n', rad2deg(theta_estimate));
%fprintf('Spatial Frequency (Delta f_x): %.4e cycles/m\n', delta_fx);
%fprintf('True Spatial Frequency (f_x): %.4e cycles/m\n', fx);
fprintf('Spatial Frequency Resolution (degrees): %.2f\n', Estimated_Resolution);

% Visualization: FFT Spectrum with True and Estimated Targets
figure();
plot(angles_deg, abs(S_R), 'LineWidth', 2, 'DisplayName', 'FFT Spectrum');
hold on;
scatter(rad2deg(theta_true), peak, 100, 'r', 'filled', 'DisplayName', 'True Target'); % True target with circle
scatter(rad2deg(theta_estimate), peak, 80, 'g', 'filled', 's', 'DisplayName', 'Estimated Target'); % Estimated target with square
xlabel('Angle (degrees)');
ylabel('Magnitude');
title('FFT Spectrum with True and Estimated Target');
legend('show');
grid on;

% Visualize Zero-Crossing for Angular Resolution
figure();
plot(angles_deg, abs(S_R), 'LineWidth', 2, 'DisplayName', 'FFT Spectrum');
hold on;
plot(angles_deg(idx_f_peak + idx_min_peak), abs(S_R(idx_f_peak + idx_min_peak)), 'r*', 'MarkerSize', 8, 'DisplayName', 'Zero-Crossing'); % Zero-crossing point
scatter(rad2deg(theta_true), peak, 100, 'r', 'filled', 'DisplayName', 'True Target');
scatter(rad2deg(theta_estimate), peak, 80, 'g', 'filled', 's', 'DisplayName', 'Estimated Target');
grid on;
xlabel('Angle (degrees)');
ylabel('Magnitude');
title('FFT Spectrum with Zero-Crossing and Target Markers');
legend('show');
hold off; 

% Visualization: Surface Plot
[theta_mesh, freq_mesh] = meshgrid(angles_deg, f_axis); % Create grid for angle and frequency
amplitude_mesh = repmat(abs(S_R), length(angles_deg), 1); % Repeat amplitude for mesh

figure();
surf(freq_mesh, theta_mesh, amplitude_mesh', 'EdgeColor', 'none');
hold on;

% Mark True and Estimated Target on Surface Plot
scatter3(fx, rad2deg(theta_true), peak, 100, 'r', 'filled', 'DisplayName', 'True Target'); % True target
scatter3(f_peak, rad2deg(theta_estimate), peak, 80, 'g', 'filled', 'DisplayName', 'Estimated Target'); % Estimated target

title('Surface Plot: Spatial Frequency vs Angle and Amplitude');
xlabel('Spatial Frequency (cycles/m)');
ylabel('Angle (degrees)');
zlabel('Amplitude');
colormap('jet'); % Use 'jet' for colormap
colorbar;
legend('show');
grid on;
