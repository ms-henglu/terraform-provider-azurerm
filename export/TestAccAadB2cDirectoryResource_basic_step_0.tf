

provider "azurerm" {
  client_id               = ""
  client_certificate_path = ""
  client_secret           = ""
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220811052807871207"
  location = "West Europe"
}


resource "azurerm_aadb2c_directory" "test" {
  country_code            = "US"
  data_residency_location = "United States"
  display_name            = "acctest220811052807871207"
  domain_name             = "acctest220811052807871207.onmicrosoft.com"
  resource_group_name     = azurerm_resource_group.test.name
  sku_name                = "PremiumP1"
}
