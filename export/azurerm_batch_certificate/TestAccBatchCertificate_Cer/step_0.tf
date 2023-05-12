
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230512010257554982"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch3tc6b"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}

resource "azurerm_batch_certificate" "test" {
  resource_group_name  = azurerm_resource_group.test.name
  account_name         = azurerm_batch_account.test.name
  certificate          = filebase64("testdata/batch_certificate.cer")
  format               = "Cer"
  thumbprint           = "312d31a79fa0cef49c00f769afc2b73e9f4edf34"
  thumbprint_algorithm = "SHA1"
}
