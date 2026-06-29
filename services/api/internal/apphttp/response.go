package apphttp

import "github.com/gin-gonic/gin"

type ErrorDetail struct {
	Field   string `json:"field,omitempty"`
	Message string `json:"message"`
}

type PaginationMeta struct {
	Page       int  `json:"page"`
	PerPage    int  `json:"per_page"`
	Total      int  `json:"total"`
	TotalPages int  `json:"total_pages"`
	HasNext    bool `json:"has_next"`
	HasPrev    bool `json:"has_prev"`
}

func Paginated(c *gin.Context, message string, data any, meta PaginationMeta) {
	c.JSON(200, gin.H{
		"success": true,
		"message": message,
		"data":    data,
		"meta":    meta,
	})
}

type ErrorBody struct {
	Code    string        `json:"code"`
	Details []ErrorDetail `json:"details,omitempty"`
}

func OK(c *gin.Context, message string, data any) {
	c.JSON(200, gin.H{
		"success": true,
		"message": message,
		"data":    data,
		"meta":    nil,
	})
}

func Created(c *gin.Context, message string, data any) {
	c.JSON(201, gin.H{
		"success": true,
		"message": message,
		"data":    data,
		"meta":    nil,
	})
}

func Accepted(c *gin.Context, message string, data any) {
	c.JSON(202, gin.H{
		"success": true,
		"message": message,
		"data":    data,
		"meta":    nil,
	})
}

func Fail(c *gin.Context, status int, message string, code string, details []ErrorDetail) {
	c.JSON(status, gin.H{
		"success": false,
		"message": message,
		"error": ErrorBody{
			Code:    code,
			Details: details,
		},
		"meta": nil,
	})
}
