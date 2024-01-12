
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_management_group" "tenant_root" {
  name = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112034056875927"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestAG-240112034056875927"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestAG"
}

resource "azurerm_consumption_budget_management_group" "test" {
  name                = "acctestconsumptionbudgetManagementGroup-240112034056875927"
  management_group_id = data.azurerm_management_group.tenant_root.id

  // Changed the amount from 1000 to 2000
  amount     = 2000
  time_grain = "Monthly"

  // Removed end_date
  time_period {
    start_date = "2024-01-01T00:00:00Z"
  }

  filter {
    dimension {
      name = "ResourceGroupName"
      values = [
        azurerm_resource_group.test.name,
      ]
    }

    tag {
      name = "foo"
      values = [
        "bar",
        "baz",
      ]
    }

    // Added tag: zip
    tag {
      name = "zip"
      values = [
        "zap",
        "zop",
      ]
    }

    // Removed not block 
  }

  notification {
    enabled        = true
    threshold      = 90.0
    operator       = "EqualTo"
    threshold_type = "Actual"

    contact_emails = [
      // Added baz@example.com
      "baz@example.com",
      "foo@example.com",
      "bar@example.com",
    ]
  }

  notification {
    // Set enabled to true
    enabled        = true
    threshold      = 100.0
    threshold_type = "Forecasted"
    // Changed from EqualTo to GreaterThanOrEqualTo 
    operator = "GreaterThanOrEqualTo"

    contact_emails = [
      "foo@example.com",
      "bar@example.com",
    ]
  }
}
