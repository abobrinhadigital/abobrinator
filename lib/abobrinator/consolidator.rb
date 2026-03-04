# frozen_string_literal: true

module Abobrinator
  # Responsável por ler, ordenar e consolidar os arquivos .txt de entrada.
  # O resultado é uma string formatada pronta para ser enviada ao Gemini,
  # e uma cópia do conteúdo bruto para arquivamento.
  class Consolidator
    attr_reader :files

    def initialize(files)
      @files = files
    end

    def any?
      @files.any?
    end

    # Retorna o texto formatado para envio à API (com identificadores de parte)
    def gemini_payload
      @files.each_with_index.map do |filepath, i|
        filename = File.basename(filepath)
        content  = File.read(filepath, encoding: "utf-8")
        "--- PARTE #{i + 1} (#{filename}) ---\n#{content}"
      end.join("\n")
    end

    # Retorna o conteúdo bruto sequencial para salvar como asset
    def raw_content
      @files.map do |filepath|
        filename = File.basename(filepath)
        content  = File.read(filepath, encoding: "utf-8")
        "--- ORIGEM: #{filename} ---\n#{content}"
      end.join("\n")
    end

  end
end
