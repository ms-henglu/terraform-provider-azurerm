package azurebackupjobs

import "github.com/Azure/go-autorest/autorest"

type AzureBackupJobsClient struct {
	Client  autorest.Client
	baseUri string
}

func NewAzureBackupJobsClientWithBaseURI(endpoint string) AzureBackupJobsClient {
	return AzureBackupJobsClient{
		Client:  autorest.NewClientWithUserAgent(userAgent()),
		baseUri: endpoint,
	}
}
