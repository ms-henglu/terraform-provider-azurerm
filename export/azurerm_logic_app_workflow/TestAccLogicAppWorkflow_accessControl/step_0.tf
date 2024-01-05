
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-240105064101790853"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-240105064101790853"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  access_control {
    content {
      allowed_caller_ip_address_range = ["10.0.5.0-10.0.5.10"]
    }

    action {
      allowed_caller_ip_address_range = ["10.0.6.0-10.0.6.10"]
    }

    trigger {
      allowed_caller_ip_address_range = ["10.0.7.0-10.0.7.10"]

      open_authentication_policy {
        name = "testpolicy1"

        claim {
          name  = "iss"
          value = "https://sts.windows.net/"
        }

        claim {
          name  = "aud"
          value = "https://management.core.windows.net/"
        }
      }
    }

    workflow_management {
      allowed_caller_ip_address_range = ["10.0.8.0-10.0.8.10"]
    }
  }
}
