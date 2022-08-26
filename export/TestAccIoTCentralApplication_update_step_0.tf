
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002830101831"
  location = "West Europe"
}

resource "azurerm_iotcentral_application" "test" {
  name                = "acctest-iotcentralapp-220826002830101831"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sub_domain          = "subdomain-220826002830101831"
  sku                 = "ST1"
}
