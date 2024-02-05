# Lovevery Exam
Configuration in this directory creates a multi-stage docker image for a Ruby on Rails Hello World app, pushes it to public repository in Docker Hub, and ilustrate different deployment options:
- Deploy it to a local kubernetes cluster using vanilla manifests
- Deploy it to a local kubernetes cluster using a helm chart
- Deploy it to a local kubernetes cluster using the Terraform kubernetes provider
## Requirements

| Name | Version |
|------|---------|
| Docker Desktop engine | >= 25.0.2 |
| docker client | >= 25.0.2 |
| terraform | >= 1.5.7 |
| kubectl | >= 1.29.1 |
| kubernetes cluster | >= 1.29.1 |
| helm | >= 3.11.3 |

- Public Docker Hub Repository already created
- Local kubernetes cluster

**Note:** The following steps were tested using kubernetes single node cluster provided by docker-desktop in a Windows Subsystem for Linux 

## Usage
### Build docker image and create docker container
```sh
cd hello-world/
docker build --platform=<TARGET-PLATFORM> -t rubyonrailsapp .
docker build --platform=linux/amd64 -t rubyonrailsapp .
or
docker build --platform=linux/arm64 -t rubyonrailsapp .
docker run -p 3000:3000 rubyonrailsapp
```
Navigate to http://localhost:3000/hello_world/index on your browser, and you should see the newly created Rails application with a message of Hello World!

### Push docker image to repository
```sh
docker login # Provide credentials
docker tag rubyonrailsapp:latest <DOCKER-HUB-ID>/<REPOSITORY-NAME>:latest
docker tag rubyonrailsapp:latest aparasxidis/lovevery:latest
docker push <DOCKER-HUB-ID>/<REPOSITORY-NAME>:latest
docker push aparasxidis/lovevery:latest
```

### Deploy it to a local kubernetes cluster using vanilla manifests
**Note:** Switch to your kubernetes cluster of choice, in this case we are going the use the single node kubernetes provided by docker-desktop, your ```~/.kube/config``` should already exist in your local machine with an entry for the context named ```docker-desktop```
```sh
cd kubernetes/
kubectl config set-context docker-desktop
kubectl apply -f namespace.yaml
kubectl apply -f deploy.yaml
kubectl apply -f service.yaml
```
Check status of the pods (There should be 2 pods with Running Status):
```sh
kubectl -n lovevery get pods
```
Expose service
```sh
kubectl -n lovevery port-forward svc/helloworld-ror 9090:8080
```
Navigate to http://localhost:9090/hello_world/index on your browser, and you should see the exposed Rails application with a message of Hello World!

### Tear Down & Clean-Up
Because we are going to show different ways of deploying the a kubernetes cluster, we need to destroy the already created resources with kubectl.
```sh
kubectl -n lovevery delete service helloworld-ror
kubectl -n lovevery delete deploy helloworld-ror
kubectl delete namespace lovevery
```

### Deploy it to a local kubernetes cluster using a helm chart
```sh
cd helm/
helm -n lovevery install helloworld-ror . -f values.yaml --create-namespace
```
Check status of the pods (There should be 2 pods with Running Status):
```sh
kubectl -n lovevery get pods
```
Expose service
```sh
kubectl -n lovevery port-forward svc/helloworld-ror 9090:8080
```
Navigate to http://localhost:9090/hello_world/index on your browser, and you should see the exposed Rails application with a message of Hello World!

### Tear Down & Clean-Up
Because we are going to show different ways of deploying the a kubernetes cluster, we need to destroy the already created resources with helm/kubectl.
```sh
helm -n lovevery uninstall helloworld-ror
kubectl delete namespace lovevery
```
### Deploy it to a local kubernetes cluster using the Terraform kubernetes provider
**Note:** Edit the parameter ```config_context file``` in the file ```terraform/modules/k8s/provider.tf``` to match the context name in your ```~/.kube/config``` file.
```sh
cd terraform/
terraform init
terraform plan
terraform apply
```
Check status of the pods (There should be 2 pods with Running Status):
```sh
kubectl -n lovevery get pods
```
Expose service
```sh
kubectl -n lovevery port-forward svc/helloworld-ror 9090:8080
```
Navigate to http://localhost:9090/hello_world/index on your browser, and you should see the exposed Rails application with a message of Hello World!
### Tear Down & Clean-Up
```sh
terraform destroy
```
## HOW TO manage terraform state file for multiple environments
One of the native ways for handling multiple terraform state files is using Terraform workspaces, this is basically how you can create and isolate each Terraform state file and reuse your module configuration files between different environments that you switch to using the ```terraform workspaces select``` command. Although this is the terraform way for managing terraform state file for multiple environment, another tool/wrapper called Terragrunt can help you create a directory structure that depicts better the segregation between environments, this is done by creating files (terragrunt.hcl) and folders for each environment (e.g.: dev, stage, prod), the following is an example:
```
.
├── live
│   ├── dev
│   │   └── ec2-instance
│   │       └── terragrunt.hcl
│   ├── prod
│   │   └── ec2-instance
│   │       └── terragrunt.hcl
│   └── stage
│       └── ec2-instance
│           └── terragrunt.hcl
└── modules
    └── ec2-instance
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
```
To see what is deployed in each environment, you can browse to the file terragrunt.hcl in the live folder, and to make changes in one of these environments you can run terragrunt commands that are equivalent to terraform commands. Each environment will have its own statefile and you will have a centralized repository/directory where you can actually see all your environment infrastructure instead of using terraform workspace to switch between environments.

## HOW TO manage terraform variables and secrets
For managing variables the most easy way is to have a file, lets call it, ```variables.tf```, where all our variables are defined. Other option is make use of ```.tfvars``` file to have different values for different environments and passing to terraform commands using the ```-var-file``` flag, like so: ```terraform plan -var-file="prod.tfvars"```.
For managing secrets, first of all, a secure remote backend should be used, e.g. AWS S3, this is where the different Terraform state files will reside, one of the key feature of using a secure remote backend like an S3 bucket is that provides encryption to the sensitive information that is store in the state file.
Secure approaches regarding secrets are the following:
- Encrypting files with AWS KMS: Create a KMS key and use it to encrypt a file, this file will contain your secrets. Commit this file to your VCS, and use a terraform data source called ```aws_kms_secrets``` to fetch the encrypted data and then decrypt it to be referenced in your terraform configuration files.
- Using a secret store AWS Secrets Manager: The idea of using a secret store is that this will be place where you will create/store secrets, the secrets are encrypted by specifying a KMS key, but without the need of the initial encryption required in the previous approach, but similar as the other approach, for the secrets to be used you will need to make use of a data source ```aws_secretsmanager_secret``` and from there reference them in your configuration files.
- Mask sensitive values: Make use of the attribute named ```sensitive = true``` to mask values that you know are sensitive in the variable or output resources.

## HOW TO test this infrastructure
- Linting: Checking for syntax and style errors, using the native ```terraform fmt```, or open source tools, TFLint
- Static code analysis for vulnerabilities: Checking for compliance violations, rules, best practices, using a tool like Terrascan
- Unit and E2E testing: Testing individual or multiple modules that reflect your actual production environment, using a tool like Terratest

All of the above can and must be integrated as jobs/steps in your CI/CD proccess.
