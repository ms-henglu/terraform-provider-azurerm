
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-211029015801084008"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-211029015801084008"
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
    }

    workflow_management {
      allowed_caller_ip_address_range = ["10.0.8.0-10.0.8.10"]
    }
  }
}
