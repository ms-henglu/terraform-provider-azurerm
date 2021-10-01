
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-211001224205360539"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-211001224205360539"
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
    }

    workflow_management {
      allowed_caller_ip_address_range = ["10.10.6.0/24"]
    }
  }
}
