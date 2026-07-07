#!/usr/bin/env python
# coding: utf-8

def EvapotranspirationCulture(lat, lon, date_debut, Tcroissance):
    """
    Calcule l'évapotranspiration de référence pour une culture
    """
    
    Tcroissance = int(Tcroissance)
    import matplotlib
    matplotlib.use("Agg")

    import matplotlib.pyplot as plt
    plt.ioff()

    import pandas as pd
    import numpy as np
    from datetime import datetime, timedelta
    import requests

    from sklearn.ensemble import RandomForestRegressor
    from sklearn.model_selection import train_test_split
    from sklearn.metrics import r2_score
    import warnings
    warnings.filterwarnings('ignore')

    def PenmanMontheithParameter(T, RH, u2, Rs):
        ew = 0.6108 * np.exp((17.27 * T) / (T + 237.3))
        e = RH * ew / 100
        VPD = ew - e
        Delta = (4098 * ew) / ((T + 237.3) ** 2)
        P = 101.3
        Gamma = 0.000665 * P
        alpha = 0.23
        Rn = (1 - alpha) * Rs
        G = np.zeros_like(Rn)
        jour = Rs > 0
        G[jour] = 0.1 * Rn[jour]
        G[~jour] = 0.5 * Rn[~jour]
        return Delta, Gamma, Rn, G, T, VPD, u2

    def CalculEvapotranspirationJournaliereAll(T, RH, u2, Rs):
        Delta, Gamma, Rn, G, T, VPD, u2 = PenmanMontheithParameter(T, RH, u2, Rs)
        numerateur = (0.408 * Delta * (Rn - G) + Gamma * (900 / (T + 273)) * u2 * VPD)
        denominateur = Delta + Gamma * (1 + 0.34 * u2)
        ETo = numerateur / denominateur
        ETo = np.maximum(ETo, 0)
        return ETo

    # RÉCUPÉRATION DES DONNÉES NASA POWER
    
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

    cols_num = df.select_dtypes(include=['number']).columns
    df = df[(df[cols_num] >= 0).all(axis=1)]

    ETo = CalculEvapotranspirationJournaliereAll(df['T'], df['RH'], df['u2'], df['Rs'])
    df["ETo"] = ETo

    # TRAITEMENT DES DONNÉES
    
    variables = ["T", "RH", "u2", "Rs"]

    for k in range(len(variables)):
        df.fillna(value={variables[k]: df[variables[k]].median()}, inplace=True)

    def finding_outliers(data, variable_name) -> pd.DataFrame:
        iqr = data[variable_name].quantile(0.75) - data[variable_name].quantile(0.25)
        lower = data[variable_name].quantile(0.25) - 1.5 * iqr
        upper = data[variable_name].quantile(0.75) + 1.5 * iqr
        return data[(data[variable_name] < lower) | (data[variable_name] > upper)]

    for k in range(len(variables)):
        iqr_fare = df[variables[k]].quantile(0.75) - df[variables[k]].quantile(0.25)
        df.loc[finding_outliers(df, variables[k]).index, variables[k]] = df[variables[k]].quantile(0.75) + 1.5 * iqr_fare

    # PRÉDICTION AVEC RANDOM FOREST

    def predEvapotranspiration(Tcroissance):

        if isinstance(date_debut, str):
            date_debut_dt = pd.to_datetime(date_debut)
        else:
            date_debut_dt = date_debut

        df_filtre = df[df["DATE"] >= date_debut_dt]
        ET_all = np.zeros(Tcroissance)

        n_hist = min(len(df_filtre), Tcroissance)
        ET_all[:n_hist] = df_filtre["ETo"].values[:n_hist]

        y_all = np.zeros((len(variables), Tcroissance))

        for k in range(len(variables)):

            df_data = df[["DATE", variables[k]]].copy()

            X = (df_data["DATE"].dt.year + (df_data["DATE"].dt.dayofyear - 1) / 365.25).to_numpy().reshape(-1, 1)
            y = df_data[variables[k]].to_numpy()

            X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

            rf = RandomForestRegressor(
                n_estimators=100,
                max_depth=10,
                min_samples_split=5,
                min_samples_leaf=2,
                random_state=42
            )

            rf.fit(X_train, y_train)
            y_pred = rf.predict(X_test)
            r2 = r2_score(y_test, y_pred)
            print(f"R² (RF) pour {variables[k]} = {r2:.4f}")

            last_date = df_data["DATE"].max()
            future_dates = pd.date_range(
                start=last_date + pd.Timedelta(days=1),
                periods=Tcroissance,
                freq="D"
            )
            X_future = (future_dates.year + (future_dates.dayofyear - 1) / 365.25).values.reshape(-1, 1)
            y_future_pred = rf.predict(X_future)
            y_all[k, :] = y_future_pred

        ET_pred = CalculEvapotranspirationJournaliereAll(
            y_all[0], y_all[1], y_all[2], y_all[3]
        )

        n_pred = min(len(ET_pred), Tcroissance - n_hist)
        ET_all[n_hist:n_hist + n_pred] = ET_pred[:n_pred]

        return ET_all

    ET_all = predEvapotranspiration(Tcroissance)
    ET_all = np.nan_to_num(ET_all)
    return ET_all.tolist()


if __name__ == "__main__":
    import numpy as np
    resultat = EvapotranspirationCulture(7.4, 2.09, '2026-04-01', 100)
    print(f"\n✅ Résultat : {len(resultat)} jours d'ET prédite")
    print(f"📊 ET moyenne : {np.mean(resultat):.2f} mm/jour")