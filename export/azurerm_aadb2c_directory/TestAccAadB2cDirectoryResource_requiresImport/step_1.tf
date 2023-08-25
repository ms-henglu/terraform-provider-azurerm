


provider "azurerm" {
  client_id               = ""
  client_certificate_path = ""
  client_secret           = ""
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825023927024714"
  location = "West Europe"
}


resource "azurerm_aadb2c_directory" "test" {
  country_code            = "US"
  data_residency_location = "United States"
  display_name            = "acctest230825023927024714"
  domain_name             = "acctest230825023927024714.onmicrosoft.com"
  resource_group_name     = azurerm_resource_group.test.name
  sku_name                = "PremiumP1"
}


resource "azurerm_aadb2c_directory" "import" {
  country_code            = azurerm_aadb2c_directory.test.country_code
  data_residency_location = azurerm_aadb2c_directory.test.data_residency_location
  display_name            = azurerm_aadb2c_directory.test.display_name
  domain_name             = azurerm_aadb2c_directory.test.domain_name
  resource_group_name     = azurerm_aadb2c_directory.test.resource_group_name
  sku_name                = azurerm_aadb2c_directory.test.sku_name
}
