docker build -t iwproyecto .


docker run -d -p 8080:80 -p 3307:3306 --name cproyecto iwproyecto


docker stop cproyecto
docker rm cproyecto
docker rmi iproyecto

