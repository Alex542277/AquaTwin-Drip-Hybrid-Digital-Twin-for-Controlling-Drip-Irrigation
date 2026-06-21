function[max_iter,tol,t]=valorsForSimulation(Tmax)
    
    [X_all,Y_all,Xp,Yp,n_prim,n_dual,total_dof]=MeshGrid();
    [r_emitter, q_irr,Efficience]=parameterGoutteur();
    dt = Tmax/(total_dof);
    t = 0:dt:Tmax;
    max_iter = 30;
    tol=1e-5;
    

end