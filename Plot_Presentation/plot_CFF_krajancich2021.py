import pandas as pd
import matplotlib.pyplot as plt

dataset_file = 'flicker_detection_datasets.csv'
df = pd.read_csv(dataset_file)

sub_df = df[df['dataset'] == 'krajancich2021']
luminance_list = [3, 23.9, 190]
ecc_list = [0, 14.84368352, 29.20530948, 42.69061437, 55.04442917]
plt.figure(figsize=(4,4), dpi=300)

for luminance in luminance_list:
    X_ecc_list = []
    Y_CFF_list = []
    for ecc in ecc_list:
        subsub_df = sub_df[(sub_df['luminance'] == luminance) & (sub_df['eccentricity'] == ecc) & (sub_df['radius'] == 1.225)]
        CFF = subsub_df['t_frequency'].iloc[0]
        X_ecc_list.append(ecc)
        Y_CFF_list.append(CFF)
    plt.plot(X_ecc_list, Y_CFF_list, 'o-', label=f'{luminance} [cd/m$^2$]')
plt.xlabel('Eccentricity [degree]')
plt.ylabel('CFF [Hz]')
plt.xticks([0,20,40,60])
plt.yticks([20,30,40,50,60,70,80])
plt.title('Krajancich2021 CFF')
plt.legend()
plt.tight_layout()
# plt.show()
plt.savefig('krajancich2021_CFF.png', dpi=300)

