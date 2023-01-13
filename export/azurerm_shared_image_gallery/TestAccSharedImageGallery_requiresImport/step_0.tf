
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230113180850401350"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230113180850401350"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
