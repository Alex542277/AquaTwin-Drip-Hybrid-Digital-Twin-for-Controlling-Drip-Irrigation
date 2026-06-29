#!/usr/bin/env python
# coding: utf-8

def EvapotranspirationCulture(lat,lon,date_debut,Tcroissance):

    Tcroissance=int(Tcroissance)
    import matplotlib
    matplotlib.use("Agg")

    import matplotlib.pyplot as plt
    plt.ioff()

    import pandas as pd
    import numpy as np
    from datetime import datetime, timedelta
    import requests

    from sklearn.gaussian_process import GaussianProcessRegressor
    from sklearn.gaussian_process.kernels import (
    RBF, ExpSineSquared, RationalQuadratic, WhiteKernel)
    
    from sklearn.metrics import r2_score

    def PenmanMontheithParameter(T, RH, u2, Rs):
        """
        Calcul des paramètres nécessaires à l'équation de Penman-Monteith FAO56

        Entrées :
        T  : température (°C)
        RH : humidité relative (%)
        u2 : vitesse du vent à 2 m (m/s)
        Rs : rayonnement solaire (MJ/m²/jour)

        Sorties :
        Delta : pente de la courbe de pression de vapeur (kPa/°C)
        Gamma : constante psychrométrique (kPa/°C)
        Rn    : rayonnement net (MJ/m²/jour)
        G     : flux de chaleur du sol (MJ/m²/jour)
        T     : température moyenne (°C)
        VPD   : déficit de pression de vapeur (kPa)
        u2    : vitesse du vent (m/s)
        """

        # Pression de vapeur saturante
        ew = 0.6108 * np.exp((17.27 * T) / (T + 237.3))

        # Pression de vapeur réelle
        e = RH * ew / 100

        # Déficit de pression de vapeur
        VPD = ew - e

        # Pente de la courbe de pression de vapeur
        Delta = (4098 * ew) / ((T + 237.3) ** 2)

        # Constante psychrométrique
        P = 101.3
        Gamma = 0.000665 * P

        # Rayonnement net
        alpha = 0.23
        Rn = (1 - alpha) * Rs

        # Flux de chaleur du sol
        G = np.zeros_like(Rn)

        jour = Rs > 0

        G[jour] = 0.1 * Rn[jour]
        G[~jour] = 0.5 * Rn[~jour]

        return Delta, Gamma, Rn, G, T, VPD, u2

    def CalculEvapotranspirationJournaliereAll(T, RH, u2, Rs):
        """
        Calcul de l'évapotranspiration de référence journalière ETo
        selon Penman-Monteith FAO56.

        Entrées :
        T  : température moyenne journalière (°C)
        RH : humidité relative (%)
        u2 : vitesse du vent à 2 m (m/s)
        Rs : rayonnement solaire (MJ/m²/jour)

        Sortie :
        ETo : évapotranspiration de référence (mm/jour)
        """

        Delta, Gamma, Rn, G, T, VPD, u2 = PenmanMontheithParameter(
            T, RH, u2, Rs
        )

        # Numérateur
        numerateur = (
            0.408 * Delta * (Rn - G)
            + Gamma * (900 / (T + 273)) * u2 * VPD
        )

        # Dénominateur
        denominateur = Delta + Gamma * (1 + 0.34 * u2)

        # ETo
        ETo = numerateur / denominateur

        # Éviter les valeurs négatives
        ETo = np.maximum(ETo, 0)
        return ETo

    date = datetime.today()
    jour_julien = date.timetuple().tm_yday
    annee = date.year
    date = datetime(annee, 1, 1) + timedelta(days=jour_julien - 3)
    real_day = date.strftime("%Y%m%d")


    url = (
        f"https://power.larc.nasa.gov/api/temporal/daily/point?"
        f"parameters=T2M,RH2M,WS2M,ALLSKY_SFC_SW_DWN,PRECTOTCORR"
        f"&community=AG"
        f"&longitude={lon}"
        f"&latitude={lat}"
        f"&start=20200101"
        f"&end={real_day}"
        f"&format=JSON"
    )

    response = requests.get(url)

    if response.status_code != 200:
        raise Exception("Erreur API NASA POWER")

    data = response.json()
    params = data["properties"]["parameter"]
    df = pd.DataFrame({
            "DATE": params["T2M"].keys(),
            "T": params["T2M"].values(),
            "RH": params["RH2M"].values(),
            "u2": params["WS2M"].values(),
            "Rs": params["ALLSKY_SFC_SW_DWN"].values(),
            "PRECIP": params["PRECTOTCORR"].values()
        })

    df["DATE"] = pd.to_datetime(df["DATE"], format="%Y%m%d")
    df["DOY"] = df["DATE"].dt.dayofyear

    # Récupérer les colonnes numériques
    cols_num = df.select_dtypes(include=['number']).columns

    # Supprimer les lignes contenant des valeurs négatives
    df = df[(df[cols_num] >= 0).all(axis=1)]

    # Récupérer la dernière date
    derniere_date = df['DATE'].iloc[-1]

    # Convertir en jour julien (DOY)
    jour_julien = derniere_date.dayofyear

    # Calcul de l'evapotranspiration et ajout à la colonne
    ETo=CalculEvapotranspirationJournaliereAll(df['T'], df['RH'], df['u2'], df['Rs'])
    df = df.copy()
    df["ETo"] = ETo


    # Visualisons les variables:
    variables = ["T","RH","u2","Rs"]      

    
    for k in range(len(variables)):
        df.fillna(value={variables[k]:df[variables[k]].median()}, inplace=True)

    # valeur < Q1 - 1,5*IQR ou valeur > Q3 + 1,5*IQR
    # La fonction nous permet de trouver des lignes avec des donnees aberantes

    def finding_outliers(data, variable_name) -> pd.DataFrame:
        iqr = data[variable_name].quantile(0.75) - data[variable_name].quantile(0.25)
        lower = data[variable_name].quantile(0.25) - 1.5*iqr
        upper = data[variable_name].quantile(0.75) + 1.5*iqr
        return data[(data[variable_name] < lower) | (data[variable_name] > upper)]

    for k in range(len(variables)):
        iqr_fare = df[variables[k]].quantile(0.75) - df[variables[k]].quantile(0.25)
        df.loc[finding_outliers(df, variables[k]).index, variables[k]] = df[variables[k]].quantile(0.75) + 1.5*iqr_fare

    # Variables à tracer
    variables = ["T", "RH", "u2", "Rs"]

    
    def predEvapotranspiration(Tcroissance):
        

        df_filtre = df[df["DATE"] >= date_debut]
        ET_all=np.zeros(Tcroissance)

        n_hist=min(len(df_filtre),Tcroissance)

        ET_all[:n_hist]=df_filtre["ETo"].values[:n_hist]
        y_all = np.zeros((len(variables), Tcroissance))

        # Sélection des colonnes nécessaires
        for k in range(len(variables)):

            df_data= df.copy()

            # Garder uniquement Date et T2M
            df_data = df_data[["DATE", variables[k]]]
            df_data.head()
            df_data["DATE"].min(), df_data["DATE"].max()

            # Prédiction de chaque variable en fonction de la date. Nous faisons également l’extrapolation pour le reste de l’année en cours.
            # En première étape, nous diviserons les données et la cible à estimer. Les données étant une date, nous la convertirons en chiffre.
            long_term_trend_kernel = 50.0**2 * RBF(length_scale=50.0)

            # Utilisation d'un noyau périodique
            seasonal_kernel = (2.0**2* RBF(length_scale=100.0)* ExpSineSquared(length_scale=1.0, periodicity=1.0, periodicity_bounds="fixed"))

            # Irregularités par un noyau quadratique rationnel
            irregularities_kernel = 0.5**2 * RationalQuadratic(length_scale=1.0, alpha=1.0)

            # Ajout d'un bruit blanc
            noise_kernel = 0.1**2 * RBF(length_scale=0.1) + WhiteKernel( noise_level=0.1**2, noise_level_bounds=(1e-5, 1e5))

            # Pour le noyau final, faisons une addition de tous les noyaux locaux
            df_kernel = (long_term_trend_kernel + seasonal_kernel + irregularities_kernel + noise_kernel)
            X = ( df_data["DATE"].dt.year + (df_data["DATE"].dt.dayofyear - 1) / 365.25).to_numpy().reshape(-1, 1)
            y = df_data[variables[k]].to_numpy()

            # Ajustement du modèle et extrapolation
            # Utilisons un régresseur de processus gaussen et ajustons les données disponibles Data.
            y_mean = y.mean()
            gaussian_process = GaussianProcessRegressor(kernel=df_kernel,normalize_y=True, n_restarts_optimizer=0)
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
            gp =GaussianProcessRegressor(kernel=df_kernel,normalize_y=True, n_restarts_optimizer=0)
            gp.fit(X_train, y_train - y_mean)

            # Prédiction test
            y_test_pred = gp.predict(X_test) + y_mean

            # R² test
            r2_test = r2_score(y_test, y_test_pred)
            print(f"R² test = {r2_test:.4f}")

            # Fin de l'année actuelle
            # Dernière date connue
            last_date = df_data["DATE"].max()
            end_date = pd.Timestamp("2026-12-31")

            # Dates futures
            future_dates = pd.date_range(start=last_date + pd.Timedelta(days=1),periods=Tcroissance,freq="D")
            X_future = (future_dates.year + (future_dates.dayofyear - 1) / 365.25).values.reshape(-1,1)
            y_future_pred, y_future_std = gp.predict(X_future,return_std=True)
            y_future_pred += y_mean

        

          
            y_all[k, :] = y_future_pred

        ET_pred=CalculEvapotranspirationJournaliereAll(y_all[0],y_all[1] , y_all[2], y_all[3]) 
        n_pred=min(len(ET_pred),Tcroissance-n_hist)

        ET_all[n_hist:n_hist+n_pred]=ET_pred[:n_pred]

        return ET_all
    

    ET_all= predEvapotranspiration(Tcroissance)
    ET_all=np.nan_to_num(ET_all)
    return ET_all   
