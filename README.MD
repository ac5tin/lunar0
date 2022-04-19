# Lunar
Lunar infra


## Get started
```sh
# init
terraform init
# plan
terraform plan
# apply
terraform apply
# teardown
terraform destroy
```

## Import Route53 zone (if exist already)
```sh
terraform import module.k8s.aws_route53_zone.downme Z2AB1CDEFGHIJKL
```

## Kubernetes
To Get kubeconfig
```sh
terraform output
```