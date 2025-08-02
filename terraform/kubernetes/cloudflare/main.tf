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
        version = "5.8.2"
      }
      http = {
        source = "hashicorp/http"
        version = "3.5.0"
      }
      onepassword = {
        source = "1password/onepassword"
	version = "2.1.2"
    }
    }
    required_version = ">= 1.3.0"

    }
    

module "onepassword_item" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Kubernetes"
  item   = "cloudflare"
}

data "http" "ipv4_lookup_raw" {
  url = "http://ipv4.icanhazip.com"
}

data "cloudflare_zone" "domain" {
  name = "mambalab.live"
}


provider "onepassword" {
  # other provider configuration...

  token = var.OP_CONNECT_TOKEN
}
