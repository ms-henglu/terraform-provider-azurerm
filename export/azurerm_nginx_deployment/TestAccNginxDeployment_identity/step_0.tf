



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-230630033706679095"
  location = "West Europe"
}


resource "azurerm_public_ip" "test" {
  name                = "acctest230630033706679095"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet230630033706679095"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "subbet230630033706679095"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
  delegation {
    name = "delegation"

    service_delegation {
      name = "NGINX.NGINXPLUS/nginxDeployments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acct-230630033706679095"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_nginx_deployment" "test" {
  name                = "acctest-230630033706679095"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "standard_Monthly"
  location            = azurerm_resource_group.test.location

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  frontend_public {
    ip_address = [azurerm_public_ip.test.id]
  }

  network_interface {
    subnet_id = azurerm_subnet.test.id
  }
}
