#!/usr/bin/env python
# coding: utf-8

# In[27]:


## Prédiction du Rendement:

def PredRendement(ETo,Rendement,V_a_predire):

    # Librairies et fonctions
    import pandas as pd
    import numpy as np
    import seaborn as sns
    import matplotlib.pyplot as plt
    from sklearn.gaussian_process import GaussianProcessRegressor
    from sklearn.gaussian_process.kernels import RBF
    import pandas as pd
    import matplotlib.pyplot as plt
    from sklearn.metrics import r2_score
    from sklearn.gaussian_process import GaussianProcessRegressor
    from sklearn.gaussian_process.kernels import RBF
    from sklearn.gaussian_process.kernels import ExpSineSquared
    from sklearn.gaussian_process.kernels import RationalQuadratic
    from sklearn.gaussian_process.kernels import WhiteKernel

    # Créons un vecteur RendementPredire
    RendementPredire = np.zeros(len(V_a_predire))


    # Créaction du dataframe à partir des vecteurs
    df = pd.DataFrame({
    'ETo': ETo,
    'Rendement': Rendement})

    df.fillna(value={"Rendement":df["Rendement"].median()}, inplace=True)

    # valeur < Q1 - 1,5*IQR ou valeur > Q3 + 1,5*IQR
    # La fonction nous permet de trouver des lignes avec des donnees aberantes

    def finding_outliers(data, variable_name) -> pd.DataFrame:
        iqr = data[variable_name].quantile(0.75) - data[variable_name].quantile(0.25)
        lower = data[variable_name].quantile(0.25) - 1.5*iqr
        upper = data[variable_name].quantile(0.75) + 1.5*iqr
        return data[(data[variable_name] < lower) | (data[variable_name] > upper)]


    iqr_fare = df["Rendement"].quantile(0.75) - df["Rendement"].quantile(0.25)
    df.loc[finding_outliers(df, "Rendement").index, "Rendement"] = df["Rendement"].quantile(0.75) + 1.5*iqr_fare
    long_term_trend_kernel = 50.0**2 * RBF(length_scale=50.0)

    # Utilisation d'un noyau périodique
    seasonal_kernel = (2.0**2* RBF(length_scale=100.0)* ExpSineSquared(length_scale=1.0, periodicity=1.0, periodicity_bounds="fixed"))

    # Irregularités par un noyau quadratique rationnel
    irregularities_kernel = 0.5**2 * RationalQuadratic(length_scale=1.0, alpha=1.0)

    # Ajout d'un bruit blanc
    noise_kernel = 0.1**2 * RBF(length_scale=0.1) + WhiteKernel( noise_level=0.1**2, noise_level_bounds=(1e-5, 1e5))

    # Pour le noyau final, faisons une addition de tous les noyaux locaux
    df_kernel = (long_term_trend_kernel + seasonal_kernel + irregularities_kernel + noise_kernel)
    X = df["ETo"].to_numpy().reshape(-1, 1)
    y = df["Rendement"].to_numpy()

    # Ajustement du modèle et extrapolation
    # Utilisons un régresseur de processus gaussen et ajustons les données disponibles Data.
    y_mean = y.mean()
    gaussian_process = GaussianProcessRegressor(kernel=df_kernel, normalize_y=False)
    gaussian_process.fit(X, y - y_mean)
    X_test = np.linspace(X.min(), X.max(), 1000).reshape(-1, 1)
    mean_y_pred, std_y_pred = gaussian_process.predict(X_test,return_std=True  )
    mean_y_pred += y_mean

    # Prédictions sur les données d'origine
    y_pred = gaussian_process.predict(X)
    y_pred += y_mean

    # Calcul du R²
    r2 = r2_score(y, y_pred)
    print(f"R² = {r2:.4f}")

    # Test du score:
    # 80% pour l'entraînement
    n_train = int(0.8 * len(X))
    X_train, X_test = X[:n_train], X[n_train:]
    y_train, y_test = y[:n_train], y[n_train:]

    # Entraînement
    y_mean = y_train.mean()
    gp = GaussianProcessRegressor(kernel=df_kernel, normalize_y=False)
    gp.fit(X_train, y_train - y_mean)

    # Prédiction test
    y_test_pred = gp.predict(X_test) + y_mean

    # R² test
    r2_test = r2_score(y_test, y_test_pred)
    print(f"R² test = {r2_test:.4f}")

    V_a_predire = np.array(V_a_predire).reshape(-1,1)
    RendementPredire = gp.predict(V_a_predire) + y_mean
    return RendementPredire


