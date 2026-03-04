# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module Abobrinator
  # Encapsula a comunicação com a API REST do Google Gemini.
  # Usa net/http da stdlib — sem gems externas, sem surpresas do Murphy.
  class GeminiClient
    API_BASE = "https://generativelanguage.googleapis.com/v1beta".freeze

    def initialize(api_key:, model:)
      @api_key = api_key
      @model   = model
    end

    # Envia o conteúdo com a instrução de sistema e retorna o texto gerado.
    def generate(system_instruction:, content:)
      uri  = build_generate_uri
      body = build_body(system_instruction: system_instruction, content: content)

      response = post_request(uri, body)
      parse_generate_response(response)
    end

    # Consulta a API para listar os modelos liberados para a chave
    def models
      uri = URI.parse("#{API_BASE}/models?key=#{@api_key}")
      
      response = get_request(uri)
      parse_models_response(response)
    end

    private

    def get_request(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 30
      
      request = Net::HTTP::Get.new(uri.request_uri)
      http.request(request)
    end

    def parse_models_response(response)
      unless response.is_a?(Net::HTTPSuccess)
        raise Abobrinator::Error,
              "[GEMINI] Erro HTTP #{response.code}: #{response.body}"
      end
      
      data = JSON.parse(response.body)
      
      (data["models"] || []).map do |model|
        {
          name: model["name"],
          actions: (model["supportedGenerationMethods"] || []).join(", ")
        }
      end
    end

    def build_generate_uri
      path = "#{API_BASE}/models/#{model_name}:generateContent?key=#{@api_key}"
      URI.parse(path)
    end

    # Remove prefixo "models/" se presente, pois ele já está no path base
    def model_name
      @model.sub(%r{\Amodels/}, "")
    end

    def build_body(system_instruction:, content:)
      {
        system_instruction: {
          parts: [{ text: system_instruction }]
        },
        contents: [
          {
            role: "user",
            parts: [{ text: content }]
          }
        ]
      }
    end

    def post_request(uri, body)
      http          = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl  = true
      http.read_timeout = 120

      request               = Net::HTTP::Post.new(uri.request_uri)
      request["Content-Type"] = "application/json"
      request.body          = JSON.generate(body)

      http.request(request)
    end

    def parse_generate_response(response)
      unless response.is_a?(Net::HTTPSuccess)
        raise Abobrinator::Error,
              "[GEMINI] Erro HTTP #{response.code}: #{response.body}"
      end

      data = JSON.parse(response.body)
      data.dig("candidates", 0, "content", "parts", 0, "text") ||
        raise(Abobrinator::Error, "[GEMINI] Resposta inesperada: #{response.body}")
    end
  end
end
