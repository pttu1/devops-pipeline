# Create Custom Docker Image
# Pull tomcat latest image from dockerhub 
FROM tomcat:latest

# Maintainer
MAINTAINER "PR Reddy - ohwilly" 

# copy war file on to container 
COPY ./ohwilly.war /usr/local/tomcat/webapps