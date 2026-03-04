# frozen_string_literal: true

require_relative "abobrinator/version"

module Abobrinator
  class Error < StandardError; end
end

require_relative "abobrinator/config"
require_relative "abobrinator/consolidator"
require_relative "abobrinator/gemini_client"
require_relative "abobrinator/post_writer"
require_relative "abobrinator/file_manager"
require_relative "abobrinator/cli"
