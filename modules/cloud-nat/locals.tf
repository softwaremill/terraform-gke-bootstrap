locals {
  router = var.create_router ? google_compute_router.router[0].name : var.router
}
