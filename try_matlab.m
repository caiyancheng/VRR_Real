syms P positive
syms intensity positive
syms mu positive
syms target_p positive
syms guess_p positive
syms beta positive

solve(P - (1 - exp(log(1 - (target_p - guess_p) / (1 - guess_p)) * (intensity / mu)^beta)) * (1 - guess_p) + guess_p, mu)