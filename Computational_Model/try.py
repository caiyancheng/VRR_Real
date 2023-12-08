import sympy as sp

# 定义符号
P, intensity, beta, target_p, guess_p, mu = sp.symbols('P intensity beta target_p guess_p mu')

# 定义函数
expr = (1 - sp.exp(sp.log(1 - (target_p - guess_p) / (1 - guess_p)) * (intensity / mu)**beta)) * (1 - guess_p) + guess_p

# 求解反函数
inverse_expr = sp.solve(sp.Eq(expr, P), mu)

# 打印结果
print("原函数:", expr)
print("反函数:", inverse_expr)