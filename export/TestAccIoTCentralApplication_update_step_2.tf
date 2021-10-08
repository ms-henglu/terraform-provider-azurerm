
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044516415659"
  location = "West Europe"
}

resource "azurerm_iotcentral_application" "test" {
  name                = "acctest-iotcentralapp-211008044516415659"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sub_domain          = "subdomain-211008044516415659"
  display_name        = "some-display-name"
  sku                 = "ST1"
  tags = {
    ENV = "Test"
  }
}
