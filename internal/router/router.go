package router

import (
	"strings"

	"stormmastermux/internal/backend"
	"stormmastermux/internal/config"
)

type Router struct {
	StormBackend *backend.Backend
	MasterBackend *backend.Backend

	StormDomain string
	MasterDomain string
}

func New(cfg *config.Config) *Router {
	return &Router{
		StormBackend: &backend.Backend{
			Address: cfg.StormDNS.Backend,
		},
		MasterBackend: &backend.Backend{
			Address: cfg.MasterDNS.Backend,
		},
		StormDomain: strings.ToLower(cfg.StormDNS.Domain),
		MasterDomain: strings.ToLower(cfg.MasterDNS.Domain),
	}
}

func (r *Router) Select(qname string) *backend.Backend {
	qname = strings.ToLower(qname)

	if strings.HasSuffix(qname, r.StormDomain) {
		return r.StormBackend
	}

	if strings.HasSuffix(qname, r.MasterDomain) {
		return r.MasterBackend
	}

	return nil
}