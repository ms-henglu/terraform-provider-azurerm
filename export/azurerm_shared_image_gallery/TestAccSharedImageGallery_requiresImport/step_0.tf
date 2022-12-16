
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221216013235521198"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig221216013235521198"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
