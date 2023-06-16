# Welcome to Reactive Checkout

Simple project with an example of service integration https://reactivepay.com/

### Starting project

```
cp .env.example .env
set your REACTIVEPAY_TOKEN in .env

docker compose build
docker compose up
```

### Setup db

```
docker ps
docker exec -it /CONTAINER/ bash
bundle exec rails db:setup
bundle exec rails db:migrate
bundle exec rails db:seed
```

### Sign in as

```
Customer
  email: customer@test.test
  password: customer

Admin
  email: admin@test.test
  password: admin
```


### How to Payments works on https://reactive-y69rn.ondigitalocean.app

```
go to https://reactive-y69rn.ondigitalocean.app/users/sign_in

login as Customer

click Buy

Fill in fields:
  Credit Card Number: 4392963203551251
  CVC: 123
  Expiry Date (mounth): 3
  Expiry Date (year): 2025
  Holder name: Test Test

after transation you will see Payments info
```


### How to Payouts works on https://reactive-y69rn.ondigitalocean.app

```
go to https://reactive-y69rn.ondigitalocean.app/users/sign_in

login as Admin

go to https://reactive-y69rn.ondigitalocean.app/payouts/new

Fill in fields:
  Credit Card Number: 4276111152393643
  Expiry Date (mounth): 3
  Expiry Date (year): 2025

after transation you will see Payouts info
```
