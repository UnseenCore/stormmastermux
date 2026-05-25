package backend

import (
	"time"

	"github.com/miekg/dns"
)

type Backend struct {
	Address string
	Timeout time.Duration
}

func (b *Backend) ExchangeUDP(msg *dns.Msg) (*dns.Msg, error) {
	client := &dns.Client{
		Net:     "udp",
		Timeout: b.Timeout,
	}

	resp, _, err := client.Exchange(msg, b.Address)
	if err != nil {
		return nil, err
	}

	return resp, nil
}

func (b *Backend) ExchangeTCP(msg *dns.Msg) (*dns.Msg, error) {
	client := &dns.Client{
		Net:     "tcp",
		Timeout: b.Timeout,
	}

	resp, _, err := client.Exchange(msg, b.Address)
	if err != nil {
		return nil, err
	}

	return resp, nil
}