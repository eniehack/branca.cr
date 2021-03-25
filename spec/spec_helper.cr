require "spec"
require "json"
require "file"
require "../src/branca-cr"

class TestConfiguration < Branca::Configuration
    getter nonce : Sodium::Nonce
    getter box : Sodium::Cipher::Aead::XChaCha20Poly1305Ietf

    #def initialize(key : String, nonce : String)
    #  @key = Sodium::SecureBuffer.new key.to_slice
    #  @box = Sodium::Cipher::Aead::XChaCha20Poly1305Ietf.new @key
    #end

    def nonce=(nonce : Bytes)
      @nonce = Sodium::Nonce.new nonce
    end
end
