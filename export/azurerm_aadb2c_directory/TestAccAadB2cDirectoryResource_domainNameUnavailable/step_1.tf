


provider "azurerm" {
  client_id               = ""
  client_certificate_path = ""
  client_secret           = ""
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120054152805531"
  location = "West Europe"
}


resource "azurerm_aadb2c_directory" "test" {
  country_code            = "US"
  data_residency_location = "United States"
  display_name            = "acctest230120054152805531"
  domain_name             = "acctest230120054152805531.onmicrosoft.com"
  resource_group_name     = azurerm_resource_group.test.name
  sku_name                = "PremiumP1"
}


resource "azurerm_resource_group" "duplicate" {
  name     = "acctestRG-duplicate-230120054152805531"
  location = "West US 2"
}

resource "azurerm_aadb2c_directory" "duplicate" {
  country_code            = azurerm_aadb2c_directory.test.country_code
  data_residency_location = azurerm_aadb2c_directory.test.data_residency_location
  display_name            = "acctest-duplicate-230120054152805531"
  domain_name             = azurerm_aadb2c_directory.test.domain_name
  resource_group_name     = azurerm_resource_group.duplicate.name
  sku_name                = "PremiumP1"
}
