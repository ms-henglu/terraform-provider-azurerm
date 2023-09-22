
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053516785983"
  location = "West US 2"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230922053516785983"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"

  security {
    enable_frontend_tls10      = true
    triple_des_ciphers_enabled = true
  }
}
