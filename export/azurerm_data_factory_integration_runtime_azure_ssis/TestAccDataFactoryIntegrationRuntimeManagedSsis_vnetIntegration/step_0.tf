
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230915023301694770"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet230915023301694770"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet230915023301694770"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  virtual_network_name = "${azurerm_virtual_network.test.name}"
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfirm230915023301694770"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_data_factory_integration_runtime_azure_ssis" "test" {
  name            = "acctestiras230915023301694770"
  description     = "acctest"
  data_factory_id = azurerm_data_factory.test.id
  location        = azurerm_resource_group.test.location

  node_size = "Standard_D8_v3"

  vnet_integration {
    subnet_id = "${azurerm_subnet.test.id}"
  }
}
