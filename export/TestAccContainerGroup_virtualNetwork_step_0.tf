
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220819165039269137"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "testvnet"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "testsubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.1.0.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_network_profile" "test" {
  name                = "testnetprofile"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  container_network_interface {
    name = "testcnic"

    ip_configuration {
      name      = "testipconfig"
      subnet_id = azurerm_subnet.test.id
    }
  }
}

resource "azurerm_container_group" "test" {
  name                = "acctestcontainergroup-220819165039269137"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "Private"
  network_profile_id  = azurerm_network_profile.test.id
  os_type             = "Linux"

  container {
    name   = "hw"
    image  = "ubuntu:20.04"
    cpu    = "0.5"
    memory = "0.5"
    ports {
      port = 80
    }
  }
  dns_config {
    nameservers    = ["reddog.microsoft.com", "somecompany.somedomain"]
    options        = ["one:option", "two:option", "red:option", "blue:option"]
    search_domains = ["default.svc.cluster.local."]
  }

  tags = {
    environment = "Testing"
  }
}
