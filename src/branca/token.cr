require "base62"
require "time"
require "sodium"
require "./configuration"
require "./error"

module Branca
  BRANCA_VERSION = 0xBA.to_u8
  class Token
    property timestamp : UInt64
    property ttl : UInt64

    def initialize()
      @timestamp = 0
      @ttl = 0
    end

    def encode(payload : Bytes, config : BaseConfiguration) : String
      #TODO: payloadにJSONも受け付けられるようにする
      #unless config.key.nil?
      #  box = Sodium::Cipher::Aead::XChaCha20Poly1305Ietf.new config.key
      #else
      #  box = Sodium::Cipher::Aead::XChaCha20Poly1305Ietf.new
      #end

      if @timestamp.nil?
        @timestamp = Time.utc.to_unix.to_u64
      end
      byte_timestamp = uninitialized UInt8[4]
      IO::ByteFormat::BigEndian.encode @timestamp.to_u32, byte_timestamp.to_slice

      header = IO::Memory.new
      token = IO::Memory.new
      writer = IO::MultiWriter.new header, token

      writer.write_byte BRANCA_VERSION
      byte_timestamp.to_slice.each { |b| writer.write_byte b }
      config.nonce.to_slice.each { |b| writer.write_byte b }

      ciphertext, _ = config.box.encrypt payload, additional: header.to_slice, nonce: config.nonce
      ciphertext.each { |b| token.write_byte b }

      Base62.encode token.to_slice
    end

    def decode(token : String, config : BaseConfiguration) : Bytes
      begin
        byte_token = bigint_to_bytes Base62.decode(token)
      rescue
        raise Branca::Error::Base62UnexpectedChar.new
      end

      header = byte_token[0..28]
      p "header: #{header}"
      encrypted = byte_token[29..]
      p "encrypted: #{encrypted}"

      version = header[0]
      timestamp = header[1...5]
      @timestamp = IO::ByteFormat::BigEndian.decode(UInt32, timestamp).to_u64
      p "timestamp(#{timestamp.bytesize}) : #{timestamp}"
      nonce = Sodium::Nonce.new header[5..28]
      p "nonce: #{header[5..28]}"

      if version != BRANCA_VERSION
        raise Branca::Error::InvaildVersion.new
      end

      begin
        payload = config.box.decrypt encrypted, nonce: nonce, additional: header
      rescue Sodium::Error::DecryptionFailed
        raise Branca::Error::InvaildToken.new
      end

      p payload

      unless @ttl.nil?
        exp_time = @timestamp + @ttl
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
        ord = UInt8.new(int.as(BigInt) & 0xFF)
        buffer << ord
        int = ((int - ord) / 256).to_big_i
      end
      buffer.reverse.each { |b| io.write_byte b }
      io.to_slice
    end
  end
end