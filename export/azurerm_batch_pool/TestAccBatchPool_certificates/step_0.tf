
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestbatch231016033447865943"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatch3rc33"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_batch_certificate" "testcer" {
  resource_group_name  = azurerm_resource_group.test.name
  account_name         = azurerm_batch_account.test.name
  certificate          = filebase64("testdata/batch_certificate.cer")
  format               = "Cer"
  thumbprint           = "312d31a79fa0cef49c00f769afc2b73e9f4edf34" # deliberately using lowercase here as verification
  thumbprint_algorithm = "SHA1"
}

resource "azurerm_batch_certificate" "testpfx" {
  resource_group_name  = azurerm_resource_group.test.name
  account_name         = azurerm_batch_account.test.name
  certificate          = filebase64("testdata/batch_certificate_password.pfx")
  format               = "Pfx"
  password             = "terraform"
  thumbprint           = "42c107874fd0e4a9583292a2f1098e8fe4b2edda"
  thumbprint_algorithm = "SHA1"
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpool3rc33"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  node_agent_sku_id   = "batch.node.ubuntu 18.04"
  vm_size             = "Standard_A1"

  fixed_scale {
    target_dedicated_nodes = 1
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-lts"
    version   = "latest"
  }

  certificate {
    id             = azurerm_batch_certificate.testcer.id
    store_location = "CurrentUser"
    visibility     = ["StartTask"]
  }

  certificate {
    id             = azurerm_batch_certificate.testpfx.id
    store_location = "CurrentUser"
    visibility     = ["StartTask", "RemoteUser"]
  }
}
