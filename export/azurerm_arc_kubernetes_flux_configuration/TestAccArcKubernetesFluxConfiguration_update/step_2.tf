
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023534448032"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230818023534448032"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-230818023534448032"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230818023534448032"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id
  }
}

resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.test.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = "acctestVM-230818023534448032"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6039!"
  provision_vm_agent              = false
  allow_extension_operations      = false
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}


resource "azurerm_arc_kubernetes_cluster" "test" {
  name                         = "acctest-akcc-230818023534448032"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyUJkQHdOnhlvFc2+rCYcwBmO7B52/TI1UIeUxZcOIvrQTZd0tlalUduieYfqZrfDgQi4GeWpvffjuzKFAXZTYTcxrJIyoPpV08EaY2xomed5O0OTIEneWD1jJgXmO5YvaLy7jgViKod5rO4SihkzOo+00Swp6r+qRM4mL4alodUbYwBPyHofrRsUNo1V7RV/GeDgtE73VoRsd24PLJocbzsk++WaRowK9rvFmgzPXueCgsXdKkqJGF66vcQAspb/zbWFLjBRBtbAGzYmXgxWmQqDA6l1q+sbXWY84doIL6Gc5AR9Clsl/1s4dXOv5uCjaaF9kuEKdhRoPj3iQTKBJbSa/GuWZ5AavJ7fdn4w4gARGjPqrU7Q0wy30TnrF2W6RHlNb8gYcdkJ+9o5/6y5p1HhKL7pZFmsfgyFk/Vj4BFdqB6M5P4Vqf8UikC5RGYj5Fwvcs2Uq3M7yToUMTb6+0s3gbB2MNzEddTgMo32oJwekijUafZmA6D21Zv/bwW4awutbV9tniYC/LZ6EAQg+Ch1ND+p/ewLrKV9OqGkCnJbsClrorRP3xB1IMeOshT4nvabXuoiXT3MIGp4TGTmAmSl7mJvVXmWlXam8aOsALdXs+h94rhGfrZJi2lO0kptlCvQYdIUKrT1PJ0qciMIQdSW2TF63EMlOHWuF0npoqMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6039!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230818023534448032"
    location            = azurerm_resource_group.test.location
    tenant_id           = "ARM_TENANT_ID"
    working_dir         = "/home/adminuser"
  })
  destination = "/home/adminuser/install_agent.sh"
}

provisioner "file" {
  source      = "testdata/install_agent.py"
  destination = "/home/adminuser/install_agent.py"
}

provisioner "file" {
  source      = "testdata/kind.yaml"
  destination = "/home/adminuser/kind.yaml"
}

provisioner "file" {
  content     = <<EOT
-----BEGIN RSA PRIVATE KEY-----
MIIJKgIBAAKCAgEAyUJkQHdOnhlvFc2+rCYcwBmO7B52/TI1UIeUxZcOIvrQTZd0
tlalUduieYfqZrfDgQi4GeWpvffjuzKFAXZTYTcxrJIyoPpV08EaY2xomed5O0OT
IEneWD1jJgXmO5YvaLy7jgViKod5rO4SihkzOo+00Swp6r+qRM4mL4alodUbYwBP
yHofrRsUNo1V7RV/GeDgtE73VoRsd24PLJocbzsk++WaRowK9rvFmgzPXueCgsXd
KkqJGF66vcQAspb/zbWFLjBRBtbAGzYmXgxWmQqDA6l1q+sbXWY84doIL6Gc5AR9
Clsl/1s4dXOv5uCjaaF9kuEKdhRoPj3iQTKBJbSa/GuWZ5AavJ7fdn4w4gARGjPq
rU7Q0wy30TnrF2W6RHlNb8gYcdkJ+9o5/6y5p1HhKL7pZFmsfgyFk/Vj4BFdqB6M
5P4Vqf8UikC5RGYj5Fwvcs2Uq3M7yToUMTb6+0s3gbB2MNzEddTgMo32oJwekijU
afZmA6D21Zv/bwW4awutbV9tniYC/LZ6EAQg+Ch1ND+p/ewLrKV9OqGkCnJbsClr
orRP3xB1IMeOshT4nvabXuoiXT3MIGp4TGTmAmSl7mJvVXmWlXam8aOsALdXs+h9
4rhGfrZJi2lO0kptlCvQYdIUKrT1PJ0qciMIQdSW2TF63EMlOHWuF0npoqMCAwEA
AQKCAgBjwL914GycGhkgInkmVEGdyU04pSTu/ErGnlzTzroYBl7mhnI3yhxoxUbz
m7VHsj95nju5wkZuvQYoC7M29VIAdl3tngzwEwQlT6nnq5zw43UINccfkt1cuRiC
iRwDXr4i2KDRlMOCNuHNH7cascDdfsrtfklMbDFVpyPwHHnOC5VmbYod4MIAh9Jt
84GqYCQ+TGKznAwl2r70Nx3YSo5bZ2I+ZCAiZVkt0AXyA/VoobDjZnTneEgZRyKh
2htKaWNir1zSdupCTICtPBqqNM1bT4V+dCi5zG8kzP7SJsI18ZGUxtC/KExeE/WY
6X0/Hwp/2aYm/dm0iwrcBso07HZruw4LZ5vYbPonKvNkRlnBJkT2nym6qrnC5B5y
Iokgb3aNbaPxmzh6AVMhvvyQi2RjpFfqOYNQSBqbBuQ88YchKKv76yNNv6Ga+L71
zjCpC9eCFOSMyL2bem30DhC53cFHTs7E9SsbQjhMl5FvlMLQyEgwDDQrKUy8iqp6
S3pzLehMQomS3y8U0ioss3DdyIRFnuPnL3j3hOBuRpdHdxcRwiqdu6XJ+NmwlgOr
fm5eoZ+WtD1hWh4DOWnSR5K1InxpKyblyZr82JYnLZDKb94xMA/a7GAa+uapBgcQ
ESS2nuvKbIBt0IO99Lfw9bzbvhd9ez4IHPGBMuWzIll8glL+gQKCAQEA0DZUQcPA
Wiqnl31sYyf4+Ug1WwdOGMh/B7u41zF28VDpYPEw29Pgs24zQ1l3zl8p0l02h5e6
QjlJysjNSalxn7tFEVz44ebxjQU18HIW7rFTuTC/CdjYlSWw51FTlD5hyooVIEby
QeHaQErOGhZl8rx6y3iArPO/u8Ob9Dq8BFqbZeYgs9saIn31mfHRxQxp84Da756L
7JBx77zyZLQZeIo5wxEmimbaCdaE18aS1F+Yf4ZmTqMtTV9LtW2ofuGk1uh/3HPR
8REtmm1ltyiRSxmFycUFPalmKfZsTx4cTW3c8wcyoCmROCxvGJjznm6t/wx/Ucil
puECDy71d8y/YwKCAQEA93OKYjWzrg5gMIaG5WdwgGFophmWQ7Po0oscT4BM3yD+
MR6hPNfOiLAduDAT7EehcBJyXcxDeiMpx2nicAVX3cLaKCN8piMtihLvPO0oj4UN
9TqJo1ryuvUDss0kp+fRm2zTMtVDZunF6RmEVnn55v9W0+FfuDUV/jDUZmeskE8g
nmUxaV0xRs7bxMvCH/Mhgpw06DwAIEBLLmHDrQp6XUAa9DdOmS1wfn8CkBVRAWPZ
aRuwYa+9XHVII0QWZI8G+9x9zP4SU07tB0uB6OYhD0EMiXyGasB/hjtiDtvrq0Dh
oJ6r57Q/h5ED8mZnnbUDx1OtbclZ1+k3u1zZxhMTwQKCAQEAx3tVzFBEiN6XBI/Y
+UMByauB2v2ruBjXg8w5soqkn1zay9Mo8WQUwzQQjzU3kJQiGHbP2Kbof6wtY8hw
zmM2BkhASvtdQ+mkgWx9milkiTmBskrerQuBrZuX2ndTcRM3U/ppdSwjzDUbij9h
KSNOd3pW13xTI+DAUJ9/WkWvfyhj/AO4Tzja2DL/zIcfZ/+VvwM0PyEShAp77qmD
PjJCuPcNkjNrTmxt98D8M1L/t9MC4yMb/7lcnOVxPpiaNz3uVSwZ3Fdmy+SeYXbw
XcPTODVytbY6aDJVPFzotgBuM0zPxFOgEEzi4gPISLO5rI/zygjqLqvi8XhgJbXi
3e1fawKCAQEA7A9VHIuOdaVRLfmoBoC/WjmS06HlL4EZwoDi6RTEQLgAxmsp9hkJ
9mvMbkGvP+C1qWxvnfuXA5U37fyc/7CZOf0AkPoJl5RHhUi64ax83S1ZO3A0jZnd
pWzHsnLxXRxRYaxXbk70leC95Llq/fQu6qb79fUyk1BRQsTiWy7b+G8D9xciJBm7
QIlmLj8TWddfSHIsJr/Wfu3WytCJEzLDuOHG1ONOH+KxRntzvnAXbvQKG7NGeGpm
gyV/Q+VYV2X6i5q0iDJ42PCaPjNSIxQmxZ6Qjzg0IvKwtSVBTluOXzjuBYRZChlx
4an90ejPQCvHBwhUkj9bbhYWDK9vMP5SAQKCAQEAluCuv8fBgHXNgDnOBTFFI53I
+LwWBcWuVYFs7Fx7XUQSiKBcfcawozZsYjCYeULM+lppQado8A/rB062wLyKAlul
uZ7q8zyBT9mhAyf5mmgB7EgZVZtuxnuLZ9HiuAimVwT6t2iu488EB42jC53FsTS+
UfFUyvxQFmW8YAPnD0v07tCMnx0L5f+QPbUlNuX1uMvyW1N1odUu/8gMCR0xpA/j
FixY4gqIXLQO2U5GSXLUTo/b431L7O46nn+K66YDewfNIebd0Nz59e2vYT6sc9ey
WO8xm5xtm3tyrHrGgPCtedXWN8Kfp8UFyZHRlMGwf86dK2+HckHu8VliqQe7eg==
-----END RSA PRIVATE KEY-----

EOT
  destination = "/home/adminuser/private.pem"
}

provisioner "remote-exec" {
  inline = [
    "sudo sed -i 's/\r$//' /home/adminuser/install_agent.sh",
    "sudo chmod +x /home/adminuser/install_agent.sh",
    "bash /home/adminuser/install_agent.sh > /home/adminuser/agent_log",
  ]
}


  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_cluster_extension" "test" {
  name           = "acctest-kce-230818023534448032"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230818023534448032"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  git_repository {
    url                      = "https://github.com/Azure/arc-k8s-demo"
    https_user               = "example"
    https_key_base64         = base64encode("example")
    https_ca_cert_base64     = base64encode("example")
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    reference_type           = "branch"
    reference_value          = "main"
  }

  kustomizations {
    name                       = "kustomization-1"
    path                       = "./test/path"
    timeout_in_seconds         = 800
    sync_interval_in_seconds   = 800
    retry_interval_in_seconds  = 800
    recreating_enabled         = true
    garbage_collection_enabled = true
  }

  kustomizations {
    name       = "kustomization-2"
    depends_on = ["kustomization-1"]
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
