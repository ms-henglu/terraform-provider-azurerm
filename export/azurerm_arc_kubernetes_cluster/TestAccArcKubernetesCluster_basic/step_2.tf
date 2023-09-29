
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064348477850"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230929064348477850"
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
  name                = "acctestpip-230929064348477850"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230929064348477850"
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
  name                            = "acctestVM-230929064348477850"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2910!"
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
  name                         = "acctest-akcc-230929064348477850"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA821tBt7jGjYwdeQQGGRn2+QcdflQpWbnhMlHA78LMlSGzsTzgopx2TGf8WJk5+1C3x7zenyQoiXj4dr3/gMZ6vSElpPI842fUhDkwF7o2A1Crkyeh6aVFYuA5/HtUDAD+WtixI3lGSiHwllI3TrWEcoqfbjJskdTpEYVuIcLPG4Nvr5Cr9a2o7S3tmOOAAZiPCSozlCgzhpRHeJP/vUIF2LTnv6ywWnlYMyXVOjga2DaBWnTMIB/pVatLlA4czS+vWYOdeHcXO2vAv6FrOFndCXgZen/1IH7F8RmsWvsa34Y5y/mo6xmeYbSf53Xl+k2E54M5IT1OvdkWDxUNi048czBrO4KURdyJ+8RRi4GCkuLI9ggbOqodZ38VOnKAxKha8xBc2trFp5fk2ojIA0QZiA/bQQ2iwdHTZTeFUeXDslb6xdufTYQ+R+Q+taCMJCXGwdQJJM1WYsMpx7tv2No8rA+It2Q74omhbBRskUFVGtJe4dyxukHVT9dcDVMO0Ti5yds2XoD7dPQZGYYHwfFKToEWiYzn+vZT7a7ojcP0nd+sjp6dwpYH+/IJHCbdaAdWH2C2Zz4ci9nDHYANr7dsKqkZpoMrGw9Jh/4tuiJT5I33wYD3V8j9h00ZvvFoVFBkZSfcpLvGM1dXYiayeoqhqVm6E/yQcsH13jc5xKUU9UCAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "TestUpdate"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2910!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230929064348477850"
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
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
Nwu0vuMCggEAEwSJoLgqoOFVTVECdvVK1Q8gCqFgoBRdXA6z83ilmnXXV8WdYM+J
0l2ImqD8bUgWn0kkRlN/L+bFKhtYBaiQd2o++BHQ5onesFpvZhyLgwz2/sRcwIWC
WJhK0SmzS+raUImaSW2/zi1DsnGOCDMW859vEWhGgoFtP8zujZ0SrW1I1qLnl3bk
25IseL3Q9VwqbDu5NzxEkSxZniZle050o/tHQpQv+Tn0x07805lmR7VYfctv8tW0
fRcUYMx7lDWtQSiF0szJ6k0i+XrcaxvXh6Jd8eZ3uRMSgk5wMoFlU74j/en8zcY9
Y1BX7RRqyt1+09fKb99uvOkCp5BkK+vrZQKCAQEAoZU5CCQsA39GawXOyLrUY4rf
jEzUoj4l4Fq6dH/I9DTkGDtJLlOTj+mpfS11liINCZCYy+DkzR+5+2zzVi6uOs/X
C2RlM6VMfIKjGJUPrfMpFup5HLY4O6KatIRc0oevd25ulDi9mXajYVpwXP9ug45c
y47kuMsq3lf/fvCAU+4XQdjxar/zKxFeMb5Sq31lfimX4vwrWa1hzBkaf9bWsHGk
97u23i7Eslewxhjut6z+dDBB0c3T2Sh/UTEmWXBOEDK+jJ+JJtlq19A/yQ8Q8+VN
Dbq2/fCYb5Ub8Chmaii5EsjkrWSTBsxLn4xVfoKHIJu+NBzfgIBSxZzMC+mZHw==
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
