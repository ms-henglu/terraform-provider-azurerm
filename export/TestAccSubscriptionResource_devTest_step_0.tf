
provider "azurerm" {
  features {}
}

data "azurerm_billing_enrollment_account_scope" "test" {
  billing_account_name    = "ARM_BILLING_ACCOUNT"
  enrollment_account_name = ""
}

resource "azurerm_subscription" "test" {
  alias             = "testAcc-211210025136559606"
  subscription_name = "testAccSubscription Renamed 211210025136559606"
  billing_scope_id  = data.azurerm_billing_enrollment_account_scope.test.id
  workload          = "DevTest"
}
