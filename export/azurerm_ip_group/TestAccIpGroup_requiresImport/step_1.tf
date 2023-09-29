

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-230929065414903010"
  location = "West Europe"
}

resource "azurerm_ip_group" "test" {
  name                = "acceptanceTestIpGroup1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_ip_group" "import" {
  name                = azurerm_ip_group.test.name
  location            = azurerm_ip_group.test.location
  resource_group_name = azurerm_ip_group.test.resource_group_name
}
