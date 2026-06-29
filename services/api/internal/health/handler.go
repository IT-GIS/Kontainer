package health

import (
	"time"

	"github.com/gin-gonic/gin"

	apphttp "container-survey/services/api/internal/apphttp"
	"container-survey/services/api/internal/config"
)

func Register(group *gin.RouterGroup, cfg config.Config) {
	group.GET("", func(c *gin.Context) {
		apphttp.OK(c, "API sehat.", gin.H{
			"app":         cfg.AppName,
			"environment": cfg.Environment,
			"time":        time.Now().UTC().Format(time.RFC3339),
		})
	})
}
