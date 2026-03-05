# frozen_string_literal: true

require "dotenv"
require "fileutils"

module Abobrinator
  class Config
    REQUIRED_VARS = %w[
      GEMINI_API_KEY
      GEMINI_MODEL
      IMAGE_PROVIDER
      JEKYLL_POSTS_DIR
      JEKYLL_DRAFTS_DIR
      JEKYLL_TRANSCRIPTION_DIR
      JEKYLL_DRAFTS_TRANSCRIPTION_DIR
      JEKYLL_IMAGE_DIR
      JEKYLL_DRAFTS_IMAGE_DIR
      TOMATEXTOR_NEW_DIR
      TOMATEXTOR_HISTORY_DIR
    ].freeze

    attr_reader :gemini_api_key, :gemini_model, :gemini_image_model,
                :image_provider, :huggingface_api_key, :huggingface_image_model,
                :posts_dir, :drafts_dir, :transcription_dir, :drafts_transcription_dir, :image_dir, :drafts_image_dir,
                :prompt_file, :new_dir, :history_dir,
                :timezone_offset

    def self.load!
      Dotenv.load
      new
    end

    def initialize
      validate!

      @gemini_api_key      = ENV.fetch("GEMINI_API_KEY")
      @gemini_model        = ENV.fetch("GEMINI_MODEL")
      @image_provider      = ENV.fetch("IMAGE_PROVIDER")

      if @image_provider == "huggingface"
        @huggingface_api_key = ENV.fetch("HUGGINGFACE_API_KEY") { raise Abobrinator::Error, "[CONFIG] Faltando variável HUGGINGFACE_API_KEY no .env (necessário para provider huggingface)" }
        @huggingface_image_model = ENV.fetch("HUGGINGFACE_IMAGE_MODEL") { raise Abobrinator::Error, "[CONFIG] Faltando variável HUGGINGFACE_IMAGE_MODEL no .env" }
      else
        @gemini_image_model  = ENV.fetch("GEMINI_IMAGE_MODEL") { raise Abobrinator::Error, "[CONFIG] Faltando variável GEMINI_IMAGE_MODEL no .env (necessário para provider gemini)" }
      end

      @posts_dir           = ENV.fetch("JEKYLL_POSTS_DIR")
      @drafts_dir         = ENV["JEKYLL_DRAFTS_DIR"]
      @transcription_dir   = ENV["JEKYLL_TRANSCRIPTION_DIR"]
      @drafts_transcription_dir = ENV["JEKYLL_DRAFTS_TRANSCRIPTION_DIR"]
      @image_dir          = ENV["JEKYLL_IMAGE_DIR"]
      @drafts_image_dir   = ENV["JEKYLL_DRAFTS_IMAGE_DIR"]
      
      @prompt_file      = File.expand_path("../../data/ai_persona.md", __dir__)
      
      @new_dir          = ENV["TOMATEXTOR_NEW_DIR"]
      @history_dir      = ENV["TOMATEXTOR_HISTORY_DIR"]
      @timezone_offset  = ENV.fetch("TIMEZONE_OFFSET", "-0400")
    end

    def ensure_directories!
      FileUtils.mkdir_p(posts_dir)
      FileUtils.mkdir_p(drafts_dir)
      FileUtils.mkdir_p(transcription_dir)
      FileUtils.mkdir_p(drafts_transcription_dir) if drafts_transcription_dir
      FileUtils.mkdir_p(image_dir)
      FileUtils.mkdir_p(drafts_image_dir) if drafts_image_dir
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
