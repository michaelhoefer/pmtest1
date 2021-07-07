heroku pipelines:destroy pmtest1-pipeline
#heroku apps:destroy -a pmtest1-dev -c pmtest1-dev
heroku apps:destroy -a pmtest1-staging -c pmtest1-staging
heroku apps:destroy -a pmtest1-prod -c pmtest1-prod
rm -- "destroypmtest1-pipeline.sh"
