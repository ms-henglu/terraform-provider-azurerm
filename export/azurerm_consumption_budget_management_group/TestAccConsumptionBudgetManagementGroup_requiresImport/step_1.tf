

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_management_group" "tenant_root" {
  name = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_consumption_budget_management_group" "test" {
  name                = "acctestconsumptionbudgetManagementGroup-231013043148738867"
  management_group_id = data.azurerm_management_group.tenant_root.id

  amount     = 1000
  time_grain = "Monthly"

  time_period {
    start_date = "2023-10-01T00:00:00Z"
  }

  filter {
    tag {
      name = "foo"
      values = [
        "bar"
      ]
    }
  }

  notification {
    enabled   = true
    threshold = 90.0
    operator  = "EqualTo"

    contact_emails = [
      "foo@example.com",
      "bar@example.com",
    ]
  }
}


resource "azurerm_consumption_budget_management_group" "import" {
  name                = azurerm_consumption_budget_management_group.test.name
  management_group_id = azurerm_consumption_budget_management_group.test.management_group_id

  amount     = azurerm_consumption_budget_management_group.test.amount
  time_grain = azurerm_consumption_budget_management_group.test.time_grain

  time_period {
    start_date = "2023-10-01T00:00:00Z"
  }

  notification {
    enabled   = true
    threshold = 90.0
    operator  = "EqualTo"

    contact_emails = [
      "foo@example.com",
      "bar@example.com",
    ]
  }
}
