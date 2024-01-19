
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-240119024553046759"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchn1k0m"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"

  network_profile {
    account_access {
      default_action = "Allow"
      ip_rule {
        ip_range = "10.0.1.0"
      }

      ip_rule {
        ip_range = "10.0.3.0/24"
      }
    }

    node_management_access {
      default_action = "Allow"

      ip_rule {
        ip_range = "10.0.2.0"
      }

      ip_rule {
        ip_range = "10.0.4.0/24"
      }
    }
  }
}
