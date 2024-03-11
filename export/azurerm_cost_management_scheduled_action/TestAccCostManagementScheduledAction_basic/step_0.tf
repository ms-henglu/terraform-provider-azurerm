
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "test" {}

resource "azurerm_cost_management_scheduled_action" "test" {
  name = "testcostview93j7a"

  view_id = "${data.azurerm_subscription.test.id}/providers/Microsoft.CostManagement/views/ms:CostByService"

  display_name         = "CostByServiceView93j7a"
  email_subject        = substr("Cost Management Report for ${data.azurerm_subscription.test.display_name} Subscription", 0, 70)
  email_addresses      = ["test@test.com", "hashicorp@test.com"]
  email_address_sender = "test@test.com"

  frequency  = "Daily"
  start_date = "2024-03-12T00:00:00Z"
  end_date   = "2024-03-13T00:00:00Z"
}
