# The main file of the collector

require 'rcs-common/path_utils'

# relatives
require_release 'rcs-collector/config'
require_release 'rcs-collector/db'

#require_relative 'statistics'
require_relative 'events'

# from RCS::Common
require 'rcs-common/trace'
require 'rcs-common/component'

# from System
require 'yaml'

module RCS
  module Controller
    # namespace aliasing
    DB = RCS::Collector::DB
    Config = RCS::Collector::Config

    class Application
      include RCS::Component

      component :controller, name: "RCS Network Controller"

      # the main of the collector
      def run(options)
        run_with_rescue do
          trace_setup

          # config file parsing
          return 1 unless Config.instance.load_from_file

          establish_database_connection(wait_until_connected: true)

          # be sure to have the network certificate
          database.get_network_cert(Config.instance.file('rcs-network')) unless File.exist? Config.instance.file('rcs-network.pem')

          # enter the main loop (hopefully will never exit from it)
          Events.new.setup
        end
      end
    end # Application::
  end # Controller::
end # RCS::
