

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "test" {}

resource "azurerm_consumption_budget_subscription" "test" {
  name            = "acctestconsumptionbudgetsubscription-231016033617953084"
  subscription_id = data.azurerm_subscription.test.id

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


resource "azurerm_consumption_budget_subscription" "import" {
  name            = azurerm_consumption_budget_subscription.test.name
  subscription_id = azurerm_consumption_budget_subscription.test.subscription_id

  amount     = azurerm_consumption_budget_subscription.test.amount
  time_grain = azurerm_consumption_budget_subscription.test.time_grain

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
