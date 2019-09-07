
## From the Docks to the Gate
"From the Docks to the Gate is a story about a simple service that answers only one question, if a given number is prime. The core problem is first solved with a Java class, which is then wrapped into a WebServlet and tested within a web server environment. The web server however does not get directly installed, but a docker image is created, containing all aforementioned components. Eventually, once sufficiently tested, the docker container is pushed into a container registry, from which it is deployed and run. The simple service is finally made public and available to the world, scalable, all without having to manage servers or clusters."

# Prime Service on Tomcat

- build the project using the build task
- create the docker image:
* start docker / docker desktop and login
* in Terminal enter "docker build -t tomcatprime ."
