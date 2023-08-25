
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024030748326"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230825024030748326"
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
  name                = "acctestpip-230825024030748326"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230825024030748326"
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
  name                            = "acctestVM-230825024030748326"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7090!"
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
  name                         = "acctest-akcc-230825024030748326"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA4hAHXJYl4Dk2dnT0xYPrcPiztHeWsaAu9YiHPSNHa6F8MU0GXRxckk+lOmaHsZWYyJj/mu/pJtQK8zzPlUeIvakAQuSVDtmkCzCKp6lxi2qKR6IKz/0X4GGP7xFMFxve8RM+gkP9oOH/Uyyzoe9Y4KxUy+0hlbFXbIsjhYYmlAjk70IFaIdW0d3uSNnFDZLFu9KmqcEzSi242wkjkIZ9iAp2IK1U+UGNL1oAWV6qcO5H2spThc0a1BNGc8x5n4KZxWp6Qe/30NL8gfF81xFnYLWT4TciFBt9wYg3jRAcDPs81EmnMC8e1s4IVCuZJTMonF2M7wzNciM7DScghnxCdZH6HVzOfCJiFyGSG6kTWsIVud6AkaGeG/0vbCRGeGXL4bquym1h7SVIgd/0UbWDFKxq6b2k9zfxx2QAKtnr2+zexq7OMa3wQbgrUv/IkPBxRM6SqLP1fhmU8n7bBfSSpVB8UgLUlIKShk13y9AgMhK+JfBniXy7VUFmhvQpodiFuY0J3H7We65ylOLBj7KbRttr5pnYH6yHbYSor50UvWdQRIWE1Iacx1+F04UHEEpv+Ib5Dqx6HZebG73PCzjMPBri55YzxiNCA2kwngFg7mi6tpwonhtqj/b6MmFN7p6v/J0D2BWMvJgwqRr7qUZj/X1Y7ro3Cm/kkSOO+ZXvpB8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7090!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230825024030748326"
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
MIIJKAIBAAKCAgEA4hAHXJYl4Dk2dnT0xYPrcPiztHeWsaAu9YiHPSNHa6F8MU0G
XRxckk+lOmaHsZWYyJj/mu/pJtQK8zzPlUeIvakAQuSVDtmkCzCKp6lxi2qKR6IK
z/0X4GGP7xFMFxve8RM+gkP9oOH/Uyyzoe9Y4KxUy+0hlbFXbIsjhYYmlAjk70IF
aIdW0d3uSNnFDZLFu9KmqcEzSi242wkjkIZ9iAp2IK1U+UGNL1oAWV6qcO5H2spT
hc0a1BNGc8x5n4KZxWp6Qe/30NL8gfF81xFnYLWT4TciFBt9wYg3jRAcDPs81Emn
MC8e1s4IVCuZJTMonF2M7wzNciM7DScghnxCdZH6HVzOfCJiFyGSG6kTWsIVud6A
kaGeG/0vbCRGeGXL4bquym1h7SVIgd/0UbWDFKxq6b2k9zfxx2QAKtnr2+zexq7O
Ma3wQbgrUv/IkPBxRM6SqLP1fhmU8n7bBfSSpVB8UgLUlIKShk13y9AgMhK+JfBn
iXy7VUFmhvQpodiFuY0J3H7We65ylOLBj7KbRttr5pnYH6yHbYSor50UvWdQRIWE
1Iacx1+F04UHEEpv+Ib5Dqx6HZebG73PCzjMPBri55YzxiNCA2kwngFg7mi6tpwo
nhtqj/b6MmFN7p6v/J0D2BWMvJgwqRr7qUZj/X1Y7ro3Cm/kkSOO+ZXvpB8CAwEA
AQKCAgEAr6EMVx4/5ugMLBPJZvqKnIZb90VBylZMpW2gxBr4jeIz/ol8/DHgqbs+
/xRRL+KthIt5agIh/YyXxUnlbHDbB56ZGV9FfvgPvrHDx2aZVFs9e1GlXNmhBy5F
CNNDbmC04E63LbVtAuUR3KjKFnFBd6vrZVOh2A6jgSzIOCB1MGWIl2mPkhozlXD6
g5bMxTLWdIm/+fqjwmmrSGDdRJd4R4z5IYIIlm4bJkKiKsylVn+JS64NHdKvmTww
bB7cDtUEap/CxB+PRKnmi332I5Dd5ACuFzciPsTs+sK9hdaSNHOsWrGuNn0lVHVV
ey80F/abAoCb0cz8gERmyF0xo8o+RmuHsjyThukZU9L0/lesm3vjXFYextHoTFg3
Qn+DtzqIvZmjfdF7NGqM1EfOv2AAyhFBpw3t/xg2D9g4ZhnWym+szLAFa/jFKqlz
5yAbWtva6DiD14pYdHZ5manScDfV7rpEzJnscZ2/2jtXxDZII/HnbihjKqe9sYEs
RNyRFaosOWYXUq/M8p9hGATJOlQFEypH3tl/oq4J7YezZMBXaZjLryxqWqftIY7F
tp6rEqfAAmSKNgFfuOhYCyGgGOnULeUU8V9rzhsUDDQ9Iw1nUyP2sXcZSVi9bXy6
gMTUm8kuAh1u1w+o/GAUc+mrw4BnCHaEybJNeXqK+VYYlxb8tkECggEBAO7GJ8SY
S3PrunOdf4b12l6g8gKzkPk8YdBrnftwwBuBzk52vzuYXPNOd+DEVAJ5nF6Cepbq
iEGIBXzgZNwS5IBrg52ZyAHm6joZhKuZ6wcWQ3SLiamrUs/sILVGcrljLjsmno5L
usvihqd22/ErMmgLhYcthPOf50sonrwt+fqONnKJEB/2pZ1YEADaeazXOqnFaM7n
QSCHjVS/Ep4b+jnzgpS5JHgJDitEJNHHANai5NC9KPJqzR4u6hDDURVPtXNTfRHP
4gSzEAQQ0YVUefimtxpZdFc0l5H8VBpCGEihPYpZQNkRZBjktlNjkCcXMn+rGm5H
PLYGicns5S5gnpkCggEBAPJfHCB/s1KxLwZcns4DlPrxNbNSGJtvMM9zAOg5s2RL
M5GzjTDRHZxhdWOrcJpb+iyqOkKOr4eXtkl36SKlrj7SKqXMZVZGbGUy4vaXNpkZ
+/b1PeaC48GdUKJIKTtbCLXJgk8aCb/FQbLnvUzYRKjFK01n21Ud9RO3aTCcxz6s
f4g6Z2o9PgBuuqvgdCNpyoNJuy+6PtUkZoYvvW/wAQ81a2Zro7y5XWU2Njrk6Hto
824XPcb7nRlYTm1WFj1nnIJrhlRgxCCjoQlopXm5T5jVxAc3KGOAIWlGhhd5uUQW
xkFrwoD2IGaYc+fBDzn+0OqBpKMGIOhIUaMH1pVvI3cCggEAfNIx79/9cbgFXHM1
O4RCh71zRl5Ap0odiCr6B3vFsZuGEhaZmbnovXiDyohXsoOIbw+erk4ktL06wTE9
CJ8HvOp3f2fo2rWwNHcql9p6ttW4pbBcYsohHHjAEIOnbaqffGSP9qs4F2VwJxNH
nyeJzkJXp3bwTbuF2hB+CrmuOIEnjXCBcXQq17o1g3yyptxM2ntMcv0JWswB4g+Q
1/6gLLNTzBONMQLq2UtiRBfYJFw7abO5OCEE4YZ87g5s0Ms+e+9lLm6SJQrGkJmK
Lj0fFhFxHuEspHnl0ncqMB/lOfKwjSZjdBZXUXwepDEkJotF5t+3jXbIEhAQ7/Jb
TIdN4QKCAQBhiZECKyH5V0C7aK6n7Z0Y19VqktFATCDyey+URRRCelkIe5+IU798
3WOmdqncFMO7Ec5cVpuhD5bWPiFeRhq3QVDUZEsryy94EmBwKC5asrBJlCwTBf2u
PybiB/Q/5MS+k5eTScE+oZ1s6AGwWSBYYvCoN/F2cZXdF2SHobA1MqooIojXokm/
VtBctvlF/x72cseXz3XVxM5VlgTAdW+XtUHBd/Pu0RIa1xQ/4zsD3xqH5WaBG2T/
fCAjtA9DKt07RxZKAp8rG26FIM3nDIJR2UUIOlRQppHLkgwIin3aPugOD9W4nFQx
tYx/aZw9FKTymrWsvZykneXsnAzpGk7FAoIBADNbxbaCpiLiJnM2soPNT1GlpHSy
vDKG9N4vfLJcPr0hxJBV0/U6at/YEwC1ErJwUQBgEowihaNnvcKjHQlXkINM/EAi
ig6g+YhG+/ViflbyCb2+TyeGixx7wbphYYeILcbyog2dTMUODRdbMvIUzo4ZKtlk
omxkob19hO7BIz260VBY6QjWD47/F+vZQCNSPyj7ZdMfeCqsvrAO0R52n5ul0OKM
Qyi3/RJU6mDiYxeEb4I0svpvfS3elgAJalZWfdqcWhWfQSBHjmyIzXRC4aJOdN6t
gXGYTCC0sq/0F7HjaGSSB4HZbz8aWhu1PkmnGm+tcPe3axs/Oyc+34NIN+Q=
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


resource "azurerm_arc_kubernetes_cluster" "import" {
  name                         = azurerm_arc_kubernetes_cluster.test.name
  resource_group_name          = azurerm_arc_kubernetes_cluster.test.resource_group_name
  location                     = azurerm_arc_kubernetes_cluster.test.location
  agent_public_key_certificate = azurerm_arc_kubernetes_cluster.test.agent_public_key_certificate

  identity {
    type = "SystemAssigned"
  }
}
