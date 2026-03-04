# frozen_string_literal: true

require "dotenv"
require "fileutils"

module Abobrinator
  class Config
    REQUIRED_VARS = %w[
      GEMINI_API_KEY
      GEMINI_MODEL
      JEKYLL_POSTS_DIR
      JEKYLL_DRAFTS_DIR
      JEKYLL_TRANSCRIPTION_DIR
      TOMATEXTOR_NEW_DIR
      TOMATEXTOR_HISTORY_DIR
    ].freeze

    attr_reader :gemini_api_key, :gemini_model,
                :posts_dir, :drafts_dir, :transcription_dir,
                :prompt_file, :new_dir, :history_dir,
                :timezone_offset

    def self.load!
      Dotenv.load
      new
    end

    def initialize
      validate!

      @gemini_api_key   = ENV["GEMINI_API_KEY"]
      @gemini_model     = ENV["GEMINI_MODEL"]
      @posts_dir        = ENV["JEKYLL_POSTS_DIR"]
      @drafts_dir       = ENV["JEKYLL_DRAFTS_DIR"]
      @transcription_dir = ENV["JEKYLL_TRANSCRIPTION_DIR"]
      
      @prompt_file      = File.expand_path("../../data/ai_persona.md", __dir__)
      
      @new_dir          = ENV["TOMATEXTOR_NEW_DIR"]
      @history_dir      = ENV["TOMATEXTOR_HISTORY_DIR"]
      @timezone_offset  = ENV.fetch("TIMEZONE_OFFSET", "-0400")
    end

    def ensure_directories!
      FileUtils.mkdir_p(posts_dir)
      FileUtils.mkdir_p(drafts_dir)
      FileUtils.mkdir_p(transcription_dir)
      FileUtils.mkdir_p(new_dir)
      FileUtils.mkdir_p(history_dir)
    end

    def output_dir(draft:)
      draft ? drafts_dir : posts_dir
    end

    private

    def validate!
      missing = REQUIRED_VARS.reject { |v| ENV[v] && !ENV[v].empty? }
      return if missing.empty?

      raise Abobrinator::Error,
            "[ABOBRINATOR] ERRO: Variáveis faltando no .env: #{missing.join(', ')}"
    end
  end
end
