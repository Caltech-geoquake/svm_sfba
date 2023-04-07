data {

  int N; //number of points
  int NVEL; //number of velocity profiles
  
  //z^star parameter
  real z_star;
  
  //velocity array indices 
  int<lower=1,upper=NVEL> i_vel[N];
  
  //input arrays
  vector[NVEL] Vs30;  
  //observations
  vector[N] Z; //Depth array 
  vector[N] Y; //Velocity array

}

transformed data {
  real delta = 1e-9;
}

parameters {
  //model parameters
  //k scaling
  real <lower=0.0>r1;
  real <lower=0.0>r2;
  real r3;
  real r4;
  //real <lower=-10,upper=-5>r3;
  //real <lower=-5,upper=-3>r4;
  //s scaling
  real<lower=0.0> s1;
  real<lower=0.0> s2;
  real<lower=0.0> s3;
 
  //aleatory variability
  real<lower=0.0> sigma_vel;
  //between event std
  real<lower=0.0> tau_r;

  //between event term
  vector[NVEL] r_dB;
}

transformed parameters {
  //velocity model parameters
  vector<lower=0.0>[NVEL] n_p;
  vector[NVEL] a_p;
  vector[NVEL] k_p;
  vector<lower=0.0>[NVEL] Vs0_p;

  //model parameters
 
 // k_p   = exp(r1 * inv_logit((log(Vs30)-r2)*r3) + r4);
  k_p   = exp((r1/(1+(r2*0.001*Vs30)^r3))+r4);      
  n_p   = 1. + s3 * inv_logit( (log(Vs30)-s1) * s2 );
  a_p   =-1. ./ n_p;
  for(i in 1:NVEL){
      // Vs0 = (k_p*(a_p+1.)*z_star + (1.+k_p*(30.-z_star))^(a_p+1.) - 1.) / (30.*(a_p+1.)*k_p) * Vs30;
      Vs0_p[i] = (k_p[i]*(a_p[i]+1.)*z_star + (1.+k_p[i]*(30.-z_star))^(a_p[i]+1.) - 1.) / (30.*(a_p[i]+1.)*k_p[i]) * Vs30[i];
  }

}

model {
  //velocity model
  vector[N] VEL_M;

  //prior distributions
  //---   ---   ---   ---   ---   ---
  //model coefficients
  r1 ~ lognormal(1.25,0.05);
  r2 ~ lognormal(0.95,0.05);
  r3 ~ normal(-8.9,2);
  r4 ~ normal(-3.1,0.2);
  s1 ~ lognormal(1.25,0.50);
  s2 ~ lognormal(1.25,0.50);
  s3 ~ lognormal(0.65,0.40);
  
  //aleatory variability
  sigma_vel ~ lognormal(-0.3,0.6);
  
 
  //functional model
  //---   ---   ---   ---   ---   ---
  //evaluate velocity model
  for(i in 1:N){
    int i_v = i_vel[i];
    VEL_M[i] =  log(Vs0_p[i_v]) + log( (1. + k_p[i_v] * max([0., Z[i]-z_star]) )^(1./n_p[i_v]) );
  }
   
  //likelihood function
  //---   ---   ---   ---   ---   ---
  //model likelihood
  Y ~ normal(VEL_M,sigma_vel);
}
