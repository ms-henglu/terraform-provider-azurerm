
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "test" {}

resource "azurerm_consumption_budget_subscription" "test" {
  name            = "acctestconsumptionbudgetsubscription-230721011342049475"
  subscription_id = data.azurerm_subscription.test.id

  amount     = 1000
  time_grain = "Monthly"

  time_period {
    start_date = "2023-07-01T00:00:00Z"
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
