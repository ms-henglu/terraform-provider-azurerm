
provider "azurerm" {
  features {}
}

data "azurerm_billing_enrollment_account_scope" "test" {
  billing_account    = "ARM_BILLING_ACCOUNT"
  enrollment_account = ""
}

resource "azurerm_subscription" "test" {
  alias             = "testAcc-211013072451924296"
  subscription_name = "testAccSubscription Renamed 211013072451924296"
  billing_scope_id  = data.azurerm_billing_enrollment_account_scope.test.id
}
