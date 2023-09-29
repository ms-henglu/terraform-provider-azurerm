

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "test" {}

resource "azurerm_cost_management_scheduled_action" "test" {
  name = "testcostviewaaz3d"

  view_id = "${data.azurerm_subscription.test.id}/providers/Microsoft.CostManagement/views/ms:CostByService"

  display_name         = "CostByServiceViewaaz3d"
  email_subject        = substr("Cost Management Report for ${data.azurerm_subscription.test.display_name} Subscription", 0, 70)
  email_addresses      = ["test@test.com", "hashicorp@test.com"]
  email_address_sender = "test@test.com"

  frequency  = "Daily"
  start_date = "2023-09-30T00:00:00Z"
  end_date   = "2023-10-01T00:00:00Z"
}


resource "azurerm_cost_management_scheduled_action" "import" {
  name = azurerm_cost_management_scheduled_action.test.name

  view_id = azurerm_cost_management_scheduled_action.test.view_id

  display_name         = azurerm_cost_management_scheduled_action.test.display_name
  email_subject        = azurerm_cost_management_scheduled_action.test.email_subject
  email_addresses      = azurerm_cost_management_scheduled_action.test.email_addresses
  email_address_sender = azurerm_cost_management_scheduled_action.test.email_address_sender

  frequency  = azurerm_cost_management_scheduled_action.test.frequency
  start_date = azurerm_cost_management_scheduled_action.test.start_date
  end_date   = azurerm_cost_management_scheduled_action.test.end_date
}
