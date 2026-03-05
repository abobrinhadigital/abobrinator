# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Abobrinator
  # Cliente simples para a Hugging Face Inference API focado em Geração de Imagens
  class HuggingFaceClient
    attr_reader :model

    def initialize(api_key:, model:)
      @api_key = api_key
      @model   = model
    end

    def generate_image(prompt:)
      uri = URI(@model)

      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{@api_key}"
      request["Content-Type"] = "application/json"
      # A Hugging Face Inference API aceita parâmetros adicionais como width e height
      # Vamos usar 1024x576 (16:9) para um formato perfeito de capa de blog
      payload = {
        "inputs" => prompt,
        "parameters" => {
          "width" => 1024,
          "height" => 576
        }
      }
      request.body = JSON.generate(payload)

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end

      parse_image_response(response)
    rescue SocketError, EOFError, Net::ReadTimeout => e
      raise Abobrinator::Error, "[HUGGINGFACE] Erro de conexão térmica: #{e.message}"
    end

    private

    def parse_image_response(response)
      unless response.is_a?(Net::HTTPSuccess)
        raise Abobrinator::Error,
              "[HUGGINGFACE] Erro HTTP na geração de imagem #{response.code}: #{format_error_message(response)}"
      end

      # A Hugging Face devolve diretamente os BYTES da imagem quando é um modelo Text-to-Image!
      response.body
    end

    def format_error_message(response)
      begin
        parsed = JSON.parse(response.body)
        parsed.dig("error") || response.body.strip
      rescue JSON::ParserError
        response.body.strip
      end
    end
  end
end
