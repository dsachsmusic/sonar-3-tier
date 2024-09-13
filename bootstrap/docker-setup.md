## Create the docker containers...
Run the following from within the folder where the services' docker file is defined
`docker build -t dsachsmusic/order-a-greeting-orders c:\users\david\working\sonar-3-tier\services\orders`
`docker build -t dsachsmusic/order-a-greeting-inventory c:\users\david\working\sonar-3-tier\services\inventory`
`docker push dsachsmusic/order-a-greeting-orders:latest`
`docker push dsachsmusic/order-a-greeting-inventory:latest`

# Push the containers to Docker hub