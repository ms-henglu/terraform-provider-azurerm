
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-230825024815968696"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-230825024815968696"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  enabled             = false

  access_control {
    content {
      allowed_caller_ip_address_range = ["10.10.3.0/24"]
    }

    action {
      allowed_caller_ip_address_range = ["10.10.4.0/24"]
    }

    trigger {
      allowed_caller_ip_address_range = ["10.10.5.0/24"]

      open_authentication_policy {
        name = "testpolicy4"

        claim {
          name  = "iss"
          value = "https://sts.windows.net/"
        }

        claim {
          name  = "testclaimname"
          value = "testclaimvalue"
        }
      }
    }

    workflow_management {
      allowed_caller_ip_address_range = ["10.10.6.0/24"]
    }
  }
}
