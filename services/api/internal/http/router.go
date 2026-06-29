package http

import (
	"container-survey/services/api/internal/database"
	"log/slog"

	"github.com/gin-gonic/gin"

	"container-survey/services/api/internal/auth"
	"container-survey/services/api/internal/config"
	"container-survey/services/api/internal/finance"
	"container-survey/services/api/internal/health"
	"container-survey/services/api/internal/jobs"
	"container-survey/services/api/internal/masterdata"
	"container-survey/services/api/internal/middleware"
	"container-survey/services/api/internal/modules"
	"container-survey/services/api/internal/reviews"
	"container-survey/services/api/internal/surveyor"
)

func NewRouter(cfg config.Config, logger *slog.Logger, pool *database.Pool) *gin.Engine {
	if cfg.Environment == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	router := gin.New()
	router.Use(gin.Recovery())
	router.Use(middleware.RequestID())
	router.Use(middleware.AccessLog(logger))
	router.Use(middleware.CORS(cfg.AllowedWebOrigins))

	health.Register(router.Group("/health"), cfg)

	authRepo := auth.NewMySQLRepository(pool)
	tokenManager := auth.NewTokenManager(cfg)
	authService := auth.NewService(authRepo, tokenManager)
	authHandler := auth.NewHandler(authService)
	requireAuth := middleware.RequireAuth(authService)

	v1 := router.Group("/api/v1")
	authHandler.Register(v1.Group("/auth"), requireAuth)
	v1.GET("/me", requireAuth, authHandler.Me)

	protected := v1.Group("")
	protected.Use(requireAuth)

	masterRepo := masterdata.NewRepository(pool)
	masterService := masterdata.NewService(masterRepo)
	masterdata.Register(protected, authService, masterService)

	jobRepo := jobs.NewRepository(pool)
	jobService := jobs.NewService(jobRepo)
	jobs.Register(protected, authService, jobService)

	surveyorRepo := surveyor.NewRepository(pool)
	surveyorService := surveyor.NewService(surveyorRepo)
	surveyor.Register(protected, authService, surveyorService)

	reviewRepo := reviews.NewRepository(pool)
	reviewService := reviews.NewService(reviewRepo)
	reviews.RegisterPublic(v1.Group("/public"), reviewService)
	reviews.Register(protected, authService, reviewService)

	financeRepo := finance.NewRepository(pool)
	financeService := finance.NewService(financeRepo)
	finance.Register(protected, authService, financeService)
	modules.Register(protected)

	return router
}
