
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appserviceplan-211217034905513073"
  location = "West Europe"
}

resource "azurerm_resource_group" "test2" {
  name     = "acctestRG2-ase-211217034905513073"
  location = "West Europe"
}


resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-211217034905513073"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-subnet-211217034905513073"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.2.0/24"
  delegation {
    name = "asedelegation"
    service_delegation {
      name    = "Microsoft.Web/hostingEnvironments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_app_service_environment_v3" "test" {
  name                = "acctest-ase-211217034905513073"
  resource_group_name = azurerm_resource_group.test.name
  subnet_id           = azurerm_subnet.test.id
}

resource "azurerm_service_plan" "test" {
  name                = "acctest-SP-211217034905513073"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Windows"
  sku_name            = "I1v2"

  app_service_environment_id = azurerm_app_service_environment_v3.test.id

  tags = {
    environment = "AccTest"
    Foo         = "bar"
  }
}
