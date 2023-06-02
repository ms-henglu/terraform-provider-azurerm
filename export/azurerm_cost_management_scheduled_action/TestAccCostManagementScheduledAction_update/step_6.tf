
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "test" {}

resource "azurerm_cost_management_scheduled_action" "test" {
  name = "testcostview7dleg"

  view_id = "${data.azurerm_subscription.test.id}/providers/Microsoft.CostManagement/views/ms:CostByService"

  display_name         = "CostByServiceView7dleg"
  message              = "Hi"
  email_subject        = substr("Cost Management Report for ${data.azurerm_subscription.test.display_name} Subscription", 0, 70)
  email_addresses      = ["test@test.com", "hashicorp@test.com"]
  email_address_sender = "test@test.com"

  days_of_week   = ["Monday"]
  weeks_of_month = ["First"]
  frequency      = "Monthly"
  start_date     = "2023-06-03T00:00:00Z"
  end_date       = "2023-06-04T00:00:00Z"
}
