package azurebackupjob

type JobExtendedInfo struct {
	AdditionalDetails      *map[string]string              `json:"additionalDetails,omitempty"`
	BackupInstanceState    *string                         `json:"backupInstanceState,omitempty"`
	DataTransferredInBytes *float64                        `json:"dataTransferredInBytes,omitempty"`
	RecoveryDestination    *string                         `json:"recoveryDestination,omitempty"`
	SourceRecoverPoint     *RestoreJobRecoveryPointDetails `json:"sourceRecoverPoint,omitempty"`
	SubTasks               *[]JobSubTask                   `json:"subTasks,omitempty"`
	TargetRecoverPoint     *RestoreJobRecoveryPointDetails `json:"targetRecoverPoint,omitempty"`
}
