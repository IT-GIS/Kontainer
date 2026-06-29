package modules

import (
	"net/http"

	"github.com/gin-gonic/gin"

	apphttp "container-survey/services/api/internal/apphttp"
)

func Register(v1 *gin.RouterGroup) {
	registerModule(v1.Group("/users"), "users")
	registerModule(v1.Group("/roles"), "roles")
	registerModule(v1.Group("/permissions"), "permissions")
	registerModule(v1.Group("/settings/company-profile"), "company_profile")
	registerModule(v1.Group("/settings/numbering"), "numbering")
	registerModule(v1.Group("/master/checklist-templates"), "checklist_templates")
	registerModule(v1.Group("/eirs"), "eirs")
	registerModule(v1.Group("/audit-logs"), "audit_logs")
	registerModule(v1.Group("/notifications"), "notifications")
	registerModule(v1.Group("/files"), "files")

	v1.GET("/dashboard/admin", notImplemented("dashboard_admin"))
	v1.GET("/dashboard/supervisor", notImplemented("dashboard_supervisor"))
	v1.GET("/dashboard/management", notImplemented("dashboard_management"))
}

func registerModule(group *gin.RouterGroup, module string) {
	group.GET("", notImplemented(module+".list"))
	group.POST("", notImplemented(module+".create"))
	group.GET("/:id", notImplemented(module+".detail"))
	group.PUT("/:id", notImplemented(module+".update"))
	group.DELETE("/:id", notImplemented(module+".delete"))
}

func notImplemented(operation string) gin.HandlerFunc {
	return func(c *gin.Context) {
		apphttp.Fail(c, http.StatusNotImplemented, "Endpoint belum diimplementasikan.", "NOT_IMPLEMENTED", []apphttp.ErrorDetail{
			{Message: operation},
		})
	}
}
