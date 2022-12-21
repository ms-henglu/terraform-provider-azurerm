
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-search-221221204800390892"
  location = "West Europe"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice221221204800390892"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"

  allowed_ips = ["168.1.5.65", "1.2.3.0/24"]

  tags = {
    environment = "staging"
  }
}
