
provider "azurerm" {
  features {}
}

data "azurerm_billing_enrollment_account_scope" "test" {
  billing_account_name    = "ARM_BILLING_ACCOUNT"
  enrollment_account_name = ""
}

resource "azurerm_subscription" "test" {
  alias             = "testAcc-221111014346129859"
  subscription_name = "testAccSubscription Renamed 221111014346129859"
  billing_scope_id  = data.azurerm_billing_enrollment_account_scope.test.id
  workload          = "DevTest"
}
