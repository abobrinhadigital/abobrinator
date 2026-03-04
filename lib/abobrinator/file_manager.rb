# frozen_string_literal: true

require "fileutils"

module Abobrinator
  # Abstração de I/O para manter a arquitetura purista e idêntica ao Tomatextor
  class FileManager
    def initialize(config)
      @config = config
    end

    def new_transcription_files
      Dir.glob(File.join(@config.new_dir, "*.txt")).sort
    end

    def archive_originals!(files)
      files.each do |filepath|
        filename = File.basename(filepath)
        dest     = File.join(@config.history_dir, filename)
        
        FileUtils.mv(filepath, dest)
        puts "[ABOBRINATOR] 📁 Arquivo original arquivado: #{filename}"
      end
    end

    def save_markdown!(base_name:, md_content:, is_draft:)
      dir = @config.output_dir(draft: is_draft)
      path = File.join(dir, "#{base_name}.md")
      
      File.write(path, md_content)
      puts "[ABOBRINATOR] ✅ SUCESSO! Post consolidado salvo em: #{path}"
      path
    end

    def save_asset!(base_name:, raw_content:, is_draft:)
      dir = is_draft ? @config.drafts_dir : @config.transcription_dir
      path = File.join(dir, "#{base_name}.txt")

      File.write(path, raw_content)
      puts "[ABOBRINATOR] ✅ Transcrição consolidada salva em: #{path}"
      path
    end
  end
end
