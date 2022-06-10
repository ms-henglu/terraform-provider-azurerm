
provider "azurerm" {
  features {}
}

data "azurerm_billing_enrollment_account_scope" "test" {
  billing_account    = "ARM_BILLING_ACCOUNT"
  enrollment_account = ""
}

resource "azurerm_subscription" "test" {
  alias             = "testAcc-220610093343682476"
  subscription_name = "testAccSubscription 220610093343682476"
  billing_scope_id  = data.azurerm_billing_enrollment_account_scope.test.id
}
