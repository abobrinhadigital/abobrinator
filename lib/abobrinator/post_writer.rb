# frozen_string_literal: true

require "fileutils"
require "date"
require "json"

module Abobrinator
  # Responsável por processar a resposta do Gemini, forçar a data correta,
  # extrair o nome base (slug + data) e salvar o .md e o .txt (Simetria Absoluta)
  class PostWriter
    attr_reader :saved_md_path, :saved_txt_path

    def initialize(config:, file_manager:, consolidator:, generated_text:, draft:)
      @config         = config
      @file_manager   = file_manager
      @consolidator   = consolidator
      @generated_text = generated_text
      @draft          = draft
    end

    def process!
      parse_gemini_output!
      extract_base_name!
      build_front_matter!
      force_asset_link_symmetry!

      # Finaliza o conteúdo MD
      @md_content = "#{@front_matter}\n\n#{@post_body}"

      save_markdown!
      save_asset!
      archive_originals!
    end

    private

    # Extrai o bloco de JSON do começo da string e separa o corpo do markdown
    def parse_gemini_output!
      # A regex busca pelo bloco ```json ... ``` (multiline) "
      # pegando tudo de dentro para o grupo 1, e o restante do texto para o grupo 2.
      match = @generated_text.match(/```json\s*(.*?)\s*```(.*)/im)
      
      unless match
        raise Abobrinator::Error, "[POST_WRITER] O Gemini não retornou o bloco JSON esperado com os metadados! Volte ao texto bruto ou tente novamente."
      end

      begin
        @metadata  = JSON.parse(match[1])
        @post_body = match[2].strip
      rescue JSON::ParserError => e
        raise Abobrinator::Error, "[POST_WRITER] Falha ao ler o JSON gerado pelo Gemini: #{e.message}"
      end
    end

    def extract_base_name!
      # Puxa o título injetado no metadata (JSON)
      titulo_cru = @metadata["title"] || "caos-consolidado"

      # Normalização: remove acentos e cria o slug (Ruby purista)
      slug = titulo_cru.unicode_normalize(:nfkd).encode("ASCII", replace: "").downcase
      slug.gsub!(/[^a-z0-9]+/, "-")
      slug.gsub!(/\A-+|-+\z/, "") # strip dos hifens nas pontas

      date_str = Time.now.strftime("%Y-%m-%d")

      # Data + os primeiros 45 caracteres do slug
      @base_name = "#{date_str}-#{slug[0..44]}"
    end

    def build_front_matter!
      date_formatted = Time.now.strftime("%Y-%m-%d %H:%M:%S #{@config.timezone_offset}")

      # Montamos o YAML Front Matter do Jekyll na mão, hardcoded com Ruby
      # Isso garante que a IA não vá quebrar as aspas ou a formatação
      @front_matter = <<~YAML
        ---
        layout: post
        title: "#{@metadata['title']}"
        description: "#{@metadata['description']}"
        categories: #{@metadata['categories']}
        author: #{@metadata['author']}
        date: #{date_formatted}
        ---
      YAML
      @front_matter.strip!
    end

    def force_asset_link_symmetry!
      # Substitui a tag limpa do {{ASSET_LINK}} injetada pelo Pollux
      # pelo caminho real garantindo a Simetria Absoluta.
      real_link = "/assets/transcricoes/#{@base_name}.txt"
      @post_body.gsub!("{{ASSET_LINK}}", real_link)
    end

    def save_markdown!
      @saved_md_path = @file_manager.save_markdown!(
        base_name: @base_name,
        md_content: @md_content,
        is_draft: @draft
      )
    end

    def save_asset!
      @saved_txt_path = @file_manager.save_asset!(
        base_name: @base_name,
        raw_content: @consolidator.raw_content,
        is_draft: @draft
      )
    end

    def archive_originals!
      @file_manager.archive_originals!(@consolidator.files)
    end
  end
end
