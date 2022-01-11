# encoding: utf-8
require_relative "../spec_helper"
require "logstash/devutils/rspec/shared_examples"
require "stud/temporary"
require "tempfile"

describe LogStash::Inputs::Unix do

  let(:tempfile)   { Tempfile.new("/tmp/foo") }

  it "should register without errors" do
    plugin = LogStash::Plugin.lookup("input", "unix").new({ "path" => tempfile.path, "force_unlink" => true })
    expect { plugin.register }.to_not raise_error
  end

  describe "when mode is client" do

    let(:mode) { "client" }

    context "if socket_not_present_retry_interval_seconds is out of bounds" do
      it "should fallback to default value" do
        plugin = LogStash::Plugin.lookup("input", "unix").new({ "path" => tempfile.path, "force_unlink" => true, "mode" => mode, "socket_not_present_retry_interval_seconds" => -1 })
        plugin.register
        expect(plugin.instance_variable_get(:@socket_not_present_retry_interval_seconds)).to be 5
      end
    end
  end

  describe "when interrupting the plugin" do

    context "#server" do
      it_behaves_like "an interruptible input plugin" do
        let(:config) { { "path" => tempfile.path, "force_unlink" => true } }
      end
    end

    context "#client" do
      let(:tempfile)    { "/tmp/sock#{rand(65532)}" }
      let(:config)      { { "path" => tempfile, "mode" => "client" } }
      let(:unix_socket) { UnixSocketHelper.new.new_socket(tempfile) }
      let(:run_forever) { true }

      before(:each) do
        unix_socket.loop(run_forever)
      end

      after(:each) do
        unix_socket.close
      end

      context "when the unix socket has data to be read" do
        it_behaves_like "an interruptible input plugin" do
          let(:run_forever) { true }
        end
      end

      context "when the unix socket has no data to be read" do
        it_behaves_like "an interruptible input plugin" do
          let(:run_forever) { false }
        end
      end
    end

  end
end
