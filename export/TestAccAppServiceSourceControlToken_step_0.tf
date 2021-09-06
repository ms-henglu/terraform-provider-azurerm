
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "gj6e4wvdiqnvvgkri6zhn9s74bdeoit4rcmwkjuz1"
  token_secret = "q2ncl2dk9ojbq0tgm4fb3r4ba6uoqb272bzasy9qq"
}
