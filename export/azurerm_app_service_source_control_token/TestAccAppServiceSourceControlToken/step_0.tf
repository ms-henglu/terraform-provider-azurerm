
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "o9qmd4djc7zi7rp3h3xol4jft9tbe9njzrl6txv3a"
  token_secret = "06syq30lqltj89ce8f4b3zconeztviuw98422utdd"
}
