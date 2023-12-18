

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072256431734"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-231218072256431734"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}


resource "azurerm_public_ip" "import" {
  name                = azurerm_public_ip.test.name
  location            = azurerm_public_ip.test.location
  resource_group_name = azurerm_public_ip.test.resource_group_name
  allocation_method   = azurerm_public_ip.test.allocation_method
}
