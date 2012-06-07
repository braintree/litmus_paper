require 'spec_helper'

describe LitmusPaper::Dependency::HaproxyBackends do
  run_in_reactor

  module StubHaproxy
    def receive_data(data)
      send_data(<<-DATA)
# pxname,svname,qcur,qmax,scur,smax,slim,stot,bin,bout,dreq,dresp,ereq,econ,eresp,wretr,wredis,status,weight,act,bck,chkfail,chkdown,lastchg,downtime,qlimit,pid,iid,sid,throttle,lbtot,tracked,type,rate,rate_lim,rate_max,check_status,check_code,check_duration,hrsp_1xx,hrsp_2xx,hrsp_3xx,hrsp_4xx,hrsp_5xx,hrsp_other,hanafail,req_rate,req_rate_max,req_tot,cli_abrt,srv_abrt,
stats,FRONTEND,,,0,0,2000,0,0,0,0,0,0,,,,,OPEN,,,,,,,,,1,1,0,,,,0,0,0,0,,,,0,0,0,0,0,0,,0,0,0,,,
stats_backend,BACKEND,0,0,0,0,0,0,0,0,0,0,,0,0,0,0,UP,0,0,0,,0,35,0,,1,2,0,,0,,1,0,,0,,,,0,0,0,0,0,0,,,,,0,0,
yellow,FRONTEND,,,0,0,2000,0,0,0,0,0,0,,,,,OPEN,,,,,,,,,1,3,0,,,,0,0,0,0,,,,,,,,,,,0,0,0,,,
yellow_cluster,node1,0,0,0,0,,0,0,0,,0,,0,0,0,0,UP,1,1,0,0,1,35,35,,1,4,1,,0,,2,0,,0,L4CON,,0,,,,,,,0,,,,0,0,
yellow_cluster,node2,0,0,0,0,,0,0,0,,0,,0,0,0,0,DOWN,1,1,0,0,1,35,35,,1,4,1,,0,,2,0,,0,L4CON,,0,,,,,,,0,,,,0,0,
yellow_cluster,node3,0,0,0,0,,0,0,0,,0,,0,0,0,0,DOWN,1,1,0,0,1,34,34,,1,4,2,,0,,2,0,,0,L4CON,,0,,,,,,,0,,,,0,0,
yellow_cluster,BACKEND,0,0,0,0,0,0,0,0,0,0,,0,0,0,0,UP,0,0,0,,1,34,34,,1,4,0,,0,,1,0,,0,,,,,,,,,,,,,,0,0,
orange,FRONTEND,,,0,0,2000,0,0,0,0,0,0,,,,,OPEN,,,,,,,,,1,5,0,,,,0,0,0,0,,,,,,,,,,,0,0,0,,,
orange_cluster,orange1,0,0,0,0,,0,0,0,,0,,0,0,0,0,DOWN,1,1,0,0,0,35,0,,1,6,1,,0,,2,0,,0,L4OK,,5,,,,,,,0,,,,0,0,
orange_cluster,orange2,0,0,0,0,,0,0,0,,0,,0,0,0,0,DOWN,1,1,0,0,0,35,0,,1,6,1,,0,,2,0,,0,L4OK,,5,,,,,,,0,,,,0,0,
orange_cluster,BACKEND,0,0,0,0,0,0,0,0,0,0,,0,0,0,0,DOWN,1,1,0,,0,35,0,,1,6,0,,0,,1,0,,0,,,,,,,,,,,,,,0,0,

      DATA
    end
  end

  describe "available?" do
    around(:each) do |spec|
      begin
        EM.start_unix_domain_server("/tmp/haproxy.#{Process.pid}", StubHaproxy)
        spec.run
      ensure
        FileUtils.rm("/tmp/haproxy.#{Process.pid}")
      end
    end

    it "is available if at least one backend is up" do
      haproxy = LitmusPaper::Dependency::HaproxyBackends.new("/tmp/haproxy.#{Process.pid}", "yellow_cluster")
      haproxy.should be_available
    end

    it "returns 0 if no nodes are available" do
      haproxy = LitmusPaper::Dependency::HaproxyBackends.new("/tmp/haproxy.#{Process.pid}", "orange_cluster")
      haproxy.should_not be_available
    end
  end
end

