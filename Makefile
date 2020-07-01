include set_env.mk

## help                                        : Show this help message
.PHONY : help
help : Makefile
	@echo ""
	@echo " Welcome to the fungicidal_bact_genomics repository!"
	@echo ""
	@echo " make..."
	@sed -n 's/^##//p' $<
	@echo ""

## build-image                                 : Build the docker image for notebooks
build-image: Dockerfile
	docker build -t fungicidal_bact_genomics . \
	&& touch $@

## build-graphlan                              : Build the docker image for graphlan
build-graphlan: Dockerfile.graphlan
	docker build -t graphlan_cntnr -f Dockerfile.graphlan . \
	&& touch $@

## run-notebook                                : Run the notebook server
.PHONY: run-notebook
run-notebook: build-image stop-notebook
	DATA_DIR=$(DATA_DIR) IMG_DIR=$(IMG_DIR) ./scripts/jupyter-lab.sh

## stop-notebook                               : Stop the notebook server
.PHONY: stop-notebook
stop-notebook:
	docker stop fungicidal_bact_genomics_$(HOSTNAME)_$(UID) || echo "already stopped"
	sleep 1

## get-url                                     : Get the URL of the notebook server
.PHONY: get-url
get-url:
	@docker exec --user jovyan -it fungicidal_bact_genomics_$(HOSTNAME)_$(UID) jupyter notebook list \
	| sed -E "s/(0.0.0.0|localhost)/$(HOSTNAME)/"

#------------------------------------------------------
#
#                   ANALYSIS
#
#------------------------------------------------------

## data/category_covariance.png                : Produce the metadata covariance figure   
images/category_covariance.png: data/isolates.tsv \
                                notebooks/summaries_and_table1.ipynb
	./scripts/docker-run.sh DATA_DIR="${DATA_DIR}" IMG_DIR="${IMG_DIR}" \
        papermill notebooks/summaries_and_table1.ipynb \
        notebooks/results/run0_summaries_and_table1.ipynb

## data/table2.tsv                             : Produce Table 2 and related feature selection analyses
data/table2.tsv \
data/supplemental_table_bs_bgcs.tsv \
images/sa_features_cooccurence.png \
images/bs_features_cooccurence.png \
data/bgc_presence_absence.tsv: data/isolates.tsv \
                               data/bgc_clustering_results.tsv \
                               notebooks/table2_bgc_feature_selection.ipynb
	./scripts/docker-run.sh DATA_DIR="${DATA_DIR}" IMG_DIR="${IMG_DIR}" \
        papermill notebooks/table2_bgc_feature_selection.ipynb \
        notebooks/results/run0_table2_bgc_feature_selection.ipynb

## images/model_cv.png                         : Perform cross-validation analysis to compare modeling approaches
images/model_cv.png \
images/tax_correlation.png \
images/tax_exclusion.png: data/isolates.tsv \
                               data/bgc_presence_absence.tsv \
                               notebooks/model_cross_validation.ipynb
	./scripts/docker-run.sh DATA_DIR="${DATA_DIR}" IMG_DIR="${IMG_DIR}" \
        papermill notebooks/model_cross_validation.ipynb \
        notebooks/results/run0_model_cross_validation.ipynb


## data/sa_rf_model_pickle                     : Train the machine learning models
img/supplemental_oversampling_effect_on_model_performance.png \
data/sa_rf_model_pickle \
data/sa_nn_model_pickle \
data/bs_rf_model_pickle \
data/bs_nn_model_pickle: data/isolates.tsv \
                         data/bgc_presence_absence.tsv \
                         data/prioritization_exp_features.tsv \
                         notebooks/prioritization_exp_model_training.ipynb
	./scripts/docker-run.sh DATA_DIR="${DATA_DIR}" IMG_DIR="${IMG_DIR}" \
        papermill notebooks/prioritization_exp_model_training.ipynb \
        notebooks/results/run0_prioritization_exp_model_training.ipynb

## data/collection_query_pa.tsv                : Evaluate performance of ML models on validation set
data/validation_strains_ml_predictions.tsv \
data/collection_query_pa.tsv : data/isolates.tsv \
                               data/prioritization_exp_features.tsv \
                               data/collection_query_results.tsv \
                               data/query_taxonomy.tsv \
                               data/sa_rf_model_pickle \
                               data/sa_nn_model_pickle \
                               notebooks/model_performance.ipynb
	./scripts/docker-run.sh DATA_DIR="${DATA_DIR}" IMG_DIR="${IMG_DIR}" \
        papermill notebooks/model_performance.ipynb \
        notebooks/results/run0_model_performance.ipynb
        

data/full_cladogram.txt \
data/full_graphlan.txt \
data/actives_cladogram.txt \
data/actives_graphlan.txt: data/isolates.tsv \
                           data/validation_strains_ml_predictions.tsv \
                           notebooks/figure2_cladogram.ipynb
	./scripts/docker-run.sh DATA_DIR="${DATA_DIR}" \
        papermill notebooks/figure2_cladogram.ipynb \
        notebooks/results/run0_figure2_cladogram.ipynb

images/full_cladogram.png: build-graphlan \
						   build-image \
						   data/full_cladogram.txt \
						   data/full_graphlan.txt
	./scripts/drun_graphlan.sh graphlan_annotate.py \
		--annot data/full_graphlan.txt \
		data/full_cladogram.txt \
		data/full_cladogram.xml && \
	./scripts/drun_graphlan.sh graphlan.py \
		data/full_cladogram.xml \
		images/full_cladogram.png \
		--dpi 400 --size 3.5

images/actives_cladogram.png: build-graphlan \
						      build-image \
						      data/actives_cladogram.txt \
						      data/actives_graphlan.txt
	./scripts/drun_graphlan.sh graphlan_annotate.py \
		--annot data/actives_graphlan.txt \
		data/actives_cladogram.txt \
		data/actives_cladogram.xml && \
	./scripts/drun_graphlan.sh graphlan.py \
		data/actives_cladogram.xml \
		images/actives_cladogram.png \
		--dpi 400 --size 3.5

## generate-cladograms                         : Produce the cladogram from the ms        
generate-cladograms: images/actives_cladogram.png images/full_cladogram.png

## clean                                       : delete all images and derivations, keeping only original data files
clean: 
	rm -f images/* && \
    rm -f !("data/isolates.tsv"|"data/bgc_clustering_results.tsv"|"data/collection_query_results.tsv"|"data/prioritization_exp_features.tsv"|"data/query_taxonomy.tsv") && \
    rm -f notebooks/results/run0_*

## all                                         : reproduce all figures and analyses
all: images/category_covariance.png \
     data/table2.tsv \
     images/model_cv.png \
     data/sa_rf_model_pickle \
     data/collection_query_pa.tsv \
     generate-cladograms