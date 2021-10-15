
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014722008423"
  location = "West Europe"
}

resource "azurerm_iotcentral_application" "test" {
  name                = "acctest-iotcentralapp-211015014722008423"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sub_domain          = "subdomain-211015014722008423"
  display_name        = "some-display-name"
  sku                 = "ST1"
  template            = "iotc-pnp-preview@1.0.0"
  tags = {
    ENV = "Test"
  }
}
