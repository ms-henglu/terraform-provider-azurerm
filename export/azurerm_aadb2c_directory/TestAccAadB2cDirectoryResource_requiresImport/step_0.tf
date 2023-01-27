

provider "azurerm" {
  client_id               = ""
  client_certificate_path = ""
  client_secret           = ""
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230127044909415594"
  location = "West Europe"
}


resource "azurerm_aadb2c_directory" "test" {
  country_code            = "US"
  data_residency_location = "United States"
  display_name            = "acctest230127044909415594"
  domain_name             = "acctest230127044909415594.onmicrosoft.com"
  resource_group_name     = azurerm_resource_group.test.name
  sku_name                = "PremiumP1"
}
