

provider "azurerm" {
  features {}
}

data "azurerm_billing_enrollment_account_scope" "test" {
  billing_account    = "ARM_BILLING_ACCOUNT"
  enrollment_account = ""
}

resource "azurerm_subscription" "test" {
  alias             = "testAcc-220818235711393411"
  subscription_name = "testAccSubscription 220818235711393411"
  billing_scope_id  = data.azurerm_billing_enrollment_account_scope.test.id
}


resource "azurerm_subscription" "import" {
  alias             = azurerm_subscription.test.alias
  subscription_name = azurerm_subscription.test.subscription_name
  billing_scope_id  = azurerm_subscription.test.billing_scope_id
}
