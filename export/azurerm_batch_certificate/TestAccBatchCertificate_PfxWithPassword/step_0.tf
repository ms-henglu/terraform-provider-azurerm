
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-231016033447868259"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchm7kho"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}

resource "azurerm_batch_certificate" "test" {
  resource_group_name  = azurerm_resource_group.test.name
  account_name         = azurerm_batch_account.test.name
  certificate          = filebase64("testdata/batch_certificate_password.pfx")
  format               = "Pfx"
  password             = "terraform"
  thumbprint           = "42c107874fd0e4a9583292a2f1098e8fe4b2edda"
  thumbprint_algorithm = "SHA1"
}
