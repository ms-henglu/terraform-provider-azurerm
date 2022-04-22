
provider "azurerm" {
  features {}
}

data "azurerm_billing_enrollment_account_scope" "test" {
  billing_account    = "ARM_BILLING_ACCOUNT"
  enrollment_account = ""
}

resource "azurerm_subscription" "test" {
  alias             = "testAcc-220422025911678715"
  subscription_name = "testAccSubscription Renamed 220422025911678715"
  billing_scope_id  = data.azurerm_billing_enrollment_account_scope.test.id
}
