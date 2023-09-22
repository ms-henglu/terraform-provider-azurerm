
provider "azurerm" {
  features {}
}

data "azurerm_platform_image" "test" {
  location  = "northeurope"
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-confidential-vm-focal"
  sku       = "20_04-lts-cvm"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060812849893"
  location = "northeurope"
}


resource "azurerm_managed_disk" "test" {
  name                 = "acctestd-230922060812849893"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  os_type              = "Linux"
  hyper_v_generation   = "V2"
  create_option        = "FromImage"
  image_reference_id   = data.azurerm_platform_image.test.id
  storage_account_type = "Standard_LRS"

  security_type = "ConfidentialVM_VMGuestStateOnlyEncryptedWithPlatformKey"
}
