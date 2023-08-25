

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lslp-230825024735669485"
  location = "West Europe"
}


resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230825024735669485"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

data "azuread_service_principal" "test" {
  application_id = "c7bb12bf-0b39-4f7f-9171-f418ff39b76a"
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_shared_image_gallery.test.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_service_principal.test.object_id
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-230825024735669485"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-sn-230825024735669485"
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

resource "azurerm_lab_service_plan" "test" {
  name                      = "acctest-lslp-230825024735669485"
  resource_group_name       = azurerm_resource_group.test.name
  location                  = azurerm_resource_group.test.location
  allowed_regions           = [azurerm_resource_group.test.location]
  default_network_subnet_id = azurerm_subnet.test.id
  shared_gallery_id         = azurerm_shared_image_gallery.test.id

  default_auto_shutdown {
    disconnect_delay = "PT15M"
    idle_delay       = "PT15M"
    no_connect_delay = "PT15M"
    shutdown_on_idle = "LowUsage"
  }

  default_connection {
    client_ssh_access = "Public"
    web_ssh_access    = "Public"
  }

  support {
    email        = "company@terraform.io"
    instructions = "Contact support for help"
    phone        = "+1-555-555-5555"
    url          = "https://www.terraform.io/"
  }

  tags = {
    Env = "Test"
  }

  depends_on = [azurerm_role_assignment.test]
}
