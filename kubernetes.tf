# Azure Resource Group for AKS Cluster ## 
resource "azurerm_resource_group" "terraform" {
    name     = var.resource_group_name
    location = var.location
}

# egress IP
resource "azurerm_public_ip" "aks_egress_ip" {
  name                = var.aks_eip_name
  resource_group_name = azurerm_resource_group.terraform.name
  location            = azurerm_resource_group.terraform.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.aks_eip_name
}

# AKS Cluster ## 
resource "azurerm_kubernetes_cluster" "aks-terraform" {
   name                = var.cluster_name
   resource_group_name = azurerm_resource_group.terraform.name
   location            = azurerm_resource_group.terraform.location
   dns_prefix          = var.dns_prefix

   linux_profile {
     admin_username = var.admin_username

        ssh_key {
            key_data = file(var.ssh_public_key)
        }
    }

    default_node_pool {
        name            = "tf1"
        node_count      = var.agent_count
        vm_size         = "Standard_D4_v3"
        os_disk_size_gb = 30 
    }

    service_principal {
        client_id     = var.client_id
        client_secret = var.client_secret
    }

    addon_profile {
        oms_agent {
        enabled                    = false
        }
    }

    network_profile {
        network_plugin     = "azure"
        network_policy     = "calico"
        service_cidr       = "10.255.0.0/16"
        dns_service_ip     = "10.255.0.10"
        docker_bridge_cidr = "172.17.0.1/16"
        load_balancer_sku  = "standard"
        load_balancer_profile {
            outbound_ip_address_ids = [ azurerm_public_ip.aks_egress_ip.id ]
            idle_timeout_in_minutes = 120
            }
    }

    tags = var.tags 
}

## Private key for the kubernetes cluster ##
resource "tls_private_key" "key" {
  algorithm   = "RSA"
}

## Save the private key in the local workspace ##
resource "null_resource" "save-key" {
  triggers = {
    key = tls_private_key.key.private_key_pem
  }

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ${path.module}/.ssh
      echo "${tls_private_key.key.private_key_pem}" > ${path.module}/.ssh/id_rsa
      chmod 0600 ${path.module}/.ssh/id_rsa
EOF
  }
}



