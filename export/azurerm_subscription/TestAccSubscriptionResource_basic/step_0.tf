
provider "azurerm" {
  features {}
}

data "azurerm_billing_enrollment_account_scope" "test" {
  billing_account    = "ARM_BILLING_ACCOUNT"
  enrollment_account = ""
}

resource "azurerm_subscription" "test" {
  alias             = "testAcc-221111014346127998"
  subscription_name = "testAccSubscription 221111014346127998"
  billing_scope_id  = data.azurerm_billing_enrollment_account_scope.test.id
}
