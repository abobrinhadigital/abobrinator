# frozen_string_literal: true

require "thor"

module Abobrinator
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc "process", "Processa novas transcrições no diretório configurado via GEMINI"
    method_option :rascunho,
                  type: :boolean,
                  aliases: "-r",
                  desc: "Salva os posts na pasta _drafts ao invés de _posts",
                  default: false
    def process
      config = Abobrinator::Config.load!
      config.ensure_directories!
      
      system_instruction = File.read(config.prompt_file, encoding: "utf-8")
      
      file_manager = Abobrinator::FileManager.new(config)
      new_files    = file_manager.new_transcription_files

      if new_files.empty?
        puts "[ABOBRINATOR] AVISO: Nenhum arquivo .txt encontrado em: #{config.new_dir}"
        return
      end

      mode = options[:rascunho] ? "RASCUNHO" : "POST"
      puts "\n[ABOBRINATOR] Operação [#{mode}] para pasta: #{config.new_dir}"
      puts "[ABOBRINATOR] Consolidando #{new_files.size} arquivos via API Gemini..."

      consolidator = Abobrinator::Consolidator.new(new_files)

      # A Payload pronta pro Gemini
      payload = consolidator.gemini_payload

      client = Abobrinator::GeminiClient.new(
        api_key: config.gemini_api_key,
        model:   config.gemini_model
      )

      # Mágica acontece (bate na API via net/http)
      generated_content = client.generate(
        system_instruction: system_instruction,
        content: payload
      )

      # Trata a resposta: força data, cria slugs, salva post MD e TXT asset
      writer = Abobrinator::PostWriter.new(
        config: config,
        file_manager: file_manager,
        consolidator: consolidator,
        generated_text: generated_content,
        draft: options[:rascunho]
      )

      writer.process!
    rescue StandardError => e
      puts "\n[ABOBRINATOR] ERRO FATAL: #{e.class} - #{e.message}"
      puts e.backtrace if ENV["DEBUG"]
      exit 1
    end
    
    # Faz 'process' ser o comando default se rodar apenas `abobrinator`
    default_task :process
  end
end
