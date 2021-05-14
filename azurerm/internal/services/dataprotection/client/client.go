package client

import (
	"github.com/Azure/azure-sdk-for-go/services/dataprotection/mgmt/2021-01-01/dataprotection"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/common"
)

type Client struct {
	BackupVaultClient    *dataprotection.BackupVaultsClient
	BackupPolicyClient   *dataprotection.BackupPoliciesClient
	BackupInstanceClient *dataprotection.BackupInstancesClient
}

func NewClient(o *common.ClientOptions) *Client {
	backupVaultClient := dataprotection.NewBackupVaultsClientWithBaseURI(o.ResourceManagerEndpoint, o.SubscriptionId)
	o.ConfigureClient(&backupVaultClient.Client, o.ResourceManagerAuthorizer)

	backupPolicyClient := dataprotection.NewBackupPoliciesClientWithBaseURI(o.ResourceManagerEndpoint, o.SubscriptionId)
	o.ConfigureClient(&backupPolicyClient.Client, o.ResourceManagerAuthorizer)

	backupInstanceClient := dataprotection.NewBackupInstancesClientWithBaseURI(o.ResourceManagerEndpoint, o.SubscriptionId)
	o.ConfigureClient(&backupInstanceClient.Client, o.ResourceManagerAuthorizer)

	return &Client{
		BackupVaultClient:    &backupVaultClient,
		BackupPolicyClient:   &backupPolicyClient,
		BackupInstanceClient: &backupInstanceClient,
	}
}
