require 'erb'

class Template
  include ERB::Util

  def initialize(filename)
    @filename = filename
    @template = File.read(filename)
  end

  def render
    ERB.new(@template).result(binding)
  end

  def save(dir)
    path = File.join(dir, File.basename(@filename, ".erb"))
    File.open(path, "w+") do |f|
      puts "#{path}\n#{render}"
      f.write(render)
    end
  end
end

class MFTemplate < Template
  def initialize(template, version, sha1: "", amis: [])
    super(template)
    @version = version
    @sha1 = sha1
    @amis = amis
  end
end

class ApplySpecTemplate < Template
  def initialize(template, agent_commit)
    super(template)
    @agent_commit = agent_commit
  end
end

class NetworkInterfaceSettingsTemplate < Template
  def initialize(template, address,network,gateway)
    super(template)
    @address = address
    @netmask = network
    @gateway = gateway
  end
end

class AWSPackerJsonTemplate < Template
  def initialize(template, regions, aws_access_key, aws_secret_key,
                 ami_name, deps_url, agent_url)
    super(template)
    @regions = regions
    @aws_access_key = aws_access_key
    @aws_secret_key = aws_secret_key
    @ami_name = ami_name
    @deps_url = deps_url
    @agent_url = agent_url
  end
end
