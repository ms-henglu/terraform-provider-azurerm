

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064611217931"
  location = "West Europe"
}

resource "azurerm_consumption_budget_resource_group" "test" {
  name              = "acctestconsumptionbudgetresourcegroup-230929064611217931"
  resource_group_id = azurerm_resource_group.test.id

  amount     = 1000
  time_grain = "Monthly"

  time_period {
    start_date = "2023-09-01T00:00:00Z"
  }

  filter {
    tag {
      name = "foo"
      values = [
        "bar",
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


resource "azurerm_consumption_budget_resource_group" "import" {
  name              = azurerm_consumption_budget_resource_group.test.name
  resource_group_id = azurerm_resource_group.test.id

  amount     = azurerm_consumption_budget_resource_group.test.amount
  time_grain = azurerm_consumption_budget_resource_group.test.time_grain

  time_period {
    start_date = "2023-09-01T00:00:00Z"
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
