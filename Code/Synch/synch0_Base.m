% Two coupled phase oscillators (Kuramoto) — visual demonstration of synchronization

clearvars; close all; clc

% Parameters
dt = 0.01;        % time step
T = 20;           % total time (s)
t = 0:dt:T;
N = numel(t);

% Natural frequencies (rad/s)
w1 = 2*pi*0.9;    % oscillator 1
w2 = 2*pi*1.1;    % oscillator 2

% Coupling strength (try increasing K to see sync)
K = 3.0;

% Initial phases
theta1 = zeros(1,N);
theta2 = zeros(1,N);
theta1(1) = 0.2;
theta2(1) = 2.5;

% Integration (Euler)
for k = 1:N-1
    dtheta1 = w1 + K * sin(theta2(k) - theta1(k));
    dtheta2 = w2 + K * sin(theta1(k) - theta2(k));
    theta1(k+1) = theta1(k) + dt * dtheta1;
    theta2(k+1) = theta2(k) + dt * dtheta2;
end

% Prepare figure with two panels
figure('Color','w','Position',[200 200 800 350])

% Panel 1: unit circle animation (phases)
ax1 = subplot(1,2,1);
theta_circle = linspace(0,2*pi,200);
plot(cos(theta_circle), sin(theta_circle), 'k:', 'LineWidth',1); hold on
h1 = plot(cos(theta1(1)), sin(theta1(1)), 'bo', 'MarkerFaceColor','b', 'MarkerSize',8);
h2 = plot(cos(theta2(1)), sin(theta2(1)), 'ro', 'MarkerFaceColor','r', 'MarkerSize',8);
line([-1.2 1.2],[0 0],'Color',[0.8 0.8 0.8]); line([0 0],[-1.2 1.2],'Color',[0.8 0.8 0.8]);
title('Oscillator Phases on Unit Circle'); axis equal off; xlim([-1.2 1.2]); ylim([-1.2 1.2]);

% Panel 2: phase difference vs time
ax2 = subplot(1,2,2);
phi = wrapToPi(theta1 - theta2);
hPhi = plot(t(1), phi(1),'b-'); hold on
yl = [-pi pi];
plot([t(1) t(end)], [0 0], 'k:');
ylim(yl); xlabel('Time (s)'); ylabel('Phase difference (rad)');
title(sprintf('Phase Difference (K = %.2f)', K));

% Animate
for k = 1:3:N
    set(h1, 'XData', cos(theta1(k)), 'YData', sin(theta1(k)));
    set(h2, 'XData', cos(theta2(k)), 'YData', sin(theta2(k)));
    set(hPhi, 'XData', t(1:k), 'YData', phi(1:k));
    drawnow
end

% Final prints
fprintf('Final phase difference (wrapped) = %.3f rad\n', wrapToPi(theta1(end)-theta2(end)));

for i=1:500
    x(i+1) = x(i);

    y(i+1) = y(i);




    plot(1:i,x(1:i),'b-')
    hold on
    plot(1:i,y(1:i),'r--')
    hold off


    drawnow
end