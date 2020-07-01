### Genomics-accelerated discovery of diverse fungicidal bacteria

To reproduce figures and results, run the following command:
```
make all
```

|                | Figure        | Legend |
| -------------  |:-------------:|  -----:|
| Full Cladogram | <img src="images/full_cladogram.png" width="300"> | <img src="images/cladogram_legend_actives.png" width="120">  |
| Only Actives   | <img src="images/actives_cladogram.png" width="300"> | <img src="images/cladogram_legend_actives.png" width="120"> |
| Metadata Co-Variance | <img src="images/category_covariance.png" width="300"> |   |
| BGC Co-Occurrence | <img src="images/sa_features_cooccurence.png" width="300"> |   |
| ML Crossvalidation  | <img src="images/model_cv.png" width="300"> |   |
| Effect of Oversampling on RF | <img src="images/supplemental_oversampling_effect_on_model_performance.png" width="300"> |   |
| ML Performance and Taxonomic Signal | <img src="images/tax_correlation.png" width="300"> |   |
| Excluding taxa from training set | <img src="images/tax_exclusion.png" width="300"> |   |
| Model performance in validation experiment | <img src="images/performance_validation.png" width="300"> |   |

The code and data in this notebook fit together like this:
<img src="images/nbflow.png" width="700">