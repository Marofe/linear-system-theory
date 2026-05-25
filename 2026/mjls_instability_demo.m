clc; clear all; close all;

%% Numerical Experiment: MJLS Switched Instability
% This script demonstrates a classic counterexample in hybrid systems:
% An autonomous Markov Jump Linear System (MJLS) where EACH individual mode
% is asymptotically stable (eigenvalues inside the unit circle), but the
% switched system under Markov switching is stochastically UNSTABLE 
% (specifically, not Mean Square Stable - MSS).
%
% System Dynamics: x(k+1) = A_theta(k) * x(k)
% Mode set: theta(k) in {1, 2}

rng(42); % Set random seed for reproducibility

%% 1. System Parameters
% Mode 1 matrix: Asymptotically stable (eigenvalues are 0.5 and 0.5)
A1 = [0.5, 1.5; 
      0.0, 0.5];

% Mode 2 matrix: Asymptotically stable (eigenvalues are 0.5 and 0.5)
A2 = [0.5, 0.0; 
      1.5, 0.5];

% Display eigenvalues of individual modes
disp('--- Individual Subsystem Stability Check ---');
disp('Eigenvalues of A1:');
disp(eig(A1));
disp('Eigenvalues of A2:');
disp(eig(A2));

%% 2. Markov Chain Transition Matrix
% Transition probability matrix: High probability of switching modes
% P(i,j) = Pr(theta(k+1) = j | theta(k) = i)
P = [0.1, 0.9; 
     0.9, 0.1];

disp('--- Transition Probability Matrix P ---');
disp(P);
%%
num_runs = 1000;      % Number of Monte Carlo realizations
num_steps = 30;       % Number of time steps
x0 = [1; 1];          % Initial state
%% 4. Simulate Individual Modes (No Switching)
% Simulate pure Mode 1 response: x(k+1) = A1 * x(k)
% Simulate pure Mode 2 response: x(k+1) = A2 * x(k)
x_mode1 = zeros(2, num_steps + 1);
x_mode2 = zeros(2, num_steps + 1);
x_m1 = x0;
x_m2 = x0;
x_mode1(:, 1) = x_m1;
x_mode2(:, 1) = x_m2;

for k = 1:num_steps
    x_m1 = A1 * x_m1;
    x_m2 = A2 * x_m2;
    x_mode1(:, k + 1) = x_m1;
    x_mode2(:, k + 1) = x_m2;
end

figure
subplot(2,1,1)
plot(x_mode1','o-',linewidth=2)
xlabel('Time')
ylabel('States')
title('Mode 1')
grid on
subplot(2,1,2)
plot(x_mode2','o-',linewidth=2)
xlabel('Time')
ylabel('States')
title('Mode 2')
grid on
%% 3. Monte Carlo Switched Simulation


% Preallocate arrays to store data
% State trajectories for all realizations: [dimension x steps x runs]
X_runs = zeros(2, num_steps + 1, num_runs); 
theta_runs = zeros(num_steps + 1, num_runs);
figure
disp('Simulating MJLS trajectories...');
for r = 1:num_runs
    x = x0;
    theta = 1; % Start in Mode 1
    X_runs(:, 1, r) = x;
    theta_runs(1, r) = theta;
    num_steps=10;
    for k = 1:num_steps
        % Determine next mode based on transition probabilities of current mode
        p_transition = P(theta, :);
        r_val = rand();
        if r_val <= p_transition(1)
            theta = 1;
        else
            theta = 2;
        end
        
        % Apply active dynamics
        if theta == 1
            x = A1 * x;
        else
            x = A2 * x;
        end

       
        X_runs(:, k + 1, r) = x;
        theta_runs(k + 1, r) = theta;
        subplot(2,1,1)
        plot(X_runs(:,1:k+1,r)','o-',linewidth=2)
        xlabel('Time')
        ylabel('States')
        title('MJLS')
        grid on
        subplot(2,1,2)
        stairs(theta_runs(1:k+1,r)','bo-',linewidth=2)
        xlabel('Time')
        ylabel('Modes')
        title('Markov Chain')
        grid on
    end
end



%% 5. Calculate Expected Behavior (Mean Square State)
% Compute empirical mean square norm: E[||x_k||^2]
mean_square_norm = zeros(num_steps + 1, 1);
for k = 1:(num_steps + 1)
    squared_norms = zeros(num_runs, 1);
    for r = 1:num_runs
        squared_norms(r) = norm(X_runs(:, k, r))^2;
    end
    mean_square_norm(k) = mean(squared_norms);
end

%% 6. Plotting Results
% figure('Position', [100, 100, 1100, 480]);
% 
% % Subplot A: Realizations (individual state trajectories)
% subplot(1, 2, 1);
% hold on;
% num_plot_runs = min(20, num_runs); % Plot first 20 trajectories
% h_sw = plot(0:num_steps, squeeze(norm(X_runs(:, :, 1), 2)), 'Color', [0.75, 0.75, 0.75], 'LineWidth', 1.0);
% for r = 2:num_plot_runs
%     plot(0:num_steps, squeeze(norm(X_runs(:, :, r), 2)), 'Color', [0.75, 0.75, 0.75], 'LineWidth', 1.0);
% end
% % Plot individual mode responses (no switching)
% h_m1 = plot(0:num_steps, squeeze(norm(x_mode1, 2)), 'b--', 'LineWidth', 2.5);
% h_m2 = plot(0:num_steps, squeeze(norm(x_mode2, 2)), 'k:', 'LineWidth', 2.5);
% 
% grid on;
% title('Individual Realizations vs. Pure Modes');
% xlabel('Time step (k)');
% ylabel('State Norm ||x_k||');
% legend([h_sw, h_m1, h_m2], {'Switched Runs', 'Pure Mode 1 (Stable)', 'Pure Mode 2 (Stable)'}, 'Location', 'NorthWest');
% set(gca, 'FontSize', 11);
% 
% % Subplot B: Expected Value (Mean Square State Norm on logarithmic scale)
% subplot(1, 2, 2);
% semilogy(0:num_steps, mean_square_norm, 'r-', 'LineWidth', 2.5);
% grid on;
% title('Empirical Mean Square State: E[||x_k||^2]');
% xlabel('Time step (k)');
% ylabel('E[||x_k||^2] (Log Scale)');
% set(gca, 'FontSize', 11);
% 
% % Add text annotation for the transition matrix P on the figure
% annotation('textbox', [0.44, 0.73, 0.12, 0.14], ...
%            'String', {'P =', '  [ 0.1   0.9 ]', '  [ 0.9   0.1 ]'}, ...
%            'FontSize', 11, 'FontName', 'monospace', ...
%            'FontWeight', 'bold', 'BackgroundColor', [1 1 1 0.9], ...
%            'EdgeColor', [0.5 0.5 0.5], 'LineWidth', 1.5, ...
%            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
% 
% sgtitle('Stochastic Instability of MJLS with Stable Subsystems', 'FontSize', 14, 'FontWeight', 'bold');
% 
% % Save the figure to the images directory
% images_dir = fullfile('..', 'images');
% if ~exist(images_dir, 'dir')
%     mkdir(images_dir);
% end
% saveas(gcf, fullfile(images_dir, 'mjls_instability.png'));

%% 7. Theoretical Instability Verification (switching operator)
% An MJLS is MSS iff the spectral radius of the coupled Lyapunov operator is < 1.
% Let's build the Kronecker representation of the Lyapunov operator.
L1 = kron(A1, A1)';
L2 = kron(A2, A2)';
% Switched Lyapunov transition matrix:
T = [P(1,1)*L1, P(1,2)*L1;
     P(2,1)*L2, P(2,2)*L2];
spectral_radius = max(abs(eig(T)));

disp('--- Theoretical Mean Square Stability (MSS) Verification ---');
fprintf('Spectral radius of the coupled Lyapunov operator: %.4f\n', spectral_radius);
if spectral_radius >= 1
    disp('Theoretical Result: The system is stochastically UNSTABLE (spectral radius >= 1).');
else
    disp('Theoretical Result: The system is Mean Square Stable.');
end
