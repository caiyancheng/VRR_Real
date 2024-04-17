import numpy as np
import matplotlib.pyplot as plt
import math


def watson2018_ecc_s(spatial_frequency, eccentricity):
    k1 = 0.0401
    k2 = 0.0081
    S_ecc = 10 ** (-(k1 * spatial_frequency + k2) * eccentricity)
    return S_ecc


def watson2018_ecc_s_yancheng(spatial_frequency, eccentricity):
    k1 = 0.0401
    k2 = 0.0081
    # Use the Guassian as the weight
    a = 1
    b = 10
    c = 10
    Guassian_ecc = a * np.exp(-(eccentricity - b) ** 2 / (2 * c ** 2))
    S_ecc = 10 ** (-(k1 * spatial_frequency + k2) * eccentricity) * Guassian_ecc
    return S_ecc


def yancheng_all_new_1(spatial_frequency, eccentricity):
    # Use the Pure Guassian
    # a = 1
    # b = 10
    # c = 30
    # k_sf_1 = 5
    # k_sf_2 = 0.1
    a = 1 #0.00205397
    b = 1.58284
    c = 0.0951465
    k_sf_1 = 6.48362
    k_sf_2 = 0.146885
    S_ecc = a * np.exp(
        -(eccentricity + k_sf_1 * spatial_frequency - b) ** 2 / (2 * c ** 2)) * 10 ** (
                    -k_sf_2 * spatial_frequency)
    return S_ecc


def yancheng_all_new_2(spatial_frequency, eccentricity):
    # Use the Pure Guassian
    a = 1
    b = 10
    c = 50
    k_sf_1 = 5
    k_sf_2 = 0.1
    k_sf_3 = 5
    S_ecc = a * np.exp(
        -(eccentricity + k_sf_1 * spatial_frequency - b) ** 2 / (2 * (c - k_sf_3 * spatial_frequency) ** 2)) * 10 ** (
                    -k_sf_2 * spatial_frequency)
    return S_ecc


if __name__ == '__main__':
    ecc_array = np.arange(0, 100, 1)
    spaitial_frequency_list = [0, 1, 2, 3]
    plt.figure(figsize=(20, 6))
    plt.subplots_adjust(left=0.03, right=0.97, top=0.9, bottom=0.2, wspace=0.2)
    for sp_f_index in range(len(spaitial_frequency_list)):
        sp_f = spaitial_frequency_list[sp_f_index]
        plt.subplot(1, len(spaitial_frequency_list), sp_f_index + 1)
        S_array = watson2018_ecc_s(sp_f, ecc_array)
        S_array_2 = watson2018_ecc_s_yancheng(sp_f, ecc_array)
        S_array_3 = yancheng_all_new_1(sp_f, ecc_array)
        plt.plot(ecc_array, S_array, label='Watson Original', color='r')
        plt.plot(ecc_array, S_array_2, label=f'Watson Guassian Revision - Yancheng',
                 color='g')
        plt.plot(ecc_array, S_array_3, label='Pure Guassian - Yancheng', color='b')
        plt.title(f'Spatial Frequency = {sp_f} cpd')
        plt.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1), fancybox=True, shadow=True, ncol=1)

    # plt.legend(loc='upper center', bbox_to_anchor=(0.5, -0.1), fancybox=True, shadow=True, ncol=1)

    plt.xlabel('Eccentricity')
    plt.ylabel('Sensitivity')
    plt.show()
