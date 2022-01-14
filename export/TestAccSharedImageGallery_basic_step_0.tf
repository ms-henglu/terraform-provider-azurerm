
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114014015953749"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220114014015953749"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
