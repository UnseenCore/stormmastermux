package server

import (
	"log"
	"net"
	"time"

	"github.com/miekg/dns"

	"stormmastermux/internal/config"
	"stormmastermux/internal/router"
)

type Server struct {
	Router *router.Router
	Config *config.Config
}

func New(cfg *config.Config, r *router.Router) *Server {
	return &Server{
		Router: r,
		Config: cfg,
	}
}

func (s *Server) Start() error {
	dns.HandleFunc(".", s.handleDNS)

	udpServer := &dns.Server{
		Addr:         s.Config.Server.UDPListen,
		Net:          "udp",
		ReadTimeout:  time.Duration(s.Config.Server.ReadTimeout) * time.Second,
		WriteTimeout: time.Duration(s.Config.Server.WriteTimeout) * time.Second,
	}

	tcpServer := &dns.Server{
		Addr:         s.Config.Server.TCPListen,
		Net:          "tcp",
		ReadTimeout:  time.Duration(s.Config.Server.ReadTimeout) * time.Second,
		WriteTimeout: time.Duration(s.Config.Server.WriteTimeout) * time.Second,
	}

	go func() {
		log.Printf("UDP server listening on %s", s.Config.Server.UDPListen)

		if err := udpServer.ListenAndServe(); err != nil {
			log.Fatal(err)
		}
	}()

	log.Printf("TCP server listening on %s", s.Config.Server.TCPListen)

	return tcpServer.ListenAndServe()
}

func (s *Server) handleDNS(w dns.ResponseWriter, r *dns.Msg) {
	if len(r.Question) == 0 {
		return
	}

	qname := r.Question[0].Name

	backend := s.Router.Select(qname)
	if backend == nil {
		msg := new(dns.Msg)
		msg.SetReply(r)
		msg.Rcode = dns.RcodeNameError

		_ = w.WriteMsg(msg)
		return
	}

	var (
		resp *dns.Msg
		err  error
	)

	if _, ok := w.RemoteAddr().(*net.TCPAddr); ok {
		resp, err = backend.ExchangeTCP(r)
	} else {
		resp, err = backend.ExchangeUDP(r)
	}

	if err != nil {
		log.Printf("backend error: %v", err)

		msg := new(dns.Msg)
		msg.SetReply(r)
		msg.Rcode = dns.RcodeServerFailure

		_ = w.WriteMsg(msg)
		return
	}

	_ = w.WriteMsg(resp)
}