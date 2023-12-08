from scipy.stats import binom
N = 162
P = 0.5
Y = [0.05, 0.95]

# 计算二项分布反函数
X = binom.ppf(Y, N, P)
print(X)

