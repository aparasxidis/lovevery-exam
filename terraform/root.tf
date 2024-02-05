module "k8s" {
  source = "./modules/k8s"

  ns        = "lovevery"
  app_name  = "helloworld-ror"
  registry  = "aparasxidis/lovevery"
  image_tag = "latest"
}