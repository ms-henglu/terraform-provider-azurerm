
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220513180348042517"
  location = "West Europe"
}

resource "azurerm_iotcentral_application" "test" {
  name                = "acctest-iotcentralapp-220513180348042517"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sub_domain          = "subdomain-220513180348042517"
  display_name        = "some-display-name"
  sku                 = "ST1"
  template            = "iotc-pnp-preview@1.0.0"
  tags = {
    ENV = "Test"
  }
}
