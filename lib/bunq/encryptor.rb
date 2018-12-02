module Bunq
  class Encryptor
    HEADER_CLIENT_ENCRYPTION_HMAC = 'X-Bunq-Client-Encryption-Hmac'
    HEADER_CLIENT_ENCRYPTION_IV = 'X-Bunq-Client-Encryption-Iv'
    HEADER_CLIENT_ENCRYPTION_KEY = 'X-Bunq-Client-Encryption-Key'
    AES_ENCRYPTION_METHOD = 'aes-256-cbc'
    HMAC_ALGORITHM = 'sha1'

    def initialize(server_public_key)
      fail ArgumentError.new('server_public_key is mandatory') unless server_public_key

      @server_public_key = OpenSSL::PKey::RSA.new(server_public_key)
    end

    def encrypt(body)
      headers = {}

      iv, key, encrypted_body = encrypt_body(body)

      headers[HEADER_CLIENT_ENCRYPTION_IV] = Base64.strict_encode64(iv)

      encrypted_key = server_public_key.public_encrypt(key)
      headers[HEADER_CLIENT_ENCRYPTION_KEY] = Base64.strict_encode64(encrypted_key)

      digest = hmac(key, iv + encrypted_body)
      headers[HEADER_CLIENT_ENCRYPTION_HMAC] = Base64.strict_encode64(digest)

      [encrypted_body, headers]
    end

    private

    attr_reader :server_public_key

    def encrypt_body(body)
      cipher = OpenSSL::Cipher.new(AES_ENCRYPTION_METHOD)
      cipher.encrypt

      iv = cipher.random_iv
      key = cipher.random_key

      encrypted_body = cipher.update(body) + cipher.final

      [iv, key, encrypted_body]
    end

    def hmac(key, content)
      hmac = OpenSSL::HMAC.new(key, OpenSSL::Digest.new(HMAC_ALGORITHM))
      hmac << content
      hmac.digest
    end
  end
end
