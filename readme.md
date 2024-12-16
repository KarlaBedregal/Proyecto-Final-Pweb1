docker build -t iwproyecto .


docker run -d -p 8085:80 -p 3307:3306 --name cproyecto iwproyecto


docker stop cproyecto
docker rm cproyecto
docker rmi iwproyecto

