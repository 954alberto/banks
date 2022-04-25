# Banks API
## Intro
This API receives a Json list in the payload and it will parse every string on the list. It will do String replacement as shown in the here:

```
"ABN", => "ABN AMRO"
"ING", => "ING Bank"
"RABO", => "Rabobank"
"Triodos", => "Triodos Bank"
"Volksbank", => "de Volksbank"
```

test the endpoint like:

```bash
curl -X POST https://tmnl.crashzone.link/banks -H 'Content-Type: application/json' -d '["Green aBn","Orange ing", "Grande RABO!", "Fantastic Triodos!", "This is Volksbank!"]'
```
the response should be:
```bash
["Green ABN AMRO","Orange ING Bank","Grande Rabobank!","Fantastic Triodos Bank!","This is de Volksbank!"]
```

## Infra

Everything is hosted in AWS.
For this project I have chosen to create an API using Rust and serve it using Lambda + API Gateway. Also I have chosen terraform as the IaC tool. 
There are 2 folders with terraform code, the folder called `terraform-locking` contains the resource to create the dynamodb table for terraform state locking. The folder called `terraform` contains the resources that have been deployed for the demo.
I have not created a cicd pipeline to build and push the docker image for the rust lambda, because it is a simple thing to manage it by hand for this demo.
AWS lambda for rust works only using docker images as a way to ship the rust binary.

## Building the binary

The best way to build to build a rust binary without having a development enviroment is using docker:

```bash
docker run --rm --user "0":"0" -v "$PWD":/usr/src/myapp -w /usr/src/myapp rust:1.60 cargo build --release
```
This slower than compiling directly on your laptop but it is easier.

## Building the docker image

Copy the new binary to the docker folder, just next to the Dockerfile.

```bash
cp target/release/bootstrap docker
```

Authenticate to AWS ECR:

```bash
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 763886000561.dkr.ecr.eu-west-1.amazonaws.com
```

And finally build and push:

```bash
docker build . -t 763886000561.dkr.ecr.eu-west-1.amazonaws.com/banks:<version_tag> && docker push 763886000561.dkr.ecr.eu-west-1.amazonaws.com/banks:<version_tag>
```

## Building the infrastructure and deploying
From the folder named `terraform` run `terraform init` and `terraform plan` and if everything looks good, `terraform apply`.
