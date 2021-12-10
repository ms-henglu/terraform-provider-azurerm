
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210024700213802"
  location = "West Europe"
}

resource "azurerm_iotcentral_application" "test" {
  name                = "acctest-iotcentralapp-211210024700213802"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sub_domain          = "subdomain-211210024700213802"
  display_name        = "some-display-name"
  sku                 = "ST1"
  tags = {
    ENV = "Test"
  }
}
