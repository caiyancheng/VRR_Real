import numpy as np
from scipy.optimize import curve_fit
import scipy as sy
import matplotlib.pyplot as plt
import sympy as sp
np.random.seed(42)

# psychometric function
def pf_dec_exp(intensity, mu, beta, target_p, guess_p):
    # Exponential psychometric function, decreases with intensity
    P = (np.exp(np.log(1 - (target_p - guess_p) / (1 - guess_p)) * (intensity / mu) ** beta))*(1-guess_p) + guess_p
    return P

def pf_inc_exp(intensity, mu, beta, target_p, guess_p):
    # Exponential psychometric function, decreases with intensity
    P = (1 - np.exp(np.log(1 - (target_p - guess_p) / (1 - guess_p)) * (intensity / mu) ** beta))*(1-guess_p) + guess_p
    return P

def invert_pf_inc_exp(intensity, P, beta, target_p, guess_p):
    mu = intensity / (np.log((P - 1) / (guess_p - 1)) / np.log((target_p - 1) / (guess_p - 1))) ** (1 / beta)
    return mu

def compute_P_from_C_T(C_T, mu):
    beta = 3.5
    target_p = 0.75
    guess_p = 0.5
    P = pf_inc_exp(intensity=C_T, mu=mu, beta=beta, target_p=target_p, guess_p=guess_p)
    return P

def fit_pf_dec_exp(intensity, P, beta, target_p, guess_p, initial_mu_guess):
    def wrapped_pf_dec_exp(x, mu):
        return pf_dec_exp(x, mu, beta, target_p, guess_p)
    params, covariance = curve_fit(wrapped_pf_dec_exp, intensity, P, p0=[initial_mu_guess])
    return params

def fit_pf_inc_exp(intensity, P, beta, target_p, guess_p, initial_mu_guess):
    def wrapped_pf_inc_exp(x, mu):
        return pf_inc_exp(x, mu, beta, target_p, guess_p)
    params, covariance = curve_fit(wrapped_pf_inc_exp, intensity, P, p0=[initial_mu_guess])
    return params


if __name__ == '__main__':
    intensity = np.arange(-100,100,0.1)
    mu = 30
    beta = 3.5
    target_p = 0.75
    guess_p = 0.5
    P = pf_dec_exp(-1, mu, beta, target_p, guess_p)
    # np.random.seed(42)
    # noise = np.random.normal(0, 0.02, len(intensity))
    # P_with_noise = P + noise
    plt.figure()
    plt.plot(intensity, P)
    plt.xlabel('Intensity')
    plt.ylabel('Probability')
    plt.show()
    # initial_guess = [mu]
    # fitted_params = fit_pf_dec_exp(intensity, P_with_noise, beta, target_p, guess_p, initial_guess)
    # print("Fitted Parameters:")
    # print("mu:", fitted_params[0])
    # plt.figure()
    # plt.plot(intensity, P_with_noise, label='Noisy Data')
    # plt.plot(intensity, pf_dec_exp(intensity, fitted_params[0], beta, target_p, guess_p), label='Fitted Curve')
    # plt.xlabel('Intensity')
    # plt.ylabel('Probability')
    # plt.legend()
    # plt.show()
