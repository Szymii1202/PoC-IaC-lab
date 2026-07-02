locals {
    project_name = "iaclab"
    location = "westeurope"

    global_tags = {
        owner       = "szymon.dudziak"
        project     = local.project_name
        managed_by  = "Terraform"
        cost_center = "iac-lab"
        lifecycle   = "dev"
        environment = var.environment
    }
}