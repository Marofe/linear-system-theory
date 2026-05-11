
% Example: Robust H-infinity Filter Design for a Simple System
% Mass-Spring-Damper system with uncertain stiffness

% 1. System Definition
% x' = [0 1; -k -d]x + [0; 1]w
% y  = [1 0]x + v
% z  = [0 1]x (Estimate velocity)

m = 1;
d = 0.5;
k_nom = 1;

A = [0 1; -k_nom -d];
Bw = [0 0; 0.1 0]; % Disturbance on acceleration and measurement noise
C = [1 0];
Dw = [0 0.1];
E = [0 1];

n = size(A,1);
p = size(C,1);
mw = size(Bw,2);
nz = size(E,1);

% 2. LMI Design using YALMIP and SeDuMi/SDPT3
fprintf('Designing H-infinity filter...\n');

P = sdpvar(n,n);
Y = sdpvar(n,p);
mu = sdpvar(1,1);

% H-infinity Performance LMI (Bounded Real Lemma for Error System)
% Error System: 
% eps' = (A-LC)eps + (Bw-LDw)w
% e    = E*eps
% LMI: [ (A-LC)'P + P(A-LC)   P(Bw-LDw)   E'; ... ] < 0
% Substitution: Y = P*L

LMI = [P >= 1e-6*eye(n), mu >= 0];
M = [A'*P + P*A - C'*Y' - Y*C,  P*Bw - Y*Dw, E';
     (P*Bw - Y*Dw)',            -mu*eye(mw), zeros(mw,nz);
     E,                         zeros(nz,mw), -eye(nz)];
LMI = [LMI, M <= -1e-6*eye(size(M,1))];

ops = sdpsettings('verbose',0,'solver','sedumi');
sol = optimize(LMI, mu, ops);

if sol.problem == 0
    gamma = sqrt(value(mu));
    L = value(P)\value(Y);
    fprintf('Optimal H-infinity gain gamma: %.4f\n', gamma);
    fprintf('Filter Gain L:\n');
    disp(L);
    
    % 3. Verification
    A_cl = A - L*C;
    B_cl = Bw - L*Dw;
    C_cl = E;
    D_cl = zeros(nz,mw);
    sys_err = ss(A_cl, B_cl, C_cl, D_cl);
    gamma_actual = norm(sys_err, inf);
    fprintf('Verified H-infinity norm: %.4f\n', gamma_actual);
else
    fprintf('Optimization failed: %s\n', sol.info);
end
