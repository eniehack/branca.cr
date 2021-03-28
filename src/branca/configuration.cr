require "sodium"
require "./error"

module Branca
  abstract class BaseConfiguration
    abstract def nonce : Sodium::Nonce
    abstract def box : Sodium::Cipher::Aead::XChaCha20Poly1305Ietf
  end

  class Configuration < BaseConfiguration
    getter nonce : Sodium::Nonce
    getter box : Sodium::Cipher::Aead::XChaCha20Poly1305Ietf

    # Creates a nonce, and generates secret key from argument.
    # Also, ttl means to time to live for token.
    def initialize(key : Bytes)
      unless key.bytesize == 32
        raise Branca::Error::InvaildKeySize.new
      else
        @key = Sodium::SecureBuffer.new key
      end
      @box = Sodium::Cipher::Aead::XChaCha20Poly1305Ietf.new @key
      @nonce = Sodium::Nonce.random
    end

    # Creates a secret key, and nonca.
    # Also, ttl means to time to live for token.
    def initialize
      @key = Sodium::SecureBuffer.random(32)
      @box = Sodium::Cipher::Aead::XChaCha20Poly1305Ietf.new @key
      @nonce = Sodium::Nonce.random
    end
  end
end
