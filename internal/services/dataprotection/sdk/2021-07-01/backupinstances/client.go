package backupinstances

import "github.com/Azure/go-autorest/autorest"

type BackupInstancesClient struct {
	Client  autorest.Client
	baseUri string
}

func NewBackupInstancesClientWithBaseURI(endpoint string) BackupInstancesClient {
	return BackupInstancesClient{
		Client:  autorest.NewClientWithUserAgent(userAgent()),
		baseUri: endpoint,
	}
}
