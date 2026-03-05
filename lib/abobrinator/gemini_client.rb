# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require "base64"

module Abobrinator
  # Encapsula a comunicação com a API REST do Google Gemini.
  # Usa net/http da stdlib — sem gems externas, sem surpresas do Murphy.
  class GeminiClient
    API_BASE = "https://generativelanguage.googleapis.com/v1beta".freeze

    def initialize(api_key:, model:, image_model: nil)
      @api_key     = api_key
      @model       = model
      @image_model = image_model
    end

    # Envia o conteúdo com a instrução de sistema e retorna o texto gerado.
    def generate(system_instruction:, content:)
      uri  = build_generate_uri(@model)
      body = build_body(system_instruction: system_instruction, content: content)

      response = post_request(uri, body)
      parse_generate_response(response)
    end

    # Envia o prompt de imagem para a API e retorna o binário da imagem (PNG/JPEG)
    def generate_image(prompt:)
      unless @image_model
        raise Abobrinator::Error, "[GEMINI] Model de imagem não configurado no client."
      end

      uri  = build_generate_uri(@image_model)
      body = build_image_body(prompt: prompt)

      response = post_request(uri, body)
      parse_image_response(response)
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

    def build_generate_uri(model)
      clean_model = model.sub(%r{\Amodels/}, "")
      path = "#{API_BASE}/models/#{clean_model}:generateContent?key=#{@api_key}"
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

    def build_image_body(prompt:)
      {
        contents: [
          {
            role: "user",
            parts: [{ text: prompt }]
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
              "[GEMINI] Erro HTTP #{response.code}: #{format_error_message(response)}"
      end

      data = JSON.parse(response.body)
      data.dig("candidates", 0, "content", "parts", 0, "text") ||
        raise(Abobrinator::Error, "[GEMINI] Resposta inesperada: #{response.body}")
    end

    def parse_image_response(response)
      unless response.is_a?(Net::HTTPSuccess)
        raise Abobrinator::Error,
              "[GEMINI] Erro HTTP na geração de imagem #{response.code}: #{format_error_message(response)}"
      end

      data = JSON.parse(response.body)
      base64_data = data.dig("candidates", 0, "content", "parts", 0, "inlineData", "data")
      
      unless base64_data
        raise Abobrinator::Error, "[GEMINI] A API não retornou inlineData.data na resposta."
      end

      # Decode da string base64 para binário
      Base64.decode64(base64_data)
    end

    def format_error_message(response)
      begin
        parsed = JSON.parse(response.body)
        parsed.dig("error", "message") || response.body.strip
      rescue JSON::ParserError
        response.body.strip
      end
    end
  end
end
