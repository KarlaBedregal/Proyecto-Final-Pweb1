docker build -t iproyecto .


docker run -d -p 8092:80 -p 3307:3306 --name cproyecto iproyecto


docker stop cproyecto
docker rm cproyecto
docker rmi iwproyecto

