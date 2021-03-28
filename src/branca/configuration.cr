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
    getter ttl : UInt64?

    # Creates a nonce, and generates secret key from argument.
    # Also, ttl represents seconds to out date for token from created time.
    def initialize(key : Bytes, ttl : UInt64?)
      unless key.bytesize == 32
        raise Branca::Error::InvaildKeySize.new
      else
        buf_key = Sodium::SecureBuffer.new key
      end
      @box = Sodium::Cipher::Aead::XChaCha20Poly1305Ietf.new buf_key
      @nonce = Sodium::Nonce.random
    end

    # Creates a secret key, and nonce.
    # Also, ttl represents seconds to out date for token from created time.
    def initialize(@ttl : UInt64?)
      key = Sodium::SecureBuffer.random(32)
      @box = Sodium::Cipher::Aead::XChaCha20Poly1305Ietf.new(key)
      @nonce = Sodium::Nonce.random
    end
  end
end
