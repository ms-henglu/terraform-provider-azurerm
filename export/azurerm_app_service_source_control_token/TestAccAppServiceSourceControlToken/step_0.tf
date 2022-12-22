
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "4c4tfgeic2iarhurtvo8wmg1vorqvhndawkmk17p9"
  token_secret = "q66fw91d42f6ip0ia23v30keqasl7sgwhdysb2xh4"
}
