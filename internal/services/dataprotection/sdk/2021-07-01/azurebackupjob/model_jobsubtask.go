package azurebackupjob

type JobSubTask struct {
	AdditionalDetails *map[string]string `json:"additionalDetails,omitempty"`
	TaskId            int64              `json:"taskId"`
	TaskName          string             `json:"taskName"`
	TaskProgress      *string            `json:"taskProgress,omitempty"`
	TaskStatus        string             `json:"taskStatus"`
}
