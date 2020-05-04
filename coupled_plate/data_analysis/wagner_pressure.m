function [rs, ps, pmax] = wagner_pressure(sigmas, t, s, sdot, sddot, eps)

% Turnover point
d = sqrt(3 * (t - s));
ddot = (sqrt(3)/2) * (1 - sdot) ./ sqrt(t - s);
dddot = - (sqrt(3)/4) * ((1 - sdot).^2 + 2 * (t - s) .* sddot)...
    ./ (t - s).^(3/2);

% Jet thickness
J = 2 * (t - s).^(3/2) / (sqrt(3) * pi);

%% Outer solution
outer_p = @(rhat, t) (1/eps) ...
    * (4 * (2 * d^2 - rhat.^2) * ddot^2 ./ (3 * pi * sqrt(d^2 - rhat.^2)) ...
    + 4 * d * dddot * sqrt(d^2 - rhat.^2) / (3 * pi));

%% Inner solution
tilde_r = @(sigma, t) - (J/pi) * (sigma + 4 * sqrt(sigma) + log(sigma) + 1);
inner_r = @(sigma, t) eps * d + eps^3 * tilde_r(sigma, t);
inner_p = @(sigma, t) (1 / eps^2) * 2 * ddot^2 * sqrt(sigma) ./ (1 + sqrt(sigma)).^2;

%% Overlap solution
overlap = @(r, t) 2 * sqrt(2) * d^(3/2) * ddot^2 ...
    ./ (3 * pi * eps^2 * sqrt(d / eps^2 - r / eps^3));

%% Composite solution
all_rs = inner_r(sigmas, t);
pos_idxs = find(all_rs > 0);
rs = all_rs(pos_idxs);
sigmas = sigmas(pos_idxs);
ps = real(inner_p(sigmas, t) + outer_p(rs/eps, t) - overlap(rs, t));

%% Maximum pressure
% Returns the maximum pressure value which is evaluated at r = d

% Find the value of sigma at tilde_r = 0
zero_fun = @(sigma) sigma + 4 * sqrt(sigma) + log(sigma) + 1;
sigma_max = fsolve(zero_fun, 0.0233);
pmax = real(inner_p(sigma_max, t) + outer_p(inner_r(sigma_max, t)/eps, t)...
    - overlap(inner_r(sigma_max, t)/eps, t));

    

end