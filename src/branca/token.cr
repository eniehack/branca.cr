require "base62"
require "time"
require "sodium"
require "./configuration"
require "./error"

module Branca
  BRANCA_VERSION = 0xBA.to_u8

  class Token
    @config : BaseConfiguration

    def initialize(@config : BaseConfiguration); end

    # encodes payloads from config
    #
    # TODO: allow to accepts JSON::Seriarizable as payload
    # TODO: allow to accepts String as payload
    #
    # examples:
    # ```
    # require "branca"
    #
    # config = Branca::Configuraion.new
    # branca = Branca::Token.new(config)
    # token = branca.encode("hello world".to_slice)
    # ```
    def encode(payload : Bytes, timestamp : UInt64?) : String
      if timestamp.nil?
        timestamp = Time.utc.to_unix.to_u64
      end
      byte_timestamp = uninitialized UInt8[4]
      IO::ByteFormat::BigEndian.encode timestamp.to_u32, byte_timestamp.to_slice

      header = IO::Memory.new
      token = IO::Memory.new
      writer = IO::MultiWriter.new header, token

      writer.write_byte BRANCA_VERSION
      byte_timestamp.to_slice.each { |b| writer.write_byte b }
      @config.nonce.to_slice.each { |b| writer.write_byte b }

      ciphertext, _ = @config.box.encrypt payload, additional: header.to_slice, nonce: @config.nonce
      ciphertext.each { |b| token.write_byte b }

      Base62.encode token.to_slice
    end

    # Verified from branca token and config.
    # When you decodes token, You must use same nonce and same key as used to encode.
    #
    # examples:
    # ```
    # require "branca"
    #
    # config = Branca::Configuraion.new
    # branca = Branca::Token.new(config)
    # token = branca.decode("870S4BYxgHw0KnP3W9fgVUHEhT5g86vJ17etaC5Kh5uIraWHCI1psNQGv298ZmjPwoYbjDQ9chy2z")
    # ```
    def decode(token : String) : Bytes
      begin
        byte_token = bigint_to_bytes Base62.decode(token)
      rescue
        raise Branca::Error::Base62UnexpectedChar.new
      end

      header = byte_token[0..28]
      encrypted = byte_token[29..]

      version = header[0]
      timestamp = IO::ByteFormat::BigEndian.decode(UInt32, header[1...5]).to_u64
      nonce = Sodium::Nonce.new header[5..28]

      if version != BRANCA_VERSION
        raise Branca::Error::InvaildVersion.new
      end

      begin
        payload = @config.box.decrypt encrypted, nonce: nonce, additional: header
      rescue Sodium::Error::DecryptionFailed
        raise Branca::Error::InvaildToken.new
      end

      unless @config.ttl.nil?
        exp_time = timestamp + @config.ttl.not_nil!
        now = Time.utc.to_unix
        if exp_time < now
          raise Branca::Error::TokenHasExpired.new
        end
      end

      payload
    end

    private def bigint_to_bytes(int : BigInt) : Bytes
      buffer = Array(UInt8).new
      io = IO::Memory.new

      while int > 0
        ord = (int & 0xFF).to_u8
        buffer << ord
        int = (int - ord) // 256
      end
      buffer.reverse.each { |b| io.write_byte b }
      io.to_slice
    end
  end
end
