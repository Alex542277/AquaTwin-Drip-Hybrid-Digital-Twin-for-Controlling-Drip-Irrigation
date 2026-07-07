#!/usr/bin/env python
# coding: utf-8

def PredictionRendementTest(ETo, Rendement, V_a_predire):

    import numpy as np
    import pandas as pd
    from sklearn.ensemble import RandomForestRegressor
    from sklearn.model_selection import train_test_split
    from sklearn.metrics import r2_score

    # Conversion robuste depuis MATLAB
    ETo = np.array([float(x) for x in ETo], dtype=float).reshape(-1,1)
    Rendement = np.array([float(x) for x in Rendement], dtype=float)
    V_a_predire = np.array([float(x) for x in V_a_predire], dtype=float).reshape(-1,1)
    
    # Création du dataframe
    df = pd.DataFrame({'ETo': ETo.flatten(), 'Rendement': Rendement})
    df.fillna(value={"Rendement": df["Rendement"].median()}, inplace=True)
    
    X = df["ETo"].to_numpy().reshape(-1, 1)
    y = df["Rendement"].to_numpy()
    
    # Division train/test
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    # Entraînement du Random Forest
    rf = RandomForestRegressor(
        n_estimators=100,
        max_depth=10,
        min_samples_split=5,
        min_samples_leaf=2,
        random_state=42
    )
    
    rf.fit(X_train, y_train)
    
    # Évaluation
    y_pred = rf.predict(X_test)
    r2 = r2_score(y_test, y_pred)
    print(f"R² = {r2:.4f}")
    
    # Prédiction
    RendementPredire = rf.predict(V_a_predire)
    
    return RendementPredire


