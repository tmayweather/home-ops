terraform {
    cloud {
      hostname = "app.terraform.io"
      organization = "lowkey"

      workspaces {
        name = "home-cloudflare"
      }
    }
    required_providers {
      cloudflare = {
        source = "cloudflare/cloudflare"
        version = "4.16.0"
      }
      http = {
        source = "hashicorp/http"
        version = "3.4.0"
      }
      onepassword = {
        version = "1.2.1"
        source  = "1password/onepassword"
}

    }
    required_version = ">= 1.3.0"

    }


module "onepassword_item" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Kubernetes"
  item   = "cloudflare"
}

data "cloudflare_zone" "domain" {
  name = "mambalab.live"
}