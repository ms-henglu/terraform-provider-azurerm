
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013043954304475"
  location = "West Europe"
}

resource "azurerm_application_security_group" "first" {
  name                = "acctest-first231013043954304475"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_application_security_group" "second" {
  name                = "acctest-second231013043954304475"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_security_group" "test" {
  name                = "acctestnsg-231013043954304475"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  security_rule {
    name                                       = "test123"
    priority                                   = 100
    direction                                  = "Inbound"
    access                                     = "Allow"
    protocol                                   = "Tcp"
    source_application_security_group_ids      = [azurerm_application_security_group.first.id]
    destination_application_security_group_ids = [azurerm_application_security_group.second.id]
    source_port_ranges                         = ["10000-40000"]
    destination_port_ranges                    = ["80", "443", "8080", "8190"]
  }
}
