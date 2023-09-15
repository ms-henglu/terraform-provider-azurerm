

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lslp-230915023617029758"
  location = "West Europe"
}


resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-230915023617029758"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-sn-230915023617029758"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "Microsoft.LabServices.labplans"

    service_delegation {
      name = "Microsoft.LabServices/labplans"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "test2" {
  name                 = "acctest-sn2-230915023617029758"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.3.0/24"]

  delegation {
    name = "Microsoft.LabServices.labplans"

    service_delegation {
      name = "Microsoft.LabServices/labplans"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_lab_service_plan" "test" {
  name                      = "acctest-lslp-230915023617029758"
  resource_group_name       = azurerm_resource_group.test.name
  location                  = azurerm_resource_group.test.location
  allowed_regions           = [azurerm_resource_group.test.location, "West US 2"]
  default_network_subnet_id = azurerm_subnet.test2.id

  default_auto_shutdown {
    disconnect_delay = "PT16M"
    idle_delay       = "PT16M"
    no_connect_delay = "PT16M"
    shutdown_on_idle = "UserAbsence"
  }

  default_connection {
    client_rdp_access = "Public"
    web_rdp_access    = "Public"
  }

  support {
    email        = "company2@terraform.io"
    instructions = "Contacting support for help"
    phone        = "+1-555-555-6666"
    url          = "https://www.terraform2.io/"
  }

  tags = {
    Env = "Test2"
  }
}
