*Vérification des intermediate weights

gen est_menage_zd = nb_mens_enq * corrected_weight_HH
bysort region : egen pop_menage_est = total(est_menage_zd)
gen diff_pop_menage = pop_menage_est - nb_men_reg
sum diff_pop_menage

gen est_menage_zd_pb = nb_men_theo * base_weight_HH	
bysort region : egen pop_menage_est_pb = total(est_menage_zd_pb)
gen diff_pop_menage_pb = pop_menage_est_pb - nb_men_reg
sum diff_pop_menage_pb
