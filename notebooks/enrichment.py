import numpy as np
import pandas as pd
from scipy.stats import hypergeom
from statsmodels.stats.multitest import multipletests

def calc_enrichment_score(n, o, M, N):
    # M = number of strains screened
    # n = number of screened strains with attribute
    # N = number of active strains
    # o = number of active strains with attribute
    rv = hypergeom(M, n, N)
    p_val = rv.sf(o-1)
    return p_val

def calc_enrichment_scores(total_strains, num_actives, all_cols_df, active_cols_df):
    enrichment_dict = {'fam_cluster_id':[],
                       'active_enrich':[],
                       'num_actives_with_bgc':[],
                       'num_strains_with_bgc':[],
                       'act_obs_exp_ratio':[]}
    [M, n] = [total_strains, num_actives]                          # Total number of strains, total number of actives

    for fcid in all_cols_df.index:
        N = sum(all_cols_df.loc[fcid,:])                           # total number of strains that contain this BGC
        if N > 0:
            num_actives_with_bgc = sum(active_cols_df.loc[fcid,:]) # number of actives that contain this BGC
            rv = hypergeom(M, n, N)

            active_p_val = rv.sf(num_actives_with_bgc-1)
            act_obs_exp_ratio = num_actives_with_bgc / rv.mean()

            enrichment_dict['fam_cluster_id'].append(fcid)
            enrichment_dict['active_enrich'].append(active_p_val)
            enrichment_dict['num_actives_with_bgc'].append(num_actives_with_bgc)
            enrichment_dict['num_strains_with_bgc'].append(N)
            enrichment_dict['act_obs_exp_ratio'].append(act_obs_exp_ratio)

    enrichment_df = (pd.DataFrame(enrichment_dict)
                        .sort_values(by=['active_enrich'], ascending=True)
                        .set_index('fam_cluster_id')
                       )
    
    mt = multipletests(enrichment_df['active_enrich'], 0.05, 'fdr_bh')
    enrichment_df['fdr_corrected_pval'] = mt[1]

    return enrichment_df