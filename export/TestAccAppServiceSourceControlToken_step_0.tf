
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "cinrqkkds0awfee3c2klf6hqkoyhhyuo6bjuoqsbc"
  token_secret = "v8ispvlfby9wt2lze9r79ndxf9iy6sl8kvy1heh4g"
}
