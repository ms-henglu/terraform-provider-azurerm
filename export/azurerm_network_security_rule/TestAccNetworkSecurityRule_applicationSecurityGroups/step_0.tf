
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034430999528"
  location = "West Europe"
}

resource "azurerm_application_security_group" "source1" {
  name                = "acctest-source1-231016034430999528"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_application_security_group" "source2" {
  name                = "acctest-source2-231016034430999528"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_application_security_group" "destination1" {
  name                = "acctest-destination1-231016034430999528"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_application_security_group" "destination2" {
  name                = "acctest-destination2-231016034430999528"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_security_group" "test" {
  name                = "acctestnsg-231016034430999528"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_security_rule" "test1" {
  name                                       = "test123"
  resource_group_name                        = azurerm_resource_group.test.name
  network_security_group_name                = azurerm_network_security_group.test.name
  priority                                   = 100
  direction                                  = "Outbound"
  access                                     = "Allow"
  protocol                                   = "Tcp"
  source_application_security_group_ids      = [azurerm_application_security_group.source1.id, azurerm_application_security_group.source2.id]
  destination_application_security_group_ids = [azurerm_application_security_group.destination1.id, azurerm_application_security_group.destination2.id]
  source_port_ranges                         = ["10000-40000"]
  destination_port_ranges                    = ["80", "443", "8080", "8190"]
}
