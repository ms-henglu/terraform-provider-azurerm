
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011554325864"
  location = "West Europe"
}

resource "azurerm_iotcentral_application" "test" {
  name                = "acctest-iotcentralapp-220916011554325864"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sub_domain          = "subdomain-220916011554325864"
  sku                 = "ST1"
}
