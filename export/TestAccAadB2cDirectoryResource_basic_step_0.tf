

provider "azurerm" {
  client_id               = ""
  client_certificate_path = ""
  client_secret           = ""
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610022144594395"
  location = "West Europe"
}


resource "azurerm_aadb2c_directory" "test" {
  country_code            = "US"
  data_residency_location = "United States"
  display_name            = "acctest220610022144594395"
  domain_name             = "acctest220610022144594395.onmicrosoft.com"
  resource_group_name     = azurerm_resource_group.test.name
  sku_name                = "PremiumP1"
}
