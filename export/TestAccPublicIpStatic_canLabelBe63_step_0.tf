
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220211131004312380"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-220211131004312380"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  allocation_method = "Static"
  domain_name_label = "3dk7fgk9u7uimy1a7199r8e0r2qe4ojik2thgcvqy4dq7lqu9u7kbi13a4p2zsx"
}
