FROM jupyter/datascience-notebook:610bb8b938db

RUN pip install --ignore-installed pyathena==1.2.2 \
    && pip install --ignore-installed awscli==1.16.128 \
	&& pip install papermill==1.0.1 \
	psycopg2-binary \
	dython==0.3.1 \
	scikit-learn==0.23.1 \
	torch==1.5.0 \
	skorch==0.8.0