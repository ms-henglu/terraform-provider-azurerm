
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "test" {}

resource "azurerm_cost_management_scheduled_action" "test" {
  name = "testcostviewo7nib"

  view_id = "${data.azurerm_subscription.test.id}/providers/Microsoft.CostManagement/views/ms:CostByService"

  display_name         = "CostByServiceViewo7nib"
  message              = "Hi"
  email_subject        = substr("Cost Management Report for ${data.azurerm_subscription.test.display_name} Subscription", 0, 70)
  email_addresses      = ["test@test.com", "hashicorp@test.com"]
  email_address_sender = "test@test.com"

  hour_of_day  = 23
  day_of_month = 30
  frequency    = "Monthly"
  start_date   = "2023-09-16T00:00:00Z"
  end_date     = "2023-09-17T00:00:00Z"
}
