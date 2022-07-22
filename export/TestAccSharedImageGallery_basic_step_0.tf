
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220722035002626182"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220722035002626182"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
