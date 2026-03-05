# frozen_string_literal: true

require "thor"

module Abobrinator
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc "models", "Lista todos os modelos Gemini disponíveis para a sua API Key"
    def models
      config = Abobrinator::Config.load!
      
      client = Abobrinator::GeminiClient.new(
        api_key: config.gemini_api_key,
        model:   config.gemini_model # O modelo não importa pro request de listagem
      )
      
      puts "\n[GEMINI] Buscando modelos liberados para sua chave..."
      
      available_models = client.models
      
      if available_models.empty?
        puts "Nenhum modelo encontrado ou erro na leitura."
      else
        puts "Modelos disponíveis:"
        available_models.each do |model|
          puts "  - #{model[:name]} (Suporta: #{model[:actions]})"
        end
      end
    rescue StandardError => e
      puts "\n[ABOBRINATOR] ERRO FATAL: #{e.class} - #{e.message}"
      puts e.backtrace if ENV["DEBUG"]
      exit 1
    end

    desc "process", "Processa novas transcrições no diretório configurado via GEMINI"
    method_option :draft,
                  type: :boolean,
                  aliases: "-d",
                  desc: "Salva os posts na pasta _drafts ao invés de _posts",
                  default: false
    method_option :no_image,
                  type: :boolean,
                  desc: "Desliga a funcionalidade nativa do Photator de gerar imagem de capa",
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

      mode = options[:draft] ? "DRAFT" : "POST"
      puts "\n[ABOBRINATOR] Operação [#{mode}] para pasta: #{config.new_dir}"
      puts "[ABOBRINATOR] Consolidando #{new_files.size} arquivos via API Gemini..."

      consolidator = Abobrinator::Consolidator.new(new_files)

      # A Payload pronta pro Gemini
      payload = consolidator.gemini_payload

      client = Abobrinator::GeminiClient.new(
        api_key: config.gemini_api_key,
        model:   config.gemini_model,
        image_model: config.gemini_image_model
      )

      # Mágica acontece (bate na API via net/http)
      generated_content = client.generate(
        system_instruction: system_instruction,
        content: payload
      )

      # Trata a resposta: força data, cria slugs, salva post MD e TXT asset e IMAGEM
      writer = Abobrinator::PostWriter.new(
        config: config,
        file_manager: file_manager,
        consolidator: consolidator,
        generated_text: generated_content,
        draft: options[:draft],
        no_image: options[:no_image]
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
