#!/usr/bin/env ruby
# Generated by the protocol buffer compiler. DO NOT EDIT!

require 'protocol_buffers'

module HuaweiDebug
  # forward declarations
  class Debug < ::ProtocolBuffers::Message; end

  class Debug < ::ProtocolBuffers::Message
    # forward declarations
    class CpuInfos < ::ProtocolBuffers::Message; end
    class ServiceCpuInfos < ::ProtocolBuffers::Message; end
    class MemoryInfos < ::ProtocolBuffers::Message; end
    class ResouceReliability < ::ProtocolBuffers::Message; end
    class BoardResouceStates < ::ProtocolBuffers::Message; end
    class Disk < ::ProtocolBuffers::Message; end

    set_fully_qualified_name "huawei_debug.Debug"

    # nested messages
    class CpuInfos < ::ProtocolBuffers::Message
      # forward declarations
      class CpuInfo < ::ProtocolBuffers::Message; end

      set_fully_qualified_name "huawei_debug.Debug.CpuInfos"

      # nested messages
      class CpuInfo < ::ProtocolBuffers::Message
        set_fully_qualified_name "huawei_debug.Debug.CpuInfos.CpuInfo"

        optional :string, :position, 1
        optional :uint32, :overload_threshold, 2
        optional :uint32, :unoverload_threshold, 3
        optional :uint32, :interval, 4
        optional :uint32, :index, 5
        optional :uint32, :system_cpu_usage, 6
        optional :uint32, :monitor_number, 7
        optional :uint32, :monitor_cycle, 8
        optional :string, :overload_state_change_time, 9
        optional :string, :current_overload_state, 10
      end

      repeated ::HuaweiDebug::Debug::CpuInfos::CpuInfo, :cpu_info, 1
    end

    class ServiceCpuInfos < ::ProtocolBuffers::Message
      # forward declarations
      class ServiceCpuInfo < ::ProtocolBuffers::Message; end

      set_fully_qualified_name "huawei_debug.Debug.ServiceCpuInfos"

      # nested messages
      class ServiceCpuInfo < ::ProtocolBuffers::Message
        set_fully_qualified_name "huawei_debug.Debug.ServiceCpuInfos.ServiceCpuInfo"

        optional :string, :position, 1
        optional :string, :service_name, 2
        optional :uint32, :service_cpu_usage, 3
      end

      repeated ::HuaweiDebug::Debug::ServiceCpuInfos::ServiceCpuInfo, :service_cpu_info, 1
    end

    class MemoryInfos < ::ProtocolBuffers::Message
      # forward declarations
      class MemoryInfo < ::ProtocolBuffers::Message; end

      set_fully_qualified_name "huawei_debug.Debug.MemoryInfos"

      # nested messages
      class MemoryInfo < ::ProtocolBuffers::Message
        set_fully_qualified_name "huawei_debug.Debug.MemoryInfos.MemoryInfo"

        optional :string, :position, 1
        optional :uint32, :overload_threshold, 2
        optional :uint32, :unoverload_threshold, 3
        optional :uint32, :index, 4
        optional :uint32, :os_memory_total, 5
        optional :uint32, :os_memory_use, 6
        optional :uint32, :os_memory_free, 7
        optional :uint32, :os_memory_usage, 8
        optional :uint32, :do_memory_total, 9
        optional :uint32, :do_memory_use, 10
        optional :uint32, :do_memory_free, 11
        optional :uint32, :do_memory_usage, 12
        optional :uint32, :simple_memory_total, 13
        optional :uint32, :simple_memory_use, 14
        optional :uint32, :simple_memory_free, 15
        optional :uint32, :simple_memory_usage, 16
        optional :string, :overload_state_change_time, 17
        optional :string, :current_overload_state, 18
        optional :uint32, :memreli_notice_threshold, 19
        optional :uint32, :memreli_overload_threshold, 20
        optional :uint32, :memreli_exception_threshold, 21
      end

      repeated ::HuaweiDebug::Debug::MemoryInfos::MemoryInfo, :memory_info, 1
    end

    class ResouceReliability < ::ProtocolBuffers::Message
      # forward declarations
      class MemoryReliability < ::ProtocolBuffers::Message; end
      class MemoryReliabilitySwitchoverThreshold < ::ProtocolBuffers::Message; end
      class FlowControlMessageReliability < ::ProtocolBuffers::Message; end

      set_fully_qualified_name "huawei_debug.Debug.ResouceReliability"

      # nested messages
      class MemoryReliability < ::ProtocolBuffers::Message
        set_fully_qualified_name "huawei_debug.Debug.ResouceReliability.MemoryReliability"

        optional :bool, :enable, 1
      end

      class MemoryReliabilitySwitchoverThreshold < ::ProtocolBuffers::Message
        set_fully_qualified_name "huawei_debug.Debug.ResouceReliability.MemoryReliabilitySwitchoverThreshold"

        optional :uint32, :threshold, 1
      end

      class FlowControlMessageReliability < ::ProtocolBuffers::Message
        set_fully_qualified_name "huawei_debug.Debug.ResouceReliability.FlowControlMessageReliability"

        optional :bool, :enable, 1
      end

      optional ::HuaweiDebug::Debug::ResouceReliability::MemoryReliability, :memory_reliability, 1
      optional ::HuaweiDebug::Debug::ResouceReliability::MemoryReliabilitySwitchoverThreshold, :memory_reliability_switchover_threshold, 2
      optional ::HuaweiDebug::Debug::ResouceReliability::FlowControlMessageReliability, :flow_control_message_reliability, 3
    end

    class BoardResouceStates < ::ProtocolBuffers::Message
      # forward declarations
      class BoardResouceState < ::ProtocolBuffers::Message; end

      set_fully_qualified_name "huawei_debug.Debug.BoardResouceStates"

      # nested messages
      class BoardResouceState < ::ProtocolBuffers::Message
        set_fully_qualified_name "huawei_debug.Debug.BoardResouceStates.BoardResouceState"

        optional :string, :position, 1
        optional :uint32, :entity_index, 2
        optional :string, :board_name, 3
        optional :uint32, :cpu_usage, 4
        optional :uint32, :memory_total_size, 5
        optional :uint32, :memory_used_size, 6
        optional :uint32, :memory_usage, 7
      end

      repeated ::HuaweiDebug::Debug::BoardResouceStates::BoardResouceState, :board_resouce_state, 1
    end

    class Disk < ::ProtocolBuffers::Message
      # forward declarations
      class Global < ::ProtocolBuffers::Message; end

      set_fully_qualified_name "huawei_debug.Debug.Disk"

      # nested messages
      class Global < ::ProtocolBuffers::Message
        set_fully_qualified_name "huawei_debug.Debug.Disk.Global"

        optional :uint32, :fault_detect_tolerance_time, 1
      end

      optional ::HuaweiDebug::Debug::Disk::Global, :global, 1
    end

    optional ::HuaweiDebug::Debug::CpuInfos, :cpu_infos, 1
    optional ::HuaweiDebug::Debug::ServiceCpuInfos, :service_cpu_infos, 2
    optional ::HuaweiDebug::Debug::MemoryInfos, :memory_infos, 3
    optional ::HuaweiDebug::Debug::ResouceReliability, :resouce_reliability, 4
    optional ::HuaweiDebug::Debug::BoardResouceStates, :board_resouce_states, 5
    optional ::HuaweiDebug::Debug::Disk, :disk, 6
  end

end
