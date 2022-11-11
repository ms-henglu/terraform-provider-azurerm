
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013655271104"
  location = "West Europe"
}

resource "azurerm_iotcentral_application" "test" {
  name                = "acctest-iotcentralapp-221111013655271104"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sub_domain          = "subdomain2-221111013655271104"
  display_name        = "some-display-name"
  sku                 = "ST0"

  tags = {
    ENV = "Test"
  }
}
