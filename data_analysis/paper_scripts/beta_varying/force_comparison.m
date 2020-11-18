%% force_comparison.m
% Script to compare the forces on the plate for where the initial height
% has been varied. The times are shifted so the theoretical time of impact
% is always the same
%

% Adds analytical forces to the path
addpath(genpath("~/repos/plate-impact/data_analysis"));

%% Data definitions


% Parent directory where all the data is held
parent_directory = '/mnt/newarre/cantilever_paper_data/beta_varying/';

% Directory to save the figure(s)
analysis_directory = "Analysis";
analysis_directory = strcat(parent_directory, analysis_directory);

% Range of alphas
betas = [0, 7.07,  28.28, 141.42];

% Defines arrays for all the values of alpha
data_directories = string(length(betas));
legend_entries = string(length(betas));

for k = 1 : length(betas)
    beta = betas(k);
    
    data_directories(k) = [parent_directory, '/beta_', num2str(beta)];
    
    legend_entries(k) = ['$\beta =$ ', num2str(beta)] ;
end

% Stationary plate data
stationary_plate_directory = '/mnt/newarre/cantilever_paper_data/stationary_plate';


%% Parameters

% Value of epsilon
eps = 1;

% Plate parameters
alpha = 2;
beta = 0;
gamma = 100;

% Initial drop height 
initial_drop_heights = 0.125;

% Impact time 
impact_time = initial_drop_heights;

% Maximum time
t_max = 0.8;

%% Wagner solution
% Stationary plate Wagner solution
wagner_t = linspace(1e-7, t_max - impact_time, 1e3);
s = zeros(size(wagner_t));
sdot = zeros(size(wagner_t));
sddot = zeros(size(wagner_t));

% Composite force solution
wagner_force = composite_force(wagner_t, s, sdot, sddot, eps);

%% Plotting
close all;

% Force comparison
fig = figure(1);
hold on;

N = length(data_directories);

start_color = 0.75;
end_color = 0.3;

m = (end_color - start_color) / (N - 1);
c = 0.5 * (start_color + end_color - (N + 1) * m);

for k = 1 : length(data_directories)
   output_mat = dlmread(sprintf("%s/cleaned_data/output.txt", data_directories(k)));
   
   line_color = (m * k + c) * [1 1 1];
   
   ts = output_mat(:, 1);
   Fs = output_mat(:, 3);
   ss = output_mat(:, 6);
   
   % Rescale ts with the impact time
   ts = ts - impact_time;
   
   figure(1);
   plot(ts, Fs, 'Displayname', legend_entries(k), 'Linewidth', 2, ...
       'color', line_color);
   
end

% Force comparison
figure(1);
output_mat = dlmread(sprintf("%s/cleaned_data/output.txt", ...
    stationary_plate_directory));
ts = output_mat(:, 1);
ts = ts - impact_time;
Fs = output_mat(:, 3);
plot(ts, Fs, 'Linewidth', 3, 'color', 'black', ...
    'Displayname', ['Stationary', newline, 'plate']);

plot(wagner_t, wagner_force, ...
    'color', 'black', 'Linewidth', 3, 'Linestyle', '--', ...
    'Displayname', ['Analytical', newline, 'solution']);
% legend("Interpreter", "latex", "location", "southeast", "Fontsize", 12);

% x limits
xlim([-impact_time t_max - impact_time]);


% Arrow for increasing beta
X = [0.55 0.375];
Y = [0.45 0.675];
annotation('arrow', X, Y);
grid on;
xlabel("$t$", "Interpreter", "latex");
ylabel("$F(t)$", 'Interpreter', 'latex');
set(gca, 'XTick', 0 : 0.2 : t_max);
set(gca, 'YTick', 0 : 1 : 5 );

% Arrow label
txt = '$\beta$';
text(0.025, 3.3, txt, "Interpreter", "Latex", "Fontsize", 30);

ax = gca;
ax.FontSize = 30;
set(gca,'TickLabelInterpreter','latex');
% title(['Force on plate: $\alpha =$ ', ...
%     num2str(alpha), ', $\gamma =$ ' num2str(gamma)], "Interpreter", "latex", ...
%     'Fontsize', 14);

set(gcf, 'Position',  [0, 0, 500, 700]);
ax = gca;

plot_name = sprintf("%s/beta_force_comparison.png", analysis_directory);
pause(0.1);
exportgraphics(ax, plot_name, 'resolution', 300);


