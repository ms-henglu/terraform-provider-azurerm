package azurebackupjob

type ExportJobsResult struct {
	BlobSasKey          *string `json:"blobSasKey,omitempty"`
	BlobUrl             *string `json:"blobUrl,omitempty"`
	ExcelFileBlobSasKey *string `json:"excelFileBlobSasKey,omitempty"`
	ExcelFileBlobUrl    *string `json:"excelFileBlobUrl,omitempty"`
}
