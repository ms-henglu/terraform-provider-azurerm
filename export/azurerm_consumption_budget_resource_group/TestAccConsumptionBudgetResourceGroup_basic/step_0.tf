
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204107221898"
  location = "West Europe"
}

resource "azurerm_consumption_budget_resource_group" "test" {
  name              = "acctestconsumptionbudgetresourcegroup-221221204107221898"
  resource_group_id = azurerm_resource_group.test.id

  amount     = 1000
  time_grain = "Monthly"

  time_period {
    start_date = "2022-12-01T00:00:00Z"
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
