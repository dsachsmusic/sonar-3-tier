## Create the docker containers...
Run the following from within the folder where the services' docker file is defined
`docker build -t dsachsmusic/order-a-greeting-orders .`
`docker build -t dsachsmusic/order-a-greeting-inventory .`
`docker push dsachsmusic/order-a-greeting-orders:latest`
`docker push dsachsmusic/order-a-greeting-inventory:latest`

# Push the containers to Docker hub