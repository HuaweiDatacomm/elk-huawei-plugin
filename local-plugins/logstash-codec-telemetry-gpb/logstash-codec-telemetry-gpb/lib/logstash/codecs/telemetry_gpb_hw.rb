# encoding: utf-8
#
require "logstash/codecs/base"
require "logstash/namespace"
require 'json'
require 'protocol_buffers'
require 'logger'
require 'base64'
#
# Implementation of a Logstash codec for the Google Protocol Buffer Format(GPB)
# For Telemetry gpb data
#
class LogStash::Codecs::Telemetry_gpb < LogStash::Codecs::Base
  config_name "telemetry_gpb_hw"

  #
  # 'protofiles' specified path for directory holding:
  #
  # .proto files as generated on router, and post-processed
  # .pb.rb generated ruby bindings for the same
  #
  # e.g. protofiles => "/data/proto"
  #
  # If you do not plan to make backward incompatible
  # changes to the .proto file, you can also simply use
  # the full version on this side safe in the knowledge
  # that it will be able to read any subset you wish to
  # generate.
  #
  # In order to generate the Ruby bindings you will need
  # to use a protocol compiler which supports Ruby
  # bindings for proto2 (e.g. ruby-protocol-buffer gem)
  #
  config :protofiles, :validate => :path, :required => true

  public

  def register
    #
    # Initialise the state of the codec. Codec is always cloned from
    # this state.
    #
    # Write error info into file
    log_file = File.open('./logs/telemetry-gpb.log', 'a')
    @file_logger = Logger.new(log_file)
    @file_logger.level = Logger::ERROR
    #
    # Load ruby binding source files for .proto
    #
    Dir.glob(@protofiles + "/*.rb") do |binding_sourcefile|
      dir_and_file = File.absolute_path binding_sourcefile
      @logger.info("Loading ruby source file",
                   :proto_binding_source => dir_and_file)
      begin
        load dir_and_file
      rescue Exception => e
        @logger.warn("Failed to load .proto Ruby binding source",
                     :proto_binding_source => dir_and_file,
                     :exception => e, :stacktrace => e.backtrace)
      end
    end
  end

  # @deprecated
  # deprecated by wangting w30000618 2020/3/4
  def hash_merge_old(clsname, hashdata)
    hash_res = Hash.new
    hashdata.each do |key, value|
      if value.is_a?(Hash)
        tmp = "." + key.to_s
        if clsname.eql?("")
          tmp = key.to_s
        end
        clsname = clsname + tmp
        new_hash_res = hash_merge(clsname, value)
        hash_res = hash_res.merge(new_hash_res)
      else
        if !clsname.eql?("")
          key = clsname + "." + key.to_s
        end
        value.each do |content|
          if content.has_key?(:data)
            data_tmp = Base64.strict_encode64(content[:data])
            @logger.info(data_tmp);
            content[:data] = data_tmp
          end
        end
        hash_res[key] = value
      end
    end
    hash_res
  end

  def hash_merge(clsname, hashdata)
    hash_res = Hash.new
    hashdata.each do |key, value|
      if value.is_a?(Hash)
        tmp = "." + key.to_s
        if clsname.eql?("")
          tmp = key.to_s
        end
        clsname = clsname + tmp
        new_hash_res = hash_merge(clsname, value)
        hash_res = hash_res.merge(new_hash_res)
      else
        if !clsname.eql?("")
          key = clsname + "." + key.to_s
        end
        # add by wangting w30000618 2020/3/4, if value's class not arr, but num; it cannot do .each
        if (!value.is_a?(Array))
          hash_res[key] = value
        else
          value.each do |content|
            if content.has_key?(:data)
              data_tmp = Base64.strict_encode64(content[:data])
              content[:data] = data_tmp
            end
          end
        end
        hash_res[key] = value
      end
    end
    hash_res
  end


  # add by wangting 2020.2.28 start
  def to_hash_with_enum_name(message)
    return nil if message == nil
    return message.is_a?(String) ? message.dup : message unless message.is_a?(::ProtocolBuffers::Message)
    message.fields.select do |tag, field|
      message.value_for_tag?(tag)
    end.inject(Hash.new) do |hash, (tag, field)|
      value = message.value_for_tag(tag)
      # hash[field.name] = value.is_a?(::ProtocolBuffers::RepeatedField) ? value.map { |elem| to_hash(elem) } : to_hash(value)
      if !field.is_a?(::ProtocolBuffers::Field::EnumField)
        hash[field.name] = value.is_a?(::ProtocolBuffers::RepeatedField) ? value.map { |elem| to_hash_with_enum_name(elem) } : to_hash_with_enum_name(value)
      end
      if field.is_a?(::ProtocolBuffers::Field::EnumField)
        if value.is_a?(::ProtocolBuffers::RepeatedField)
          hash[field.name] = []
          value.map { |elem|
            hash[field.name] << field.value_to_name[elem]
          }
        else
          hash[field.name] = field.is_a?(::ProtocolBuffers::Field::EnumField) ? field.value_to_name[value] : value
        end
      end
      hash
    end
  end

  # add by wangting 2020.2.28 end

  public

  def decode(data)

    connection_thread = Thread.current

    @logger.debug? &&
        @logger.debug("Transport passing data down",
                      :thread => connection_thread.to_s,
                      :length => data.length)

    #Huawei Data Decoder
    begin
      hwmsg = Hwtelemetry::Telemetry.new
      # hwmsg_out = hwmsg.parse(data).to_hash   delete by wangting 30000618 2020.2.28
      hwmsg_out = to_hash_with_enum_name(hwmsg.parse(data)) # add by wangting 30000618 2020.2.28
      class_path = hwmsg_out[:sensor_path].split("/")
      moudule_classpre = class_path[0].split(":") #get second class name to create message class
      moudule_class = moudule_classpre[0].split("-")
      moudule_prename = moudule_class[0].capitalize
      module_class_len = moudule_class.length
      moudule_name = ""
      i = 1
      while i < module_class_len
        mod_tmp = moudule_class[i]
        mod_tmp[0] = mod_tmp[0].capitalize
        moudule_name += mod_tmp
        i += 1
      end
      sec_class = moudule_classpre[1].split("-")
      sec_class_len = sec_class.length
      sec_name = ""
      i = 0
      while i < sec_class_len
        sec_tmp = sec_class[i]
        sec_tmp[0] = sec_tmp[0].capitalize
        sec_name += sec_tmp
        i += 1
      end
      classname = moudule_prename + moudule_name + "::" + sec_name
      row_class = classname.split('::').inject(Object) { |n, c| n.const_get c }
      data_gpb = hwmsg_out.delete(:data_gpb)
      data_rows = data_gpb.delete(:row)

      data_rows.each do |row|
        # Map row to appropriate sub-message type and decode.
        row_out = to_hash_with_enum_name(row_class.parse(row[:content]))
        hwmsg_out[:timestamp] = row[:timestamp]
        content_out = Hash.new
        clsname = ""
        content_out = hash_merge(clsname, row_out)
        ev = hwmsg_out.clone
        ev = ev.merge(content_out)
        #yield LogStash::Event.new(JSON.parse(ev.to_json))
        yield LogStash::Event.new(ev)
      end # End of iteration over rows

    rescue Exception => e # Catch Decoder Exception
      msg = "Failed to decode telemetry data"
      @logger.error("Failed to decode telemetry data",
                    :data => data,
                    :exception => e, :stacktrace => e.backtrace)
      @file_logger.error(:msg => msg,
                         :data => data,
                         :exception => e, :stacktrace => e.backtrace)
    end # End of Exception handling

  end

  # def decode

  public

  def encode(event)
    # do nothing on encode for now
    @logger.info("telemetry: no encode facility")
  end

# def encode

end # class LogStash::Codecs::Telemetry_gpb
